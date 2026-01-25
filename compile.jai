
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
	stack_slot.resolved_type = declarator.resolved_type;
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
		emit(compiler, "ldr %, [sp, #%]", register(compiler.register, stack_slot.resolved_type), stack_slot.offset);
	}
}

emit :: (compiler: *Compiler, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	//print("%\n", to_append);
	append(*compiler.builder, to_append);
	append(*compiler.builder, "\n");
}

compile_lvalue :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Identifier;
			name := expr.(*Node_Identifier).id.view;
			found, stack_slot := find_decl_on_stack(compiler, name);
			if !found {
				for compiler.globals {
					if it == name {
						emit(compiler, "adrp x%, _%@PAGE", compiler.register, name, compiler.register);
						emit(compiler, "ldr w%, [x%, _%@PAGEOFF]", compiler.register, compiler.register, name, compiler.register, compiler.register);
						return;
					}
				}
				assert(false);
			} else {
				emit(compiler, "add x%, sp, #%", compiler.register, stack_slot.offset);
			}
		case Node_Unary;
			op := expr.(*Node_Unary).op;
			if op.type == {
				case .Asterisk;
					compile_lvalue(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x%, [x%]", compiler.register, compiler.register);
			}
	}
}

register :: (reg: int, resolved_type: *Resolved_Type) -> string {
	assert(resolved_type != null);
	if resolved_type.kind == .Integral || resolved_type.kind == .Pointer {
		if resolved_type.size_in_bytes == {
			case 8;
				return tprint("x%", reg);
			case 4; #through;
			case 2;
				return tprint("w%", reg);
		}
	} else if resolved_type.kind == .Floating {
		if resolved_type.size_in_bytes == {
			case 8;
				return tprint("d%", reg);
			case 4;
				return tprint("s%", reg);
		}
	}
	assert(false);
	return "";
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
		case Node_Assign;
			// To avoid any clobbering of the expression using the register we store
			// the lvalue in, we just evaluate the expression first then load the
			// lvalue address
			compile_expr(compiler, expr.(*Node_Assign).right);
			src := register(compiler.register, expr.(*Node_Assign).right.resolved_type);
			compiler.register += 1;
			compile_lvalue(compiler, expr.(*Node_Assign).left);
			if expr.(*Node_Assign).op.type == {
				case .Equals;
					emit(compiler, "str %, [x%]", src, compiler.register);
			}
			compiler.register -= 1;
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);

			compile_expr(compiler, array_access.offset);
			offset_register := compiler.register;
			
			compiler.register += 1;
			lvalue_register := compiler.register;
			compile_lvalue(compiler, array_access.left);

			compiler.register += 1;
			scale_register := compiler.register;
			

			bytes_per_element := array_access.resolved_type.size_in_bytes;

			emit(compiler, "mov x%, #%", scale_register, bytes_per_element);
			emit(compiler, "mul x%, x%, x%", offset_register, offset_register, scale_register);
			emit(compiler, "add x%, x%, x%", lvalue_register, lvalue_register, offset_register);

			compiler.register -= 1;
			compiler.register -= 1;
			
			emit(compiler, "ldr %, [x%]", register(compiler.register, array_access.resolved_type), lvalue_register);
		case Node_Binary;
			op := expr.(*Node_Binary).op;
			t := expr.resolved_type;
			compile_expr(compiler, expr.(*Node_Binary).left);
			dst := compiler.register;
			compiler.register += 1;
			compile_expr(compiler, expr.(*Node_Binary).right);
			// TODO(Oliver): This doesn't account for the types, fix that
			f := "";
			if t.kind == .Floating {
				f = "f";
			}
			if op.type == {
				case .Equals;
				case .Plus;
					emit(compiler, "%add %, %, %", f, register(dst, t), register(dst, t), register(compiler.register, t));
				case .Minus;
					emit(compiler, "%sub %, %, %", f, register(dst, t), register(dst, t), register(compiler.register, t));
				case .Asterisk;
					emit(compiler, "%mul %, %, %", f, register(dst, t), register(dst, t), register(compiler.register, t));
				case .ForwardSlash;
					div: string;
					if t.kind == .Integral {
						if t.unsigned {
							div = "udiv";
						} else {
							div = "sdiv";
						}
					} else if t.kind == .Floating {
						div = "fdiv";
					}
					emit(compiler, "% %, %, %", div, register(dst, t), register(dst, t), register(compiler.register, t));
			}
			compiler.register -= 1;
		case Node_Number;
			number := expr.(*Node_Number);
			t := number.resolved_type;
			reg := register(compiler.register, t);
			if t.kind == {
				case .Floating;
					if t.size_in_bytes == {
						case 8;
							emit(compiler, "fmov %, #%", reg, number.as_f64);
						case 4;
							emit(compiler, "fmov %, #%", reg, cast(float32)number.as_f64);
					}
				case .Integral;
					if t.unsigned {
						if t.size_in_bytes == {
							case 8;
								emit(compiler, "mov %, #%", reg, number.as_u64);
							case 4;
								emit(compiler, "mov %, #%", reg, cast(u32)number.as_u64);
							case 2;
								emit(compiler, "mov %, #%", reg, cast(u16)number.as_u64);
							case 1;
								emit(compiler, "mov %, #%", reg, cast(u8)number.as_u64);
						}
					} else {
						if t.size_in_bytes == {
							case 8;
								emit(compiler, "mov %, #%", reg, number.as_u64);
							case 4;
								emit(compiler, "mov %, #%", reg, cast(s32)number.as_u64);
							case 2;
								emit(compiler, "mov %, #%", reg, cast(s16)number.as_u64);
							case 1;
								emit(compiler, "mov %, #%", reg, cast(s8)number.as_u64);
						}
					}
			}
		case Node_Cast;
			cast_node := expr.(*Node_Cast);
			compile_expr(compiler, cast_node.expr);
		
			source := cast_node.expr.resolved_type;
			target := cast_node.resolved_type;

			src := register(compiler.register, source);
			dst := register(compiler.register, target);

			if source.kind == .Integral && target.kind == .Floating {
				if source.unsigned {
					emit(compiler, "ucvtf %, %", dst, src);
				} else {
					emit(compiler, "scvtf %, %", dst, src);
				}
			} else if source.kind == .Floating && target.kind == .Integral {
				if target.unsigned {
					emit(compiler, "fcvtzu %, %", dst, src);
				} else {
					emit(compiler, "fcvtzs %, %", dst, src);
				}
			} else if source.kind == .Integral && target.kind == .Integral {
				if target.size_in_bytes > source.size_in_bytes {
					if source.unsigned {
						emit(compiler, "mov %, %", dst, src);
					} else {
						emit(compiler, "sxtw %, %", dst, src);
					}
				}
			} else if source.kind == .Floating && target.kind == .Floating {
				if target.size_in_bytes > source.size_in_bytes {
					emit(compiler, "fcvt %, %", dst, src);
				}
			}
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
			reg_float := 0;
			reg_integer := 0;
			for call.args {
				compile_expr(compiler, it);
				if variadic && it_index >= param_count {
					if it.resolved_type.kind == .Floating {
						if it.resolved_type.size_in_bytes == 4 {
							emit(compiler, "fcvt d%, %", compiler.register, register(compiler.register, it.resolved_type));
						}
						emit(compiler, "str d%, [sp, #%]", compiler.register, vararg_offset);
					} else if it.resolved_type.kind == .Integral {
						emit(compiler, "str x%, [sp, #%]", compiler.register, vararg_offset);
					} else {
						assert(false);
					}
					// NOTE(Oliver): always 8 byte aligned
					vararg_offset += 8;
				} else {
					if it.resolved_type.kind == .Floating {
						emit(compiler, "fmov %, %", register(reg_float, it.resolved_type), register(compiler.register, it.resolved_type));
						reg_float += 1;
					} else if it.resolved_type.kind == .Integral || it.resolved_type.kind == .Pointer {
						emit(compiler, "mov %, %", register(reg_integer, it.resolved_type), register(compiler.register, it.resolved_type));
						reg_integer += 1;
					} else {
						assert(false);
					}
				}
			}
			assert(call.id.expr_type == Node_Identifier);
			emit(compiler, "bl _%", name);
			if call.resolved_type.kind == .Floating {
				emit(compiler, "fmov d%, d0", compiler.register);
			} else {
				emit(compiler, "mov x%, x0", compiler.register);
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

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, stack_offset: int) -> int {
	if !init return stack_offset;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		compile_expr(compiler, expr);
		emit(compiler, "str %, [sp, #%]", register(compiler.register, expr.resolved_type), stack_offset);
		return stack_offset + expr.resolved_type.size_in_bytes;
	} else {

		for init.(*Node_Designated_Initializer).designations {
			stack_offset = compile_initializer(compiler, it.expr, stack_offset);
		}
	}
	return stack_offset;
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
			t := stmt.(*Node_Return).expr.resolved_type;
			print("RETURN TYPE: %\n", t.*);
			if t.kind == .Floating {
				emit(compiler, "fmov d0, d%", compiler.register);
			} else {
				emit(compiler, "mov x0, x%", compiler.register);
			}
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
				compile_initializer(compiler, it.init, stack_slot.offset);
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
				emit(compiler, "str %, [sp, #%]", register(compiler.register, it.resolved_type), compiler.stack_offset);
			}
		}
	}
}

stack_space_needed_for_variables :: (block: *Node_Statement) -> int {
	if !block return 0;
	assert(block.statement_type == Node_Block);
	stack_size := 0;
	for block.(*Node_Block).statements {
		if it.statement_type == Node_Block {
			stack_size = max(stack_size, stack_space_needed_for_variables(it));
		} else if it.statement_type == Node_Decl_Statement {
			decl := it.(*Node_Decl_Statement).decl;
			for declarator: decl.declarators {
				if declarator.resolved_type {
					stack_size += (declarator.resolved_type.size_in_bytes + 7) & ~7;
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
				// NOTE(Oliver): All C symbols need underscores? what the hell?
				emit(compiler, "_%:", identifier_from_declarator(declarator));
				link_and_return_stack_size := 16;
				locals_stack_size := stack_space_needed_for_variables(decl.body);
				variadic_stack_size := stack_space_needed_for_variadic_functions(compiler, decl.body);

				function := function_declarator(declarator);
				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type {
						locals_stack_size += it.declarators[0].resolved_type.size_in_bytes;
					}
				}
				// We should only need to resize the final total here
				total_stack_space_needed := locals_stack_size + variadic_stack_size + link_and_return_stack_size;
				total_stack_space_needed = (total_stack_space_needed + 15) & ~15; 
				// We have to align the stack offsets and size to be a multiple of 16
				variadic_offset := 0;
				locals_offset := variadic_stack_size;
				link_and_return_offset := total_stack_space_needed - link_and_return_stack_size;
				compiler.stack_offset = locals_offset;
				emit(compiler, "sub sp, sp, #%", total_stack_space_needed);
				emit(compiler, "stp x29, x30, [sp, #%]", link_and_return_offset);
				emit(compiler, "add x29, sp, #0");

				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type.kind == .Integral {
						emit(compiler, "str x%, [sp, #%]", it_index, compiler.stack_offset);
					} else if it.declarators[0].resolved_type.kind == .Floating {
						if it.declarators[0].resolved_type.size_in_bytes == 8 {
							emit(compiler, "str d%, [sp, #%]", it_index, compiler.stack_offset);
						} else {
							emit(compiler, "str s%, [sp, #%]", it_index, compiler.stack_offset);
						}
					}
					push_decl(compiler, name, it.declarators[0].resolved_type.size_in_bytes, it.declarators[0]);
				}
				// FIXME(Oliver): This could be better
				compile_statement(compiler, decl.body);
				emit(compiler, "ldp x29, x30, [sp, #%]", link_and_return_offset);
				emit(compiler, "add sp, sp, #%", total_stack_space_needed);
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