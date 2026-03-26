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
	for < scope: compiler.scopes {
		for < scope.bindings {
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
	dst := ir_register(next_register(compiler), IR_PTR);
	if expr.expr_type == {
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);
			index := compile_expr(compiler, array_access.index);
			
			array := compile_lvalue(compiler, array_access.left);

			if array_access.left.resolved_type.kind == .Pointer {
				loaded := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_load(loaded, array));
				array = loaded;
			}

			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;
			ir_emit(function, ir_mul(index, index, ir_constant(xx bytes_per_element, IR_U64)));
			ir_emit(function, ir_add(dst, array, index));
			return dst;
		case Node_Compound;
			compound := expr.(*Node_Compound);
			size := (compound.resolved_type.size_in_bytes + 7) & ~7;
			compound_address := ir_register(next_register(compiler), IR_PTR);
			ir_emit(function, ir_alloca(dst, xx size));
			ir_emit(function, ir_address(compound_address, dst));
			ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memset", 3));
			ir_emit(function, ir_param(compound_address));
			ir_emit(function, ir_param(ir_constant(0, IR_S64)));
			ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));

			compile_initializer(compiler, compound.init, dst);
			dst = compound_address;
			return dst;
		case Node_Identifier;
			id := expr.(*Node_Identifier);
			binding := find_binding(compiler, id.id.view);
			if binding.slot.kind == .Label {
				ir_emit(function, ir_address(dst, binding.slot));
			} else {
				dst = binding.slot;
				dst.type = IR_PTR;
			}
			return dst;
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			operand: IR_Operand;
			lhs_type := member_access.left.resolved_type;
			if member_access.op.type == .Arrow {
				lhs_type = lhs_type.inner;
				// LHS is already a pointer, load it directly.
				operand = compile_expr(compiler, member_access.left);
			} else {
				// LHS is a value but we want the address
				operand = compile_lvalue(compiler, member_access.left);
			}

			_struct := lhs_type.composite.(*Node_Struct);
			offset := offset_from_member_name(_struct, lhs_type.layout, member_access.right.view);
			ir_emit(function, ir_add(dst, operand, ir_constant(offset.(u64), IR_U64)));
			return dst;
		case Node_Unary;
			unary := expr.(*Node_Unary);
			if unary.op.type == .Asterisk {
				dst := compile_expr(compiler, unary.expr);
				return dst;
			}
			assert(false, "We shouldnt try compling an lvalue unary that isnt a dereference");
			return .{};
		case Node_Call;
			value := compile_expr(compiler, expr);
			if expr.resolved_type.kind == .Composite {
				return value;
			}
			size := (expr.resolved_type.size_in_bytes + 7) & ~7;
			ir_emit(function, ir_alloca(dst, xx size));
			ir_emit(function, ir_store(dst, value));
			return dst;
		case;
			assert(false, "Compile LValue case not implemented");
			return .{};
	}
	return .{};
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
					ir_emit(function, ir_eq(dst, value, ir_constant(0, value.type)));
					result = dst;
				case .Ampersand;
					address := compile_lvalue(compiler, unary.expr);
					dst := ir_register(next_register(compiler), address.type);
					ir_emit(function, ir_copy(dst, address));
					result = dst;
				case .Asterisk;
					value := compile_expr(compiler, unary.expr);
					dst := ir_register(next_register(compiler), operand_type(unary.expr.resolved_type.inner));
					ir_emit(function, ir_load(dst, value));
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
		case Node_Compound;
			result = compile_lvalue(compiler, expr);
		case Node_Sizeof_Type;
			sizeof := expr.(*Node_Sizeof_Type);
			dst := ir_constant(xx sizeof.target_type.size_in_bytes, operand_type(sizeof.target_type));
			result = dst;
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			dst := ir_constant(xx sizeof.expr.resolved_type.size_in_bytes, operand_type(sizeof.expr.resolved_type));
			result = dst;
		case Node_Binary;
			binary := expr.(*Node_Binary);

			dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));

			if binary.op.type == .AmpersandAmpersand {
				on_false := next_label(compiler);
				end := next_label(compiler);

				left := compile_expr(compiler, binary.left);
				ir_emit(function, ir_ifz(left, on_false));

				right := compile_expr(compiler, binary.right);
				ir_emit(function, ir_ne(dst, right, ir_constant(0, right.type)));
				ir_emit(function, ir_goto(end));

				ir_emit(function, ir_label(on_false));
				ir_emit(function, ir_copy(dst, ir_constant(0, dst.type)));

				ir_emit(function, ir_label(end));
			} else if binary.op.type == .PipePipe {
				end := next_label(compiler);

				left := compile_expr(compiler, binary.left);
				ir_emit(function, ir_ne(dst, left, ir_constant(0, left.type)));
				ir_emit(function, ir_if(left, end));

				right := compile_expr(compiler, binary.right);
				ir_emit(function, ir_ne(dst, right, ir_constant(0, right.type)));
				ir_emit(function, ir_label(end));
			} else {
				left := compile_expr(compiler, binary.left);
				right := compile_expr(compiler, binary.right);
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
					case .Pipe;
						ir_emit(function, ir_or(dst, left, right));
					case .Caret;
						ir_emit(function, ir_xor(dst, left, right));
					case .LessLess;
						ir_emit(function, ir_shl(dst, left, right));
					case .GreaterGreater;
						ir_emit(function, ir_shr(dst, left, right));
				}
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
			dst: IR_Operand;
			if binding.resolved_type.kind == .Composite || binding.resolved_type.kind == .Array {
				dst = ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_copy(dst, address));
			} else {
				dst = ir_register(next_register(compiler), operand_type(binding.resolved_type));
				ir_emit(function, ir_load(dst, address));
			}
			result = dst;
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			
			address := compile_lvalue(compiler, member_access);
			if member_access.resolved_type.kind == .Composite {
				result = address;
			} else {
				dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));
				ir_emit(function, ir_load(dst, address));
				result = dst;
			}
		case Node_Array_Access;
			address := compile_lvalue(compiler, expr);
			if expr.resolved_type.kind == .Composite {
				result = address;
			} else {
				dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));
				ir_emit(function, ir_load(dst, address));
				result = dst;
			}
		case Node_Char;
			c := expr.(*Node_Char);
			value := eval_char_literal(c.token.view);
			result = ir_constant(xx value, IR_S32);
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
		case Node_Ternary;
			ternary := expr.(*Node_Ternary);
			on_false := next_label(compiler);
			end := next_label(compiler);

			dst := ir_register(next_register(compiler), operand_type(ternary.resolved_type));

			cond := compile_expr(compiler, ternary.cond);
			ir_emit(function, ir_ifz(cond, on_false));
			expr_true := compile_expr(compiler, ternary.on_true);
			ir_emit(function, ir_copy(dst, expr_true));
			ir_emit(function, ir_goto(end));
			ir_emit(function, ir_label(on_false));
			expr_false := compile_expr(compiler, ternary.on_false);
			ir_emit(function, ir_copy(dst, expr_false));
			ir_emit(function, ir_label(end));
			result = dst;
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;

			emit_struct_params :: (compiler: *Compiler, base: IR_Operand, _struct: *Node_Struct, layout: Struct_Layout, args: *[..]IR_Operand) -> int {
				function := compiler.current_function;
				param_count := 0;
				index := 0;
				for _struct.members {
					for declarator: it.declarators {
						member_type := declarator.resolved_type;
						offset := layout.members[index].offset;

						address := base;
						if offset != 0 {
							address = ir_register(next_register(compiler), IR_PTR);
							ir_emit(function, ir_add(address, base, ir_constant(xx offset, IR_U64)));
						}

						if member_type.kind == .Composite {
							param_count += emit_struct_params(compiler, address, member_type.composite.(*Node_Struct), member_type.layout, args);
						} else {
							value := ir_register(next_register(compiler), operand_type(member_type));
							ir_emit(function, ir_load(value, address));
							array_add(args, value);
							param_count += 1;
						}
						index += 1;
					}
				}
				return param_count;
			}

			_, decl := table_find(*compiler.ordinary, name);
			source_function := function_declarator(decl.(*Node_Decl).declarators[0]);
			source_param_count := source_function.params.count;

			args: [..] IR_Operand;
			non_variadic_expanded_param_count := 0;
			for call.args {
				variadic := it_index >= source_param_count;
				if it.resolved_type.kind == .Composite {
					address := compile_lvalue(compiler, it);
					param_count := emit_struct_params(compiler, address, it.resolved_type.composite.(*Node_Struct), it.resolved_type.layout, *args);
					if !variadic then non_variadic_expanded_param_count += param_count;
				} else {
					arg := compile_expr(compiler, it);
					array_add(*args, arg);
					if !variadic then non_variadic_expanded_param_count += 1;
				}
			}

			if call.resolved_type.kind == .Composite {
				ret_slot := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_alloca(ret_slot, xx call.resolved_type.size_in_bytes));
				ir_emit(function, ir_call(ret_slot, name, xx non_variadic_expanded_param_count));

				for args {
					ir_emit(function, ir_param(it));
				}

				addr := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(addr, ret_slot));
				result = addr;
			} else {
				dst := ir_register(next_register(compiler), operand_type(call.resolved_type));
				ir_emit(function, ir_call(dst, name, xx non_variadic_expanded_param_count));

				for args {
					ir_emit(function, ir_param(it));
				}

				result = dst;
			}
		case Node_Assign;
			assign := expr.(*Node_Assign);
			lhs := compile_lvalue(compiler, assign.left);
			if assign.right.resolved_type.kind == .Composite {
				rhs := compile_expr(compiler, assign.right);
				size := assign.right.resolved_type.size_in_bytes;
				ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memcpy", 3));
				ir_emit(function, ir_param(lhs));
				ir_emit(function, ir_param(rhs));
				ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));
			} else {
				rhs := compile_expr(compiler, assign.right);
				ir_emit(function, ir_store(lhs, rhs));
			}
			result = lhs;
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
			for decl.declarators {
				compile_declarator(compiler, it);
			}
	}
	return result;
}

compile_declarator :: (compiler: *Compiler, declarator: *Node_Declarator) -> Binding {
	function := compiler.current_function;
	name := identifier_from_declarator(declarator);

	slot := ir_register(next_register(compiler), IR_PTR);
	ir_emit(function, ir_alloca(slot, xx declarator.resolved_type.size_in_bytes));
	binding := bind_decl(compiler, name, slot, declarator.resolved_type);
	compile_initializer(compiler, declarator.init, slot);
	return binding;
}

compile_statement :: (compiler: *Compiler, statement: *Node_Statement) {
	if !statement return;
	function := compiler.current_function;
	if statement.statement_type == {
		case Node_Decl_Statement;
			decl := statement.(*Node_Decl_Statement).decl;
			for decl.declarators {
				compile_declarator(compiler, it);
			}
		case Node_Expr_Statement;
			compile_expr(compiler, statement.(*Node_Expr_Statement).expr);
		case Node_Return;
			ret := ir_return(compile_expr(compiler, statement.(*Node_Return).expr));
			ir_emit(function, ret);
		case Node_For;
			_for := statement.(*Node_For);
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
		case Node_While;
			_while := statement.(*Node_While);
			start := next_label(compiler);
			end := next_label(compiler);

			ir_emit(function, ir_label(start));
			cond := compile_expr(compiler, _while.cond);
			ir_emit(function, ir_ifz(cond, end));
			compile_statement(compiler, _while.body);
			ir_emit(function, ir_goto(start));
			ir_emit(function, ir_label(end));
		case Node_If;
			_if := statement.(*Node_If);
			on_false := next_label(compiler);
			end := next_label(compiler);
			cond := compile_expr(compiler, _if.cond);
			ir_emit(function, ir_ifz(cond, on_false));
			compile_statement(compiler, _if.on_true);
			ir_emit(function, ir_goto(end));
			ir_emit(function, ir_label(on_false));
			compile_statement(compiler, _if.on_false);
			ir_emit(function, ir_label(end));
		case Node_Block;
			push_scope(compiler);
			block := statement.(*Node_Block);
			for block.statements {
				compile_statement(compiler, it);
			}
			pop_scope(compiler);
		case Node_Label;
			label := tprint("l%_%",statement.(*Node_Label).token.view, compiler.current_function.name);
			ir_emit(function, ir_label(label));
		case Node_Goto;
			goto := statement.(*Node_Goto);
			label := tprint("l%_%", goto.to.view, compiler.current_function.name);
			ir_emit(function, ir_goto(label));
	}
}

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, dst: IR_Operand) {
	if !init return;
	function := compiler.current_function;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		if expr.resolved_type.kind == .Composite {
			rhs := compile_expr(compiler, expr);
			size := expr.resolved_type.size_in_bytes;
			ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memcpy", 3));
			ir_emit(function, ir_param(dst));
			ir_emit(function, ir_param(rhs));
			ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));

		} else {
			value := compile_expr(compiler, expr);
			ir_emit(function, ir_store(dst, value));
		}
	} else {
		for init.(*Node_Designated_Initializer).designations {
			member_address := dst;
			if it.byte_offset != 0 {
				member_address = ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_add(member_address, dst, ir_constant(xx it.byte_offset, IR_U64)));
			}
			compile_initializer(compiler, it.expr, member_address);
		}
	}
}

compile_global_initializer :: (compiler: *Compiler, init: *Node_Initializer, size_in_bytes: int) -> []u8 {
	if !init return {};
	compile_global_initializer :: (compiler: *Compiler, init: *Node_Initializer, bytes: []u8, byte_offset := 0) -> int {
		if !init return byte_offset;
		function := compiler.current_function;
		if init.initializer_type == Node_Scalar_Initializer {
			expr := init.(*Node_Scalar_Initializer).expr;
			value := eval_constant_expr(expr);
			if expr.resolved_type.kind == .Floating && expr.resolved_type.size_in_bytes == 4 {
				f32_val := cast(float32) value.as_f64;
				memcpy(bytes.data + byte_offset, *f32_val, 4);
			} else {
				memcpy(bytes.data + byte_offset, *value.as_u64, expr.resolved_type.size_in_bytes);
			}
			return byte_offset + expr.resolved_type.size_in_bytes;
		} else {
			for init.(*Node_Designated_Initializer).designations {
				compile_global_initializer(compiler, it.expr, bytes, byte_offset + it.byte_offset);
			}
		}
		return byte_offset;
	}
	bytes := NewArray(size_in_bytes, u8);
	compile_global_initializer(compiler, init, bytes);
	return bytes;
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

				append_struct_params :: (_struct: *Node_Struct, layout: Struct_Layout, params: *[..]IR_Operand_Type) {
					index := 0;
					for _struct.members {
						for declarator: it.declarators {
							member_type := declarator.resolved_type;
							if member_type.kind == .Composite {
								append_struct_params(member_type.composite.(*Node_Struct), member_type.layout, params);
							} else {
								array_add(params, operand_type(member_type));
							}
							index += 1;
						}
					}
				}

				emit_struct_load_params :: (compiler: *Compiler, function: *IR_Function, _struct: *Node_Struct, layout: Struct_Layout, base: IR_Operand, param_index: int) -> int {
					index := 0;
					for _struct.members {
						for declarator: it.declarators {
							member_type := declarator.resolved_type;
							offset := layout.members[index].offset;

							if member_type.kind == .Composite {
								member_base := base;
								member_base = ir_register(next_register(compiler), IR_PTR);
								ir_emit(function, ir_add(member_base, base, ir_constant(xx offset, IR_U64)));
								param_index = emit_struct_load_params(compiler, function, member_type.composite.(*Node_Struct), member_type.layout, member_base, param_index);
							} else {
								dst := ir_register(next_register(compiler), operand_type(member_type));
								ir_emit(function, ir_load_param(dst, ir_constant(xx param_index, IR_U64)));
								address := base;
								address = ir_register(next_register(compiler), IR_PTR);
								ir_emit(function, ir_add(address, base, ir_constant(xx offset, IR_U64)));
								ir_emit(function, ir_store(address, dst));
								param_index += 1;
							}
							index += 1;
						}
					}
					return param_index;
				}

				param_index := 0;
				for function.params {
					binding := compile_declarator(compiler, it.declarators[0]);
					param_type := it.declarators[0].resolved_type;
					if param_type.kind == .Composite {
						_struct := param_type.composite.(*Node_Struct);
						param_index = emit_struct_load_params(compiler, *ir_function, _struct, param_type.layout, binding.slot, param_index);
						append_struct_params(_struct, param_type.layout, *ir_function.params);
					} else {
						array_add(*ir_function.params, operand_type(param_type));
						dst := ir_register(next_register(compiler), operand_type(param_type));
						ir_emit(*ir_function, ir_load_param(dst, ir_constant(xx param_index, IR_U64)));
						ir_emit(*ir_function, ir_store(binding.slot, dst));
						param_index += 1;
					}
				}

				ret_type := declarator.resolved_type;
				if ret_type.kind == .Composite {
					append_struct_params(ret_type.composite.(*Node_Struct), ret_type.layout, *ir_function.results);
				} else {
					array_add(*ir_function.results, operand_type(ret_type));
				}

				compile_statement(compiler, decl.body);
				ir_function.registers_needed = compiler.registers_needed;
				array_add(*compiler.ir.functions, ir_function);
			} else if is_variable_declaration(decl, declarator) {
				bind_decl(compiler, name, ir_label_operand(name), declarator.resolved_type);
				bytes := compile_global_initializer(compiler, declarator.init, declarator.resolved_type.size_in_bytes);
				ir_emit_global(*compiler.ir, name, bytes, declarator.resolved_type.alignment);
			}
		}
	}
	pop_scope(compiler);

	for value, key: compiler.strings {
		terminated_bytes := process_string_escapes(key);
		ir_emit_global(*compiler.ir, tprint("str%", value), terminated_bytes, 1);
	}
	
}