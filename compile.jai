
Stack_Slot :: struct {
	name: string;
	offset: int;
	resolved_type: *Resolved_Type;
	declarator: *Node_Declarator;
}

Scope_Frame :: struct {
	slots: [..]Stack_Slot;
	start_offset: int;
}

Compiler :: struct {
	builder: String_Builder;
	register := 9;

	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);

	strings: Table(string, int);
	// Just linearly search idk seems fine and less noisy
	// We also don't need the full type since we are doing
	// textual assembly so only need the label
	globals: [..]string;
	
	// This is just a convenienve thing, theres
	// only 1 stack frame per function but we
	// need to track what offset the scope
	// entered so we can restore it on exit
	scopes: [..]Scope_Frame;
	stack_offset: int;

	variadic_stack_size: int;
}

push_scope :: (compiler: *Compiler) {
	scope: Scope_Frame;
	scope.start_offset = compiler.stack_offset;
	array_add(*compiler.scopes, scope);
}

// FIXME(Oliver): This leaks like basically everything else
// which is fine but it uses more memory than it needs to
pop_scope :: (compiler: *Compiler) {
	assert(compiler.scopes.count > 0);
	compiler.stack_offset = compiler.scopes[compiler.scopes.count - 1].start_offset;
	compiler.scopes.count -= 1;
}

current_scope_frame :: (compiler: *Compiler) -> *Scope_Frame {
	assert(compiler.scopes.count > 0);
	return *compiler.scopes[compiler.scopes.count - 1];
}

push_decl :: (compiler: *Compiler, name: string, size_in_bytes: int, declarator: *Node_Declarator) -> Stack_Slot {
	scope := current_scope_frame(compiler);
	stack_slot: Stack_Slot;
	stack_slot.name = name;
	stack_slot.offset = compiler.stack_offset;
	stack_slot.declarator = declarator;
	array_add(*scope.slots, stack_slot);
	// TODO(Oliver): Derive from decl?
	// Nearest 8 bytes because alignment
	compiler.stack_offset += (size_in_bytes + 7) & ~7;
	return stack_slot;
}

find_decl_on_stack :: (compiler: *Compiler, name: string) -> bool, Stack_Slot {

	find_decl_in_scope :: (compiler: *Compiler, name: string, scope_index: int) -> bool, Stack_Slot {
		if scope_index < 0 return false, .{};
		scope := compiler.scopes[scope_index];
		for scope.slots {
			if it.name == name {
				return true, it;
			}
		}
		found, stack_slot := find_decl_in_scope(compiler, name, scope_index - 1);
		return found, stack_slot;
	}

	scope_index := compiler.scopes.count - 1;

	found, stack_slot := find_decl_in_scope(compiler, name, scope_index);
	return found, stack_slot;
}

load_variable_into_register :: (compiler: *Compiler, name: string) {
	found, stack_slot := find_decl_on_stack(compiler, name);
	if !found {
		for compiler.globals {
			if it == name {
				emit(compiler, "adrp x%, _%@PAGE", compiler.register, name, compiler.register);
				emit(compiler, "ldr w%, [x%, _%@PAGEOFF]", compiler.register, compiler.register, name, compiler.register, compiler.register);
				return;
			}
		}
		// We should have found it on the stack
		// TODO(Oliver): error checking
		assert(false);
	} else {
		if stack_slot.declarator.resolved_type && stack_slot.declarator.resolved_type.size_in_bytes == 8 {
			emit(compiler, "ldr x%, [sp, #%]", compiler.register, stack_slot.offset);
		} else {
			emit(compiler, "ldr w%, [sp, #%]", compiler.register, stack_slot.offset);
		}
	}
}

emit :: (compiler: *Compiler, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	//print("%\n", to_append);
	append(*compiler.builder, to_append);
	append(*compiler.builder, "\n");
}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Unary;
			op := expr.(*Node_Unary).op;
			if op.type == {
				case .Asterisk;
					compile_expr(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x%, [x%]", compiler.register, compiler.register);
				case .Ampersand;
					rhs := expr.(*Node_Unary).expr;
					assert(rhs.expr_type == Node_Identifier);
					id := rhs.(*Node_Identifier).id.view;
					// TODO(Oliver): handle globals for addresses
					found, stack_slot := find_decl_on_stack(compiler, id);
					if !found {
						// Might be a global, handle that
						assert(false);
					}
					emit(compiler, "add x%, sp, #%", compiler.register, stack_slot.offset);
			}
		case Node_Binary;
			compile_expr(compiler, expr.(*Node_Binary).left);
			dst := compiler.register;
			compiler.register += 1;
			compile_expr(compiler, expr.(*Node_Binary).right);
			if expr.(*Node_Binary).op.type == {
				case .Plus;
					emit(compiler, "add w%, w%, w%", dst, dst, compiler.register);
				case .Minus;
					emit(compiler, "sub w%, w%, w%", dst, dst, compiler.register);
				case .Asterisk;
					emit(compiler, "mul w%, w%, w%", dst, dst, compiler.register);
				case .ForwardSlash;
					emit(compiler, "div w%, w%, w%", dst, dst, compiler.register);
			}
			compiler.register -= 1;
		case Node_Number;
			emit(compiler, "mov w%, #%", compiler.register, expr.(*Node_Number).as_u64.(u32));
		case Node_Char;
			value := 0;
			for expr.(*Node_Char).token.view {
				value += it;
			}
			emit(compiler, "mov w%, #%", compiler.register, value);
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			_, decl := table_find(*compiler.ordinary, name);
			param_count := 0;
			variadic := false;
			for decl.(*Node_Decl).declarators {
				if it.declarator_type == Node_Function_Declarator {
					param_count = it.(*Node_Function_Declarator).params.count;
					variadic = it.(*Node_Function_Declarator).variadic;
				}
			}
			variadic_stack_register := compiler.register;
			vararg_offset := 0;
			for call.args {
				compile_expr(compiler, it);
				if it_index >= param_count {
					emit(compiler, "str x%, [sp, #%]", compiler.register, vararg_offset - compiler.variadic_stack_size);
					// NOTE(Oliver): always 8 byte aligned
					vararg_offset += 8;
				} else {
					if it.resolved_type && it.resolved_type.size_in_bytes == 8 {
						emit(compiler, "mov x%, x%", it_index, compiler.register);
					} else {
						emit(compiler, "mov w%, w%", it_index, compiler.register);
					}
				}
			}
			assert(call.id.expr_type == Node_Identifier);
			if variadic {
				emit(compiler, "sub sp, sp, #%", compiler.variadic_stack_size);
			}
			emit(compiler, "bl _%", name);
			emit(compiler, "mov w%, w0", compiler.register);
			if variadic {
				emit(compiler, "add sp, sp, #%", compiler.variadic_stack_size);
			}
		case Node_String;
			ok, count := table_find(*compiler.strings, expr.(*Node_String).token.view);
			assert(ok);
			if count == 0 {
				emit(compiler, "adrp x%, l_.str@PAGE", compiler.register);
				emit(compiler, "add x%, x%, l_.str@PAGEOFF", compiler.register, compiler.register);
			} else {
				emit(compiler, "adrp x%, l_.str.%@PAGE", compiler.register, count);
				emit(compiler, "add x%, x%, l_.str.%@PAGEOFF", compiler.register, compiler.register, count);
			}
		case Node_Identifier;
			load_variable_into_register(compiler, expr.(*Node_Identifier).id.view);
	}
}

compile_statement :: (compiler: *Compiler, stmt: *Node_Statement) {
	if !stmt return;
	if stmt.statement_type == {
		case Node_Block;
			push_scope(compiler);
			for stmt.(*Node_Block).statements {
				compile_statement(compiler, it);
			}
			pop_scope(compiler);
		case Node_Return;
			compile_expr(compiler, stmt.(*Node_Return).expr);
			emit(compiler, "mov x0, x%", compiler.register);
		case Node_Expr_Statement;
			compile_expr(compiler, stmt.(*Node_Expr_Statement).expr);
		case Node_Decl_Statement;
			decl := stmt.(*Node_Decl_Statement).decl;
			for decl.declarators {
				name := identifier_from_declarator(it);
				// FIXME(Oliver): Enums won't work yet
				stack_slot: Stack_Slot;
				if it.resolved_type {
					stack_slot = push_decl(compiler, name, it.resolved_type.size_in_bytes, it);
				}
				if it.init {
					if it.init.initializer_type == Node_Scalar_Initializer {
						compile_expr(compiler, it.init.(*Node_Scalar_Initializer).expr);
						emit(compiler, "str x%, [sp, #%]", compiler.register, stack_slot.offset);
					}
				}
			}
	}
}

function_declarator :: (declarator: *Node_Declarator) -> *Node_Function_Declarator {
	result := declarator;
	while result && result.declarator_type != Node_Function_Declarator {
		result = result.inner;
	}
	assert(result.declarator_type == Node_Function_Declarator);
	return result.(*Node_Function_Declarator);
}

compile_decl :: (compiler: *Compiler, decl: *Node_Decl) {
	if !decl return;
	for decl.declarators {
		name := identifier_from_declarator(it);
		// FIXME(Oliver): Enums won't work yet
		if it.resolved_type {
			print("DECL %: %\n", name, decl.*);
			push_decl(compiler, name, it.resolved_type.size_in_bytes, it);
		}
		if it.init {
			if it.init.initializer_type == Node_Scalar_Initializer {
				compile_expr(compiler, it.init.(*Node_Scalar_Initializer).expr);
				emit(compiler, "str x%, [sp, #%]", compiler.register, compiler.stack_offset);
			}
		}
	}
}

stack_space_needed_for_variables :: (block: *Node_Statement) -> int {
	if !block return 0;
	assert(block.statement_type == Node_Block);
	stack_size := 0;
	for block.(*Node_Block).statements {
		// FIXME(Oliver): Why is this happening????????
		if !it break;
		if it.statement_type == Node_Block {
			stack_size = max(stack_size, stack_space_needed_for_variables(it));
		} else if it.statement_type == Node_Decl_Statement {
			decl := it.(*Node_Decl_Statement).decl;
			for declarator: decl.declarators {
				if declarator.resolved_type {
					stack_size += declarator.resolved_type.size_in_bytes;
				}
			}
		}
		print("Statement Type: %\n", it.statement_type);
	}
	return stack_size;
}

stack_space_needed_for_variadic_functions :: (compiler: *Compiler, block: *Node_Statement) -> int {
	if !block return 0;
	assert(block.statement_type == Node_Block);
	stack_size := 0;
	for block.(*Node_Block).statements {
		// FIXME(Oliver): Why is this happening????????
		if !it break;
		if it.statement_type == Node_Block {
			stack_size = max(stack_size, stack_space_needed_for_variadic_functions(compiler, it));
		} else if it.statement_type == Node_Expr_Statement {
			// FIXME(Oliver): This looks ugly as fuck
			if it.(*Node_Expr_Statement).expr.expr_type == Node_Call {
				call := it.(*Node_Expr_Statement).expr.(*Node_Call);
				found, decl := table_find(*compiler.ordinary, call.id.(*Node_Identifier).id.view);
				assert(found);
				param_count := 0;
				variadic := false;
				for decl.(*Node_Decl).declarators {
					if it.declarator_type == Node_Function_Declarator {
						param_count = it.(*Node_Function_Declarator).params.count;
						variadic = it.(*Node_Function_Declarator).variadic;
					}
				}
				if variadic {
					stack_size += (call.args.count - param_count) * 8;
					print("Variadic stack size: %\n", (call.args.count - param_count) * 8);
				}
			}
		}
	}
	return stack_size;
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

is_variable_declaration :: (decl: *Node_Decl, declarator: *Node_Declarator) -> bool {
	return !is_function_declaration(declarator) && !is_typedef(decl.base);
}

compile :: (compiler: *Compiler, tu: Node_Translation_Unit) {
	emit(compiler, ".globl _main"); // Set _main to be the entry point
	emit(compiler, ".p2align 2"); // Align to 4 bytes, power of 2: 2^2
	for decl: tu.declarations {
		for declarator: decl.declarators {
			if is_function_definition(decl, declarator) {
				/*
					The intuition behind this is that return address
					and frame pointer are stored in x29 and x30 we save
					those on the stack using store pair (stp). This writes
					x29 at sp + 0 and x30 stores it at sp + 8. That occupies
					16 bytes and so we need to make sure our locals write from
					byte 16 onwards. Similarly, we want to write all variadic stuff
					in a different part of the stack frame than the locals to avoid
					overwriting anything, so we calculate these sizes separately. Both
					also need to be aligned to a multiple of 16. Likely this can be cleaned
					up in some way but for now its' fine.

				*/
				push_scope(compiler);
				compiler.stack_offset = 16;
				// NOTE(Oliver): All C symbols need underscores? what the hell?
				emit(compiler, "_%:", identifier_from_declarator(declarator));
				stack_size := stack_space_needed_for_variables(decl.body) + 16;

				function := function_declarator(declarator);
				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type {
						stack_size += it.declarators[0].resolved_type.size_in_bytes;
					}
				}
				variadic_stack_size := stack_space_needed_for_variadic_functions(compiler, decl.body);
				compiler.variadic_stack_size = variadic_stack_size;
				stack_size += variadic_stack_size;
				// We have to align the stack size to be a multiple of 16
				stack_size_p2 := (stack_size + 15) & ~15;
				emit(compiler, "sub sp, sp, #%", stack_size_p2);
				emit(compiler, "stp x29, x30, [sp]");
				emit(compiler, "add x29, sp, #0");

				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type{
						emit(compiler, "str x%, [sp, #%]", it_index, compiler.stack_offset);
						push_decl(compiler, name, it.declarators[0].resolved_type.size_in_bytes, it.declarators[0]);
					}
				}
				// FIXME(Oliver): This could be better
				compile_statement(compiler, decl.body);
				emit(compiler, "ldp x29, x30, [sp]");
				emit(compiler, "add sp, sp, #%", stack_size_p2);
				emit(compiler, "ret");
				pop_scope(compiler);
			} else if is_variable_declaration(decl, declarator) {
				if declarator.init {
					array_add(*compiler.globals, identifier_from_declarator(declarator));
				}
			}
		}
	}

	for value, key: compiler.strings {
		if value == 0 {
			emit(compiler, "l_.str:");
			emit(compiler, "	.asciz \"%\"", key);
		} else {
			emit(compiler, "l_.str.%:", value);
			emit(compiler, "	.asciz \"%\"", key);
		}
	}

	for tu.declarations {
		for declarator: it.declarators {
			if is_variable_declaration(it, declarator) { 
				name := identifier_from_declarator(declarator);
				emit(compiler, ".globl _%", name);
				init_expr: *Node_Expr;
				if declarator.init &&
					declarator.init.initializer_type == Node_Scalar_Initializer {
					init_expr = declarator.init.(*Node_Scalar_Initializer).expr;
				} else if declarator.init {
					// TODO(Oliver): handle aggregate initialzirs
					continue;
				}
				assert(declarator.resolved_type != null);
				if declarator.resolved_type.size_in_bytes == {
					case 1;
						emit(compiler, ".p2align %", 0);
						emit(compiler, "_%:", name);
						emit(compiler, ".byte %", eval_expr(init_expr));
					case 2;
						emit(compiler, ".p2align %", 1);
						emit(compiler, "_%:", name);
						emit(compiler, ".short %", eval_expr(init_expr));
					case 4;
						emit(compiler, ".p2align %", 2);
						emit(compiler, "_%:", name);
						emit(compiler, ".long %", eval_expr(init_expr));
					case 8;
						emit(compiler, ".p2align %", 3);
						emit(compiler, "_%:", name);
						emit(compiler, ".quad %", eval_expr(init_expr));
				}
			}
		}
	}

	write_entire_file("out.s", *compiler.builder);
}