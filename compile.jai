#load "ir.jai";

Compiler :: struct {
	ir: IR;
	strings: Table(string, int);
	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);

	register: int;
	registers_needed: int;

	scopes: [..]Scope_Frame;

	current_function: *IR_Function;

	label_counter: int;
}

Binding :: struct {
	name: string;
	slot: IR_Operand;
	resolved_type: *Resolved_Type;
}

Scope_Frame :: struct {
	bindings: [..]Binding;
}

push_scope :: (compiler: *Compiler) {
	scope: Scope_Frame;
	array_add(*compiler.scopes, scope);
}

pop_scope :: (compiler: *Compiler) {
	assert(compiler.scopes.count > 0);
	compiler.scopes.count -= 1;
}

current_scope_frame :: (compiler: *Compiler) -> *Scope_Frame {
	assert(compiler.scopes.count > 0);
	return *compiler.scopes[compiler.scopes.count - 1];
}

bind_decl :: (compiler: *Compiler, name: string, slot: IR_Operand, rt: *Resolved_Type) -> Binding {
	frame := current_scope_frame(compiler);
	binding: Binding;
	binding.name = name;
	binding.resolved_type = rt;
	binding.slot = slot;
	array_add(*frame.bindings, binding);

	return binding;
}

next_label :: (compiler: *Compiler) -> string {
	defer compiler.label_counter += 1;
	return tprint("l%", compiler.label_counter);
}

is_function_definition :: (decl: *Node_Decl, declarator: *Node_Declarator) -> bool {
	return is_function_declaration(declarator) && decl.body != null;
}

is_function_declaration :: (declarator: *Node_Declarator) -> bool {
	while declarator {
		if declarator.declarator_type == Node_Function_Declarator {
			return true;
		}
		declarator = declarator.inner;
	}
	return false;
}

find_binding :: (compiler: *Compiler, name: string) -> Binding, bool {
	is_global := 0;
	for < compiler.scopes {
		for it.bindings {
			if it.name == name return it, it_index == 0;
		}
	}
	assert(false, "undeclared variable");
	return .{}, false;
}

is_variable_declaration :: (decl: *Node_Decl, declarator: *Node_Declarator) -> bool {
	return !is_function_declaration(declarator) && !is_typedef(decl.base);
}

operand_type :: (resolved_type: *Resolved_Type) -> IR_Operand_Type {
	if resolved_type.kind == .Floating {
		return .{ .Float, resolved_type.size_in_bytes, false };
	} else {
		return .{ .Integer, resolved_type.size_in_bytes, resolved_type.unsigned };
	}
}

next_register :: (compiler: *Compiler) -> int {
	next := compiler.register;
	compiler.register += 1;
	compiler.registers_needed = max(compiler.registers_needed, compiler.register);
	return next;
}

offset_from_member_name :: (_struct: *Node_Struct, layout: Struct_Layout, name: string) -> int {
	offset := 0;
	index := 0;
	for _struct.members {
		for declarator: it.declarators {
			member_name := identifier_from_declarator(declarator);
			if name == member_name {
				offset = layout.members[index].offset;
				break it;
			}
			index += 1;
		}
	}
	return offset;
}

compile_lvalue :: (compiler: *Compiler, expr: *Node_Expr) -> IR_Operand {
	if !expr return .{};
	function := compiler.current_function;
	if expr.expr_type == {
		case Node_Compound;
			compound := expr.(*Node_Compound);
			size := (compound.resolved_type.size_in_bytes + 7) & ~7;
			dst := ir_register(next_register(compiler), IR_PTR);
			ir_emit(function, ir_alloca(dst, xx size));
			ir_emit(function, ir_param(dst));
			ir_emit(function, ir_param(ir_constant(0, IR_S64)));
			ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));
			ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memset", 3));
			compile_initializer(compiler, compound.init, dst);
			return dst;
		case Node_Identifier;
			id := expr.(*Node_Identifier);
			binding := find_binding(compiler, id.id.view);
			operand := binding.slot;
			if binding.slot.kind == .Label {
				dst := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(dst, binding.slot));
				operand = dst;
			}
			return operand;
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			operand: IR_Operand;
			if member_access.op.type == .Arrow {
				// LHS is already a pointer, load it directly.
				operand = compile_expr(compiler, member_access.left);
			} else {
				// LHS is a value but we want the address
				operand = compile_lvalue(compiler, member_access.left);
			}
			lhs_type := member_access.left.resolved_type;
			if lhs_type.composite == null {
				lhs_type = lhs_type.inner;
			}
			_struct := lhs_type.composite.(*Node_Struct);

			offset := offset_from_member_name(_struct, lhs_type.layout, member_access.right.view);
			ir_emit(function, ir_add(operand, operand, ir_constant(offset.(u64), IR_U64)));
			return operand;
		case Node_Unary;
			unary := expr.(*Node_Unary);
			if unary.op.type == .Asterisk {
				dst := compile_lvalue(compiler, unary.expr);
			}
	}
}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) -> IR_Operand {
	if !expr return .{};
	result: IR_Operand;
	function := compiler.current_function;
	if expr.expr_type == {
		case Node_Unary;
			unary := expr.(*Node_Unary);
			if unary.op.type == {
				case .Minus;
					value := compile_expr(compiler, unary.expr);
					dst := ir_register(next_register(compiler), value.type);
					ir_emit(function, ir_neg(dst, value));
					result = dst;
				case .Bang;
					value := compile_expr(compiler, unary.expr);
					dst := ir_register(next_register(compiler), value.type);
					ir_emit(function, ir_eq(dst, dst, ir_constant(0, dst.type)));
					result = dst;
				case .PlusPlus;
					address := compile_lvalue(compiler, unary.expr);
					pre := ir_register(next_register(compiler), operand_type(unary.expr.resolved_type));
					ir_emit(function, ir_load(pre, address));

					offset := 1;
					if unary.expr.resolved_type.kind == .Pointer {
						offset = unary.expr.resolved_type.inner.size_in_bytes;
					}

					post := ir_register(next_register(compiler), pre.type);
					ir_emit(function, ir_add(post, pre, ir_constant(xx offset, pre.type)));
					ir_emit(function, ir_store(address, post));

					if unary.postfix {
						result = pre;
					} else {
						result = post;
					}
			}
		case Node_Binary;
			binary := expr.(*Node_Binary);
			short_circuit := next_label(compiler);
			left := compile_expr(compiler, binary.left);
			if binary.op.type == .PipePipe {
				ir_emit(function, ir_if(left, short_circuit));
			} else if binary.op.type == .AmpersandAmpersand {
				ir_emit(function, ir_ifz(left, short_circuit));
			}
			right := compile_expr(compiler, binary.right);
			ir_emit(function, ir_label(short_circuit));
			dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));
			if binary.op.type == {
				case .Plus;
					ir_emit(function, ir_add(dst, left, right));
				case .Minus;
					ir_emit(function, ir_sub(dst, left, right));
				case .Asterisk;
					ir_emit(function, ir_mul(dst, left, right));
				case .ForwardSlash;
					ir_emit(function, ir_div(dst, left, right));
				case .Less;
					ir_emit(function, ir_lt(dst, left, right));
				case .Greater;
					ir_emit(function, ir_lt(dst, right, left));
				case .LessEqual;
					ir_emit(function, ir_le(dst, left, right));
				case .GreaterEqual;
					ir_emit(function, ir_le(dst, right, left));
				case .EqualEqual;
					ir_emit(function, ir_eq(dst, left, right));
				case .BangEqual;
					ir_emit(function, ir_ne(dst, left, right));
				case .Percent;
					ir_emit(function, ir_mod(dst, left, right));
				case .Ampersand;
					ir_emit(function, ir_and(dst, left, right));
			}
			result = dst;
		case Node_Identifier;
			id := expr.(*Node_Identifier);
			binding := find_binding(compiler, id.id.view);
			address := binding.slot;
			if binding.slot.kind == .Label {
				address = ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(address, binding.slot));
			}
			dst := ir_register(next_register(compiler), operand_type(binding.resolved_type));
			ir_emit(function, ir_load(dst, address));
			result = dst;
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			address := compile_lvalue(compiler, member_access);
			dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));
			ir_emit(function, ir_load(dst, address));
			result = dst;
		case Node_String;
			str := expr.(*Node_String);
			found, count := table_find(*compiler.strings, str.token.view);
			if !found {
				count = compiler.strings.count;
				table_set(*compiler.strings, str.token.view, count);
			}
			label := tprint("str%", count);
			dst := ir_register(next_register(compiler), .{ .Integer, 8, true });
			ir_emit(function, ir_address(dst, ir_label_operand(label)));
			result = dst;
		case Node_If;
			_if := expr.(*Node_If);
			cond := compile_expr(compiler, _if.cond);
			on_false := next_label(compiler);
			end := next_label(compiler);

			ir_emit(function, ir_ifz(cond, on_false));
			compile_statement(compiler, _if.on_true);
			ir_emit(function, ir_goto(end));
			ir_emit(function, ir_label(on_false));
			compile_statement(compiler, _if.on_false);
			ir_emit(function, ir_label(end));
		case Node_For;
			_for := expr.(*Node_For);
			start := next_label(compiler);
			end := next_label(compiler);

			compile_statement(compiler, _for.init);
			ir_emit(function, ir_label(start));
			cond := compile_expr(compiler, _for.cond);
			ir_emit(function, ir_ifz(cond, end));
			compile_statement(compiler, _for.body);
			compile_expr(compiler, _for.expr);
			ir_emit(function, ir_goto(start));
			ir_emit(function, ir_label(end));
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			
			for call.args {
				arg := compile_expr(compiler, it);
				ir_emit(function, ir_param(arg));
			}
			
			dst := ir_register(next_register(compiler), operand_type(call.resolved_type));
			ir_emit(function, ir_call(dst, name, xx call.args.count));
			result = dst;
		case Node_Assign;
			assign := expr.(*Node_Assign);
			address := compile_lvalue(compiler, assign.left);
			value := compile_expr(compiler, assign.right);
			ir_emit(function, ir_store(address, value));
			result = value;
		case Node_Number;
			number := expr.(*Node_Number);
			type := operand_type(number.resolved_type);
			if number.kind == .FLOAT {
				value: u64;
				memcpy(*value, *number.as_f64, 8);
				result = ir_constant(value, type);
			} else {
				result = ir_constant(number.as_u64, type);
			}
		case Node_Cast;
			_cast := expr.(*Node_Cast);
			dst := ir_register(next_register(compiler), operand_type(_cast.resolved_type));
			ir_emit(function, ir_cast(dst, compile_expr(compiler, _cast.expr)));
			result = dst;
		case Node_Decl;
			decl := expr.(*Node_Decl);
			compile_decl(compiler, decl);
	}
	return result;
}

compile_decl :: (compiler: *Compiler, decl: *Node_Decl) {
	function := compiler.current_function;
	for decl.declarators {
		name := identifier_from_declarator(it);

		slot := ir_register(next_register(compiler), IR_PTR);
		ir_emit(function, ir_alloca(slot, xx it.resolved_type.size_in_bytes));
		binding := bind_decl(compiler, name, slot, it.resolved_type);
		compile_initializer(compiler, it.init, slot);
	}
}

compile_statement :: (compiler: *Compiler, statement: *Node_Statement) {
	if !statement return;
	function := compiler.current_function;
	if statement.statement_type == {
		case Node_Decl_Statement;
			decl := statement.(*Node_Decl_Statement).decl;
			compile_decl(compiler, decl);
		case Node_Expr_Statement;
			compile_expr(compiler, statement.(*Node_Expr_Statement).expr);
		case Node_Return;
			ret := ir_return(compile_expr(compiler, statement.(*Node_Return).expr));
			ir_emit(function, ret);
		case Node_Block;
			push_scope(compiler);
			block := statement.(*Node_Block);
			for block.statements {
				compile_statement(compiler, it);
			}
			pop_scope(compiler);
	}
}

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, dst: IR_Operand) {
	if !init return;
	function := compiler.current_function;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		value := compile_expr(compiler, expr);
		ir_emit(function, ir_store(dst, value));
	} else {
		assert(false, "TODO: designated initializer");
	}
}

compile :: (compiler: *Compiler, tu: Node_Translation_Unit) {

	push_scope(compiler);
	for decl: tu.declarations {
		for declarator: decl.declarators {
			name := identifier_from_declarator(declarator);
			if is_function_definition(decl, declarator) {
				ir_function: IR_Function;
				ir_function.name = name;

				function := function_declarator(declarator);
				compiler.register = 0;
				compiler.registers_needed = 0;
				compiler.current_function = *ir_function;
				for function.params {
					compile_decl(compiler, it);
					array_add(*ir_function.params, operand_type(it.declarators[0].resolved_type));
				}
				compile_statement(compiler, decl.body);
				ir_function.registers_needed = compiler.registers_needed;
				array_add(*compiler.ir.functions, ir_function);
			} else if is_variable_declaration(decl, declarator) {
				bind_decl(compiler, name, ir_label_operand(name), declarator.resolved_type);
			}
		}
	}
	pop_scope(compiler);

	for value, key: compiler.strings {
		ir_emit_global(*compiler.ir, tprint("str%", value), xx key, 8);
	}
	
}