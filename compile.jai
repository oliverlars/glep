#load "ir.jai";

Compiler :: struct {
	ir: IR;
	strings: Table(string, int);
	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);

	register: int;

	scopes: [..]Scope_Frame;

	current_function: *IR_Function;
}

Binding :: struct {
	name: string;
	register: int;
	resolved_type: *Resolved_Type;
	declarator: *Node_Declarator;
}

Scope_Frame :: struct {
	bindings: [..]Binding;
}

push_scope :: (compiler: *Compiler) {
	scope: Scope_Frame;
	compiler.register = 0;
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

bind_decl :: (compiler: *Compiler, name: string, declarator: *Node_Declarator) -> Binding {
	frame := current_scope_frame(compiler);
	binding: Binding;
	binding.name = name;
	binding.register = next_register(compiler);
	binding.resolved_type = declarator.resolved_type;
	binding.declarator = declarator;
	array_add(*frame.bindings, binding);

	return binding;
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

find_decl_slot :: (compiler: *Compiler, name: string) -> Binding {
	find_decl_in_scope :: (compiler: *Compiler, name: string, scope_index: int) -> bool, Binding {
		if scope_index < 0 return false, .{};
		scope := compiler.scopes[scope_index];
		for scope.bindings {
			if it.name == name {
				return true, it;
			}
		}
		found, stack_slot := find_decl_in_scope(compiler, name, scope_index - 1);
		return found, stack_slot;
	}

	scope_index := compiler.scopes.count - 1;

	found, stack_slot := find_decl_in_scope(compiler, name, scope_index);
	assert(found);
	return stack_slot;
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
	return next;
}

compile_lvalue :: (compiler: *Compiler, expr: *Node_Expr) -> IR_Operand {

}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) -> IR_Operand {
	if !expr return .{};
	result: IR_Operand;
	function := compiler.current_function;
	if expr.expr_type == {
		case Node_Binary;
			binary := expr.(*Node_Binary);
			left := compile_expr(compiler, binary.left);
			right := compile_expr(compiler, binary.right);
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
			}
			result = dst;
		case Node_Identifier;
			id := expr.(*Node_Identifier);
			slot := find_decl_slot(compiler, id.id.view);
			result = ir_register(slot.register, operand_type(slot.resolved_type));
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
			dst := compile_expr(compiler, assign.left);
			src := compile_expr(compiler, assign.right);
			ir_emit(function, ir_copy(dst, src));
			result = dst;
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
	}
	return result;
}

compile_decl :: (compiler: *Compiler, decl: *Node_Decl) {
	for decl.declarators {
		name := identifier_from_declarator(it);

		binding := bind_decl(compiler, name, it);
		dst := ir_register(binding.register, operand_type(it.resolved_type));
		compile_initializer(compiler, it.init, dst);
	}
}

compile_statement :: (compiler: *Compiler, statement: *Node_Statement) {

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
		ir_emit(function, ir_copy(dst, value));
	} else {
		assert(false, "TODO: designated initializer");
	}
}

compile :: (compiler: *Compiler, tu: Node_Translation_Unit) {
	for decl: tu.declarations {
		for declarator: decl.declarators {
			if is_function_definition(decl, declarator) {
				ir_function: IR_Function;
				ir_function.name = identifier_from_declarator(declarator);
				function := function_declarator(declarator);
				compiler.current_function = *ir_function;
				compile_statement(compiler, decl.body);
				array_add(*compiler.ir.functions, ir_function);
			}
		}
	}

	for value, key: compiler.strings {
		ir_emit_global(*compiler.ir, tprint("str%", value), xx key, 8);
	}

	for decl: tu.declarations {
		for declarator: decl.declarators {
			if is_variable_declaration(decl, declarator) {
			}
		}
	}
}