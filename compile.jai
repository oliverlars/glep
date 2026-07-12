#load "ir.jai";

Compiler :: struct {
	ir: IR;
	strings: Table(string, int);
	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, int);
	typedefs: Table(string, *Node_Decl);

	register: int;
	registers_needed: int;

	scopes: [..]Scope_Frame;

	current_function: *IR_Function;

	trace_functions: [..]string;

	switch_variable: IR_Operand;

	// Stack of break/continue targets for nested loops & switches.
	// continue_label is "" for frames that don't carry one (switch).
	label_stack: [..]Label_Frame;

	label_counter: int;
}

Binding :: struct {
	name: string;
	slot: IR_Operand;
	resolved_type: *Resolved_Type;
	is_function: bool;
}

Label_Frame :: struct {
	break_label:    string;
	continue_label: string;
}

push_label_frame :: (compiler: *Compiler, break_label: string, continue_label: string) {
	array_add(*compiler.label_stack, Label_Frame.{ break_label, continue_label });
}

pop_label_frame :: (compiler: *Compiler) {
	assert(compiler.label_stack.count > 0);
	compiler.label_stack.count -= 1;
}

current_break_label :: (compiler: *Compiler) -> string {
	assert(compiler.label_stack.count > 0, "break outside of loop or switch");
	return compiler.label_stack[compiler.label_stack.count - 1].break_label;
}

current_continue_label :: (compiler: *Compiler) -> string {
	// Walks down the stack so `continue` inside a switch jumps to the
	// enclosing loop's continue target, skipping the switch.
	for < compiler.label_stack {
		if it.continue_label return it.continue_label;
	}
	assert(false, "continue outside of loop");
	return "";
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

find_binding :: (compiler: *Compiler, name: string) -> Binding, bool {
	is_global := 0;
	for < scope: compiler.scopes {
		for < scope.bindings {
			if it.name == name return it, it_index == 0;
		}
	}
	// Fallback: function names referenced as values (e.g. &foo) live in
	// compiler.ordinary, not in scope bindings. Treat them as label-bound.
	found, decl := table_find(*compiler.ordinary, name);
	if found {
		fn_decl := decl.(*Node_Decl);
		if fn_decl.declarators.count > 0 {
			binding: Binding;
			binding.name = name;
			binding.slot = ir_label_operand(name);
			binding.resolved_type = fn_decl.declarators[0].resolved_type;
			binding.is_function = is_function_declaration(fn_decl.declarators[0]);
			return binding, true;
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
		return .{ .Float, resolved_type.size_in_bytes, false, false };
	} else {
		return .{ .Integer, resolved_type.size_in_bytes, resolved_type.unsigned, resolved_type.inner != null };
	}
}

types_equal :: (a: IR_Operand_Type, b: IR_Operand_Type) -> bool {
	return a.kind == b.kind &&
		   a.size_in_bytes == b.size_in_bytes &&
		   a.unsigned == b.unsigned;
}

is_void_type :: (type: *Resolved_Type) -> bool {
	return type && type.memoryless && type.size_in_bytes == 0;
}

is_comparison_token :: (type: Token_Type) -> bool {
	return type == .Less || type == .Greater ||
		   type == .LessEqual || type == .GreaterEqual ||
		   type == .EqualEqual || type == .BangEqual;
}

common_operand_type :: (a: IR_Operand_Type, b: IR_Operand_Type) -> IR_Operand_Type {
	if types_equal(a, b) return a;
	if a.pointer return a;
	if b.pointer return b;
	if a.kind == .Float || b.kind == .Float {
		if a.kind == .Float && b.kind == .Float {
			if a.size_in_bytes >= b.size_in_bytes return a;
			return b;
		}
		if a.kind == .Float return a;
		return b;
	}
	result := a;
	if b.size_in_bytes > a.size_in_bytes result = b;
	result.unsigned = a.unsigned || b.unsigned;
	return result;
}

next_register :: (compiler: *Compiler) -> int {
	next := compiler.register;
	compiler.register += 1;
	compiler.registers_needed = max(compiler.registers_needed, compiler.register);
	return next;
}

offset_from_member_name :: (_struct: *Node_Struct, layout: Struct_Layout, name: string) -> int {
	if !_struct then return -1;
	offset := -1;
	index := 0;
	for _struct.members {
		for declarator: it.declarators {
			member_name := identifier_from_declarator(declarator);
			if member_name == "" && declarator.resolved_type.composite {
				inner_offset := offset_from_member_name(xx declarator.resolved_type.composite, declarator.resolved_type.layout, name);
				if inner_offset >= 0 {
					offset = layout.members[index].offset;
					return offset + inner_offset;
				}
			}
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

			// compile_expr handles both cases:
			//   array → Copy (alloca address IS the base pointer)
			//   pointer → Load (loads the pointer value from the alloca)
			array := compile_expr(compiler, array_access.left);

			if !types_equal(index.type, IR_U64) {
				converted := ir_register(next_register(compiler), IR_U64);
				ir_emit(function, ir_cast(converted, index));
				index = converted;
			}

			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;
			stride := ir_register(next_register(compiler), index.type);
			ir_emit(function, ir_mul(stride, index, ir_constant(xx bytes_per_element, IR_U64)));
			ir_emit(function, ir_add(dst, array, stride));
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

			compile_initializer(compiler, compound.init, operand_type(compound.resolved_type), dst);
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
			assert(false, "Compile LValue case not implemented: %", expr.expr_type);
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
				case .Plus;
					value := compile_expr(compiler, unary.expr);
					result = value;
				case .Bang;
					value := compile_expr(compiler, unary.expr);
					dst := ir_register(next_register(compiler), value.type);
					ir_emit(function, ir_eq(dst, value, ir_constant(0, value.type)));
					result = dst;
				case .Tilde;
					value := compile_expr(compiler, unary.expr);
					dst := ir_register(next_register(compiler), value.type);
					ir_emit(function, ir_bit_not(dst, value));
					result = dst;
				case .Ampersand;
					address := compile_lvalue(compiler, unary.expr);
					dst := ir_register(next_register(compiler), address.type);
					ir_emit(function, ir_copy(dst, address));
					result = dst;
				case .Asterisk;
					value := compile_expr(compiler, unary.expr);
					if unary.expr.resolved_type.inner.kind != .Array {
						dst := ir_register(next_register(compiler), operand_type(unary.expr.resolved_type.inner));
						ir_emit(function, ir_load(dst, value));
						result = dst;
					} else {
						result = value;
					}
				case .PlusPlus;
					address := compile_lvalue(compiler, unary.expr);
					pre := ir_register(next_register(compiler), operand_type(unary.expr.resolved_type));
					ir_emit(function, ir_load(pre, address));

					offset := 1;
					if unary.expr.resolved_type.kind == .Pointer {
						offset = unary.expr.resolved_type.inner.size_in_bytes;
					} else if unary.expr.resolved_type.kind == .Array {
						offset = unary.expr.resolved_type.inner.size_in_bytes / unary.expr.resolved_type.inner.array_count;
					}

					post := ir_register(next_register(compiler), pre.type);
					ir_emit(function, ir_add(post, pre, ir_constant(xx offset, pre.type)));
					ir_emit(function, ir_store(address, post));

					if unary.postfix {
						result = pre;
					} else {
						result = post;
					}
				case .MinusMinus;
					address := compile_lvalue(compiler, unary.expr);
					pre := ir_register(next_register(compiler), operand_type(unary.expr.resolved_type));
					ir_emit(function, ir_load(pre, address));

					offset := 1;
					if unary.expr.resolved_type.kind == .Pointer {
						offset = unary.expr.resolved_type.inner.size_in_bytes;
					} else if unary.expr.resolved_type.kind == .Array {
						offset = unary.expr.resolved_type.inner.size_in_bytes / unary.expr.resolved_type.inner.array_count;
					}

					post := ir_register(next_register(compiler), pre.type);
					ir_emit(function, ir_sub(post, pre, ir_constant(xx offset, pre.type)));
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
			dst := ir_constant(xx sizeof.target_type.size_in_bytes, IR_U64);
			result = dst;
		case Node_Alignof_Type;
			alignof := expr.(*Node_Alignof_Type);
			dst := ir_constant(xx alignof.target_type.alignment, IR_U64);
			result = dst;
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			dst := ir_constant(xx sizeof.expr.resolved_type.size_in_bytes, IR_U64);
			result = dst;
			case Node_Binary;
				binary := expr.(*Node_Binary);

				left_type := binary.left.resolved_type;
				right_type := binary.right.resolved_type;

				if binary.op.type == .Comma {
					compile_expr(compiler, binary.left);
					result = compile_expr(compiler, binary.right);
					return result;
				}

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
				operand_target_type := dst.type;
				if is_comparison_token(binary.op.type) {
					right_type := operand_type(binary.right.resolved_type);
					operand_target_type = common_operand_type(left.type, right_type);
				}
				if !types_equal(operand_target_type, left.type) {
					converted := ir_register(next_register(compiler), operand_target_type);
					ir_emit(function, ir_cast(converted, left));
					left = converted;
				}
				right := compile_expr(compiler, binary.right);
				if is_comparison_token(binary.op.type) {
					operand_target_type = common_operand_type(left.type, right.type);
				}
				if !types_equal(operand_target_type, right.type) {
					converted := ir_register(next_register(compiler), operand_target_type);
					ir_emit(function, ir_cast(converted, right));
					right = converted;
				}
				assert(types_equal(left.type, right.type));
				if binary.op.type == {
					case .Plus;
						if (left_type.kind == .Pointer || left_type.kind == .Array) && (right_type.kind != .Pointer && right_type.kind != .Array) {
							pointer := ir_register(next_register(compiler), IR_PTR);
							size_of_pointee := left_type.inner.size_in_bytes;
							ir_emit(function, ir_mul(pointer, right, ir_constant(xx size_of_pointee, IR_PTR)));
							right = pointer;
						} else if (right_type.kind == .Pointer || right_type.kind == .Array) && (left_type.kind != .Pointer && left_type.kind != .Array) {
							pointer := ir_register(next_register(compiler), IR_PTR);
							size_of_pointee := right_type.inner.size_in_bytes;
							ir_emit(function, ir_mul(pointer, left, ir_constant(xx size_of_pointee, IR_PTR)));
							left = pointer;
						}
						ir_emit(function, ir_add(dst, left, right));
					case .Minus;
						if (left_type.kind == .Pointer || left_type.kind == .Array) && (right_type.kind != .Pointer && right_type.kind != .Array) {
							scaled := ir_register(next_register(compiler), IR_PTR);
							size_of_pointee := left_type.inner.size_in_bytes;
							ir_emit(function, ir_mul(scaled, right, ir_constant(xx size_of_pointee, IR_PTR)));
							right = scaled;
						}
						ir_emit(function, ir_sub(dst, left, right));
						if left_type.kind == .Pointer && right_type.kind == .Pointer {
							scaled_dst := ir_register(next_register(compiler), IR_PTR);
							size_of_pointee := left_type.inner.size_in_bytes;
							ir_emit(function, ir_div(scaled_dst, dst, ir_constant(xx size_of_pointee, IR_PTR)));
							dst = scaled_dst;
						}
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
			found_enum, enum_value := table_find(*compiler.enums, id.id.view);
			if found_enum {
				type := ifx expr.resolved_type then operand_type(expr.resolved_type) else IR_S32;
				result = ir_constant(enum_value.(u64), type);
				return result;
			}
			binding := find_binding(compiler, id.id.view);
			address := binding.slot;
			if binding.slot.kind == .Label {
				address = ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(address, binding.slot));
			}
			// Function names: the address IS the value (function pointer).
			// Don't dereference — that would read the first 8 bytes of the
			// function body as a "pointer".
			if binding.is_function {
				result = address;
				return result;
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
			if member_access.resolved_type.kind == .Composite ||
			   member_access.resolved_type.kind == .Array {
				result = address;
			} else {
				dst := ir_register(next_register(compiler), operand_type(expr.resolved_type));
				ir_emit(function, ir_load(dst, address));
				result = dst;
			}
		case Node_Array_Access;
			address := compile_lvalue(compiler, expr);
			line := expr.line;
			col := expr.col;
			if expr.resolved_type.kind == .Composite || expr.resolved_type.kind == .Array {
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
				dst := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(dst, ir_label_operand(label)));
				result = dst;
			case Node_Ternary;
				ternary := expr.(*Node_Ternary);
				on_false := next_label(compiler);
				end := next_label(compiler);

				is_void := is_void_type(ternary.resolved_type);
				dst: IR_Operand;
				if !is_void {
					dst = ir_register(next_register(compiler), operand_type(ternary.resolved_type));
				}

				cond := compile_expr(compiler, ternary.cond);
				ir_emit(function, ir_ifz(cond, on_false));
				expr_true := compile_expr(compiler, ternary.on_true);
				if !is_void ir_emit(function, ir_copy(dst, expr_true));
				ir_emit(function, ir_goto(end));
				ir_emit(function, ir_label(on_false));
				expr_false := compile_expr(compiler, ternary.on_false);
				if !is_void ir_emit(function, ir_copy(dst, expr_false));
				ir_emit(function, ir_label(end));
				result = dst;
		case Node_Call;
			call := expr.(*Node_Call);

			if call.builtin_kind != .NONE {
				if call.builtin_kind == {
					case .CLZ;
						value_type := operand_type(call.args[0].resolved_type.inner);
						value      := compile_expr(compiler, call.args[0]);
						dst        := ir_register(next_register(compiler), value_type);
						ir_emit(function, ir_clz(dst, value));
						result = dst;
					case .CTZ;
						value_type := operand_type(call.args[0].resolved_type);
						value      := compile_expr(compiler, call.args[0]);
						dst        := ir_register(next_register(compiler), value_type);
						ir_emit(function, ir_ctz(dst, value));
						result = dst;
					case .ATOMIC_LOAD;
						value_type := operand_type(call.args[0].resolved_type);
						ptr        := compile_expr(compiler, call.args[0]);
						order      := constant_to_int(eval_constant_expr(*compiler.enums, call.args[1]));
						dst        := ir_register(next_register(compiler), value_type);
						ir_emit(function, ir_memory_order(order));
						ir_emit(function, ir_atomic_load(dst, ptr));
						result = dst;
					case .ATOMIC_STORE;
						value_type := operand_type(call.args[0].resolved_type.inner);
						ptr        := compile_expr(compiler, call.args[0]);
						val        := compile_expr(compiler, call.args[1]);
						if !types_equal(value_type, val.type) {
							converted := ir_register(next_register(compiler), value_type);
							ir_emit(function, ir_cast(converted, val));
							val = converted;
						}
						order := constant_to_int(eval_constant_expr(*compiler.enums, call.args[2]));
						ir_emit(function, ir_memory_order(order));
						ir_emit(function, ir_atomic_store(ptr, val));
					case .ATOMIC_FETCH_ADD;
						value_type := operand_type(call.args[0].resolved_type.inner);
						ptr        := compile_expr(compiler, call.args[0]);
						val        := compile_expr(compiler, call.args[1]);
						if !types_equal(value_type, val.type) {
							converted := ir_register(next_register(compiler), value_type);
							ir_emit(function, ir_cast(converted, val));
							val = converted;
						}
						order := constant_to_int(eval_constant_expr(*compiler.enums, call.args[2]));
						dst   := ir_register(next_register(compiler), value_type);
						ir_emit(function, ir_memory_order(order));
						ir_emit(function, ir_atomic_fetch_add(dst, ptr, val));
						result = dst;
					case .VA_START;
						ap_addr := compile_lvalue(compiler, call.args[0]);
						last    := compile_expr(compiler, call.args[1]);
						ir_emit(function, ir_va_start(ap_addr, last));
					case .VA_END;
						ap_addr := compile_lvalue(compiler, call.args[0]);
						ir_emit(function, ir_va_end(ap_addr));
					case .VA_COPY;
						dst_addr := compile_lvalue(compiler, call.args[0]);
						src_addr := compile_lvalue(compiler, call.args[1]);
						ir_emit(function, ir_va_copy(dst_addr, src_addr));
				}
				return result;
			}

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
			
			is_indirect := true;
			name: string;
			if call.id.expr_type == Node_Identifier {
				name = call.id.(*Node_Identifier).id.view;
				binding, _ := find_binding(compiler, name);
				if binding.is_function then is_indirect = false;
			}

			source_param_count: int;
			lhs: IR_Operand;
			if is_indirect {
				function_type := call.id.resolved_type;
				if function_type.kind == .Pointer then function_type = function_type.inner;
				source_param_count = function_type.params.count;
				lhs = compile_expr(compiler, call.id);
			} else {
				_, decl := table_find(*compiler.ordinary, name);
				source_function := function_declarator(decl.(*Node_Decl).declarators[0]);
				source_param_count = source_function.params.count;
			}

			args: [..] IR_Operand;
			non_variadic_expanded_param_count := 0;
			variadic: bool;
			for call.args {
				variadic = it_index >= source_param_count;
				if is_void_type(it.resolved_type) {
					compile_expr(compiler, it);
				} else if it.resolved_type.kind == .Composite {
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
				if is_indirect {
					ir_emit(function, ir_call(ret_slot, lhs, xx non_variadic_expanded_param_count));
				} else {
					ir_emit(function, ir_call(ret_slot, name, xx non_variadic_expanded_param_count));
				}

				for args {
					ir_emit(function, ir_param(it));
				}

				addr := ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_address(addr, ret_slot));
				result = addr;
			} else {
				dst: IR_Operand;
				if !is_void_type(call.resolved_type) {
					dst = ir_register(next_register(compiler), operand_type(call.resolved_type));
				}
				if is_indirect {
					ir_emit(function, ir_call(dst, lhs, xx non_variadic_expanded_param_count));
				} else {
					ir_emit(function, ir_call(dst, name, xx non_variadic_expanded_param_count));
				}

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
				value_type := operand_type(assign.left.resolved_type);
				if !types_equal(value_type, rhs.type) {
					converted := ir_register(next_register(compiler), value_type);
					ir_emit(function, ir_cast(converted, rhs));
					rhs = converted;
				}
				if assign.op.type != .Equals {
					left_type := assign.left.resolved_type;
					right_type := assign.right.resolved_type;
					op := ir_register(next_register(compiler), value_type);
					value := compile_expr(compiler, assign.left);
					if assign.op.type == {
						case .PlusEqual;
							if (left_type.kind == .Pointer || left_type.kind == .Array) && (right_type.kind != .Pointer && right_type.kind != .Array) {
								pointer := ir_register(next_register(compiler), IR_PTR);
								size_of_pointee := left_type.inner.size_in_bytes;
								ir_emit(function, ir_mul(pointer, rhs, ir_constant(xx size_of_pointee, IR_PTR)));
								rhs = pointer;
							} else if (right_type.kind == .Pointer || right_type.kind == .Array) && (left_type.kind != .Pointer && left_type.kind != .Array) {
								pointer := ir_register(next_register(compiler), IR_PTR);
								size_of_pointee := right_type.inner.size_in_bytes;
								ir_emit(function, ir_mul(pointer, lhs, ir_constant(xx size_of_pointee, IR_PTR)));
								lhs = pointer;
							}
							ir_emit(function, ir_add(op, value, rhs));
						case .MinusEqual;
							if (left_type.kind == .Pointer || left_type.kind == .Array) && (right_type.kind != .Pointer && right_type.kind != .Array) {
								pointer := ir_register(next_register(compiler), IR_PTR);
								size_of_pointee := left_type.inner.size_in_bytes;
								ir_emit(function, ir_mul(pointer, rhs, ir_constant(xx size_of_pointee, IR_PTR)));
								rhs = pointer;
							} else if (right_type.kind == .Pointer || right_type.kind == .Array) && (left_type.kind != .Pointer && left_type.kind != .Array) {
								pointer := ir_register(next_register(compiler), IR_PTR);
								size_of_pointee := right_type.inner.size_in_bytes;
								ir_emit(function, ir_mul(pointer, lhs, ir_constant(xx size_of_pointee, IR_PTR)));
								lhs = pointer;
							}
							ir_emit(function, ir_sub(op, value, rhs));
						case .AsteriskEqual;
							ir_emit(function, ir_mul(op, value, rhs));
						case .ForwardSlashEqual;
							ir_emit(function, ir_div(op, value, rhs));
						case .LessLessEqual;
							ir_emit(function, ir_shl(op, value, rhs));
						case .GreaterGreaterEqual;
							ir_emit(function, ir_shr(op, value, rhs));
						case .AmpersandEqual;
							ir_emit(function, ir_and(op, value, rhs));
						case .PipeEqual;
							ir_emit(function, ir_or(op, value, rhs));
						case .CaretEqual;
							ir_emit(function, ir_xor(op, value, rhs));
						case .PercentEqual;
							ir_emit(function, ir_mod(op, value, rhs));
					}
					rhs = op;
				}
				ir_emit(function, ir_store(lhs, rhs));
				result = rhs;
			}
			if assign.right.resolved_type.kind == .Composite {
				result = lhs;
			}
		case Node_Number;
			number := expr.(*Node_Number);
			type := operand_type(number.resolved_type);
			if number.kind == .FLOAT {
				value: u64;
				if number.resolved_type.size_in_bytes == 4 {
					as_f32 := number.as_f64.(float32);
					print("NUMBER: %\n", as_f32);
					memcpy(*value, *as_f32, 4);
				} else {
					memcpy(*value, *number.as_f64, 8);
				}
				result = ir_constant(value, type);
			} else {
				result = ir_constant(number.as_u64, type);
			}
		case Node_Cast;
			_cast := expr.(*Node_Cast);
			line := _cast.line;
			col := _cast.col;
			if is_void_type(_cast.resolved_type) {
				compile_expr(compiler, _cast.expr);
				return .{};
			}
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

should_trace :: (compiler: *Compiler, name: string) -> bool {
	for compiler.trace_functions if it == name return true;
	return false;
}

trace_format_for :: (rt: *Resolved_Type) -> string {
	if !rt return "";
	if rt.kind == .Pointer return "%p";
	if rt.kind == .Integral {
		if rt.size_in_bytes == 8 return ifx rt.unsigned then "%llu" else "%lld";
		return ifx rt.unsigned then "%u" else "%d";
	}
	return "";
}

emit_trace :: (compiler: *Compiler, binding: Binding) {
	fmt := trace_format_for(binding.resolved_type);
	if fmt == "" return;
	function := compiler.current_function;
	full_fmt := tprint("[%] % = %\\n", function.name, binding.name, fmt);
	found, count := table_find(*compiler.strings, full_fmt);
	if !found {
		count = compiler.strings.count;
		table_set(*compiler.strings, full_fmt, count);
	}
	str_addr := ir_register(next_register(compiler), IR_PTR);
	ir_emit(function, ir_address(str_addr, ir_label_operand(tprint("str%", count))));
	val := ir_register(next_register(compiler), operand_type(binding.resolved_type));
	ir_emit(function, ir_load(val, binding.slot));
	ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "printf", 2));
	ir_emit(function, ir_param(str_addr));
	ir_emit(function, ir_param(val));
}

compile_declarator :: (compiler: *Compiler, declarator: *Node_Declarator) -> Binding {
	function := compiler.current_function;
	name := identifier_from_declarator(declarator);

	slot := ir_register(next_register(compiler), IR_PTR);
	ir_emit(function, ir_alloca(slot, xx declarator.resolved_type.size_in_bytes));
	binding := bind_decl(compiler, name, slot, declarator.resolved_type);
	size := (declarator.resolved_type.size_in_bytes + 7) & ~7;
	ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memset", 3));
	ir_emit(function, ir_param(slot));
	ir_emit(function, ir_param(ir_constant(0, IR_S64)));
	ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));
	compile_initializer(compiler, declarator.init, operand_type(declarator.resolved_type), slot);
	return binding;
}

compile_statement :: (compiler: *Compiler, statement: *Node_Statement) {
	if !statement return;
	function := compiler.current_function;
	ir_emit(function, ir_debug_label(tprint("LINE: %", statement.line)));
	if statement.statement_type == {
		case Node_Decl_Statement;
			decl := statement.(*Node_Decl_Statement).decl;
			for decl.declarators {
				name := identifier_from_declarator(it);
				compile_declarator(compiler, it);
			}
			case Node_Expr_Statement;
				compile_expr(compiler, statement.(*Node_Expr_Statement).expr);
			case Node_Return;
				return_expr := statement.(*Node_Return).expr;
				if return_expr {
					ir_emit(function, ir_return(compile_expr(compiler, return_expr)));
				} else {
					ir_emit(function, ir_return(.{}));
				}
		case Node_For;
			_for := statement.(*Node_For);
			start := next_label(compiler);
			end := next_label(compiler);
			cont := next_label(compiler);

			ir_emit(function, "for init");
			compile_statement(compiler, _for.init);
			ir_emit(function, ir_label(start));
			ir_emit(function, "for cond");
			if _for.cond {
				cond := compile_expr(compiler, _for.cond);
				ir_emit(function, ir_ifz(cond, end));
			}
			ir_emit(function, "for body");
			push_label_frame(compiler, end, cont);
			compile_statement(compiler, _for.body);
			pop_label_frame(compiler);
			ir_emit(function, ir_label(cont));
			compile_expr(compiler, _for.expr);
			ir_emit(function, ir_goto(start));
			ir_emit(function, "for end");
			ir_emit(function, ir_label(end));
		case Node_While;
			_while := statement.(*Node_While);
			start := next_label(compiler);
			end := next_label(compiler);
			cont := next_label(compiler);

			ir_emit(function, ir_label(start));
			cond := compile_expr(compiler, _while.cond);
			ir_emit(function, ir_ifz(cond, end));
			push_label_frame(compiler, end, end);
			compile_statement(compiler, _while.body);
			pop_label_frame(compiler);
			ir_emit(function, ir_goto(start));
			ir_emit(function, ir_label(end));
		case Node_Do;
			_do := statement.(*Node_Do);
			start := next_label(compiler);
			end   := next_label(compiler);
			cont  := next_label(compiler);

			ir_emit(function, ir_label(start));
			push_label_frame(compiler, end, cont);
			compile_statement(compiler, _do.body);
			pop_label_frame(compiler);
			ir_emit(function, ir_label(cont));
			cond := compile_expr(compiler, _do.cond);
			ir_emit(function, ir_if(cond, start));
			ir_emit(function, ir_label(end));
		case Node_Switch;
			switch := statement.(*Node_Switch);
			end_label := next_label(compiler);
			switch_value := compile_expr(compiler, switch.expr);
			compiler.switch_variable = switch_value;

			Switch_Body_Entry :: struct {
				is_case:   bool;
				case_node: *Node_Case;
				statement: *Node_Statement;
				label:     string;
			}
			body_entries: [..]Switch_Body_Entry;

			// Flatten the switch body: a Node_Case's body might be another
			// Node_Case (stacked cases) or a real statement. We walk through
			// blocks and case chains to produce a flat sequence so dispatch
			// and emission can both index it linearly.
			flatten_switch_body :: (statement: *Node_Statement, entries: *[..]Switch_Body_Entry) {
				if !statement return;
				if statement.statement_type == Node_Block {
					for statement.(*Node_Block).statements {
						flatten_switch_body(it, entries);
					}
				} else if statement.statement_type == Node_Case {
					case_node := statement.(*Node_Case);
					array_add(entries, Switch_Body_Entry.{ is_case = true, case_node = case_node });
					flatten_switch_body(case_node.statement, entries);
				} else {
					array_add(entries, Switch_Body_Entry.{ is_case = false, statement = statement });
				}
			}
			flatten_switch_body(switch.body, *body_entries);

			// Allocate a label per case. Default's label is what we jump to
			// when no case matches; without a default, we fall through to end.
			default_label := end_label;
			for * body_entries {
				if !it.is_case continue;
				it.label = next_label(compiler);
				if it.case_node.is_default then default_label = it.label;
			}

			// Dispatch: emit a comparison and conditional jump for each
			// non-default case, in source order.
			for body_entries {
				if !it.is_case || it.case_node.is_default continue;
				comparison := ir_register(next_register(compiler), switch_value.type);
				case_expr  := compile_expr(compiler, it.case_node.expr);
				ir_emit(function, ir_eq(comparison, switch_value, case_expr));
				ir_emit(function, ir_if(comparison, it.label));
			}
			ir_emit(function, ir_goto(default_label));

			// Bodies in source order, with natural fall-through between cases.
			push_label_frame(compiler, end_label, "");
			for body_entries {
				if it.is_case {
					ir_emit(function, ir_label(it.label));
				} else {
					compile_statement(compiler, it.statement);
				}
			}
			pop_label_frame(compiler);
			ir_emit(function, ir_label(end_label));
		case Node_Case;
		case Node_Continue;
			ir_emit(function, ir_goto(current_continue_label(compiler)));
		case Node_Break;
			ir_emit(function, ir_goto(current_break_label(compiler)));
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

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, lhs_type: IR_Operand_Type, dst: IR_Operand) {
	if !init return;
	function := compiler.current_function;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		rhs := compile_expr(compiler, expr);
		if expr.resolved_type.kind == .Composite || expr.resolved_type.kind == .Array {
			size := expr.resolved_type.size_in_bytes;
			ir_emit(function, ir_call(ir_register(next_register(compiler), IR_S32), "memcpy", 3));
			ir_emit(function, ir_param(dst));
			ir_emit(function, ir_param(rhs));
			ir_emit(function, ir_param(ir_constant(xx size, IR_S64)));

		} else {
			if !types_equal(lhs_type, rhs.type) {
				converted := ir_register(next_register(compiler), lhs_type);
				ir_emit(function, ir_cast(converted, rhs));
				rhs = converted;
			}
			ir_emit(function, ir_store(dst, rhs));
		}
	} else {
		for init.(*Node_Designated_Initializer).designations {
			member_address := dst;
			if it.byte_offset != 0 {
				member_address = ir_register(next_register(compiler), IR_PTR);
				ir_emit(function, ir_add(member_address, dst, ir_constant(xx it.byte_offset, IR_U64)));
			}
			
			compile_initializer(compiler, it.expr, operand_type(it.target_resolved_type), member_address);
		}
	}
}

compile_global_initializer :: (compiler: *Compiler, init: *Node_Initializer, target_type: *Resolved_Type) -> []u8, []IR_Relocation {
	if !init return {}, {};
	compile_global_initializer :: (compiler: *Compiler, init: *Node_Initializer, target_type: *Resolved_Type, bytes: []u8, relocations: *[..]IR_Relocation, byte_offset := 0) -> int {
		if !init return byte_offset;
		function := compiler.current_function;
		if init.initializer_type == Node_Scalar_Initializer {
			expr := init.(*Node_Scalar_Initializer).expr;
			if expr.expr_type == Node_String && target_type.kind == .Array {
				str := expr.(*Node_String);
				str_bytes := process_string_escapes(str.token.view);
				copy_count := min(str_bytes.count, target_type.size_in_bytes);
				memcpy(bytes.data + byte_offset, str_bytes.data, copy_count);
				return byte_offset + target_type.size_in_bytes;
			}
			value := convert_constant(eval_constant_expr(*compiler.enums, expr, *compiler.ordinary), target_type);
			if value.symbol != "" {
				print("FOUND RELOCATION: %\n", value.symbol);
				array_add(relocations, .{value.symbol, value.as_s64, byte_offset});
			} else if target_type.kind == .Floating {
				if target_type.size_in_bytes == 4 {
					f32_val := cast(float32) value.as_f64;
					memcpy(bytes.data + byte_offset, *f32_val, 4);
				} else {
					memcpy(bytes.data + byte_offset, *value.as_f64, 8);
				}
			} else {
				memcpy(bytes.data + byte_offset, *value.as_u64, target_type.size_in_bytes);
			}
			return byte_offset + target_type.size_in_bytes;
		} else {
			for init.(*Node_Designated_Initializer).designations {
				compile_global_initializer(compiler, it.expr, it.target_resolved_type, bytes, relocations, byte_offset + it.byte_offset);
			}
		}
		return byte_offset;
	}
	bytes := NewArray(target_type.size_in_bytes, u8);
	relocations: [..]IR_Relocation;
	compile_global_initializer(compiler, init, target_type, bytes, *relocations);
	if relocations.count == 1 {
		a := 5;
	}
	return bytes, relocations;
}


is_struct_composite :: (type: *Resolved_Type) -> bool {
	return type.kind == .Composite && type.composite.type == Node_Struct;
}

append_struct_params :: (_struct: *Node_Struct, layout: Struct_Layout, params: *[..]IR_Operand_Type) {
	index := 0;
	for _struct.members {
		for declarator: it.declarators {
			member_type := declarator.resolved_type;
			if !member_type then continue;
			if is_struct_composite(member_type) {
				inner_struct := cast(*Node_Struct) member_type.composite;
				append_struct_params(inner_struct, member_type.layout, params);
			} else {
				array_add(params, operand_type(member_type));
			}
			index += 1;
		}
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
				ir_function.variadic = function.variadic;
				linkage: IR_Linkage;
				if decl.storage_class == "static" {
					linkage = .INTERNAL;
				}
				ir_function.linkage = linkage;
				compiler.register = 0;
				compiler.registers_needed = 0;
				compiler.current_function = *ir_function;

				emit_struct_load_params :: (compiler: *Compiler, function: *IR_Function, _struct: *Node_Struct, layout: Struct_Layout, base: IR_Operand, param_index: int) -> int {
					index := 0;
					for _struct.members {
						for declarator: it.declarators {
							member_type := declarator.resolved_type;
							if !member_type { index += 1; continue; }
							offset := layout.members[index].offset;

							if is_struct_composite(member_type) {
								inner_struct := cast(*Node_Struct) member_type.composite;
								member_base := ir_register(next_register(compiler), IR_PTR);
								ir_emit(function, ir_add(member_base, base, ir_constant(xx offset, IR_U64)));
								param_index = emit_struct_load_params(compiler, function, inner_struct, member_type.layout, member_base, param_index);
							} else {
								dst := ir_register(next_register(compiler), operand_type(member_type));
								ir_emit(function, ir_load_param(dst, ir_constant(xx param_index, IR_U64)));
								address := ir_register(next_register(compiler), IR_PTR);
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
					param_bindings: [..]Binding;
					for function.params {
						if it.declarators.count == 0 then continue;
						param_type := it.declarators[0].resolved_type;
						if !param_type then continue;
						if is_void_type(param_type) then continue;
						binding := compile_declarator(compiler, it.declarators[0]);
						array_add(*param_bindings, binding);
						if is_struct_composite(param_type) {
							_struct := cast(*Node_Struct) param_type.composite;
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

					if should_trace(compiler, ir_function.name) {
						for param_bindings emit_trace(compiler, it);
					}

					ret_type := declarator.resolved_type.ret;
					if is_void_type(ret_type) {
						// No result values for void functions.
					} else if ret_type.kind == .Composite {
						if is_struct_composite(ret_type) {
							ret_struct := cast(*Node_Struct) ret_type.composite;
							append_struct_params(ret_struct, ret_type.layout, *ir_function.results);
						} else {
							array_add(*ir_function.results, operand_type(ret_type));
						}
				} else {
					array_add(*ir_function.results, operand_type(ret_type));
				}

				compile_statement(compiler, decl.body);
				ir_function.registers_needed = compiler.registers_needed;
				array_add(*compiler.ir.functions, ir_function);
			} else if is_variable_declaration(decl, declarator) {
				bind_decl(compiler, name, ir_label_operand(name), declarator.resolved_type);
				if decl.storage_class == "extern" {
					already := false;
					for compiler.ir.extern_vars {
						if it == name { already = true; break; }
					}
					if !already array_add(*compiler.ir.extern_vars, name);
				} else {

					if identifier_from_declarator(declarator) == "Data" {
						a := 5;
					}
					bytes, relocations := compile_global_initializer(compiler, declarator.init, declarator.resolved_type);

					existing := -1;
					for * compiler.ir.globals {
						if it.name == name { existing = it_index; break; }
					}
					if existing >= 0 {
						if declarator.init != null {
							g := *compiler.ir.globals[existing];
							g.bytes = bytes;
							g.relocations = relocations;
						}
					} else {
						ir_emit_global(*compiler.ir, name, bytes, relocations, declarator.resolved_type.alignment, declarator.resolved_type.size_in_bytes);
					}
				}
			} else if declarator.resolved_type.kind == .Function {
					external: IR_External;
					external.name = name;

					function := function_declarator(declarator);
					for function.params {
						if it.declarators.count == 0 then continue;
						param_type := it.declarators[0].resolved_type;
						if !param_type then continue;
						if is_void_type(param_type) then continue;
						if is_struct_composite(param_type) {
							ext_struct := cast(*Node_Struct) param_type.composite;
							append_struct_params(ext_struct, param_type.layout, *external.params);
						} else {
							array_add(*external.params, operand_type(param_type));
						}
					}
					external.variadic = function.variadic;

					ret_type := declarator.resolved_type.ret;
					if is_void_type(ret_type) {
						// No result values for void externs.
					} else if is_struct_composite(ret_type) {
						ext_ret_struct := cast(*Node_Struct) ret_type.composite;
						append_struct_params(ext_ret_struct, ret_type.layout, *external.results);
					} else if ret_type.kind != .Composite {
						array_add(*external.results, operand_type(ret_type));
					}

				array_add(*compiler.ir.externals, external);
			}
		}
	}
	pop_scope(compiler);

	for value, key: compiler.strings {
		terminated_bytes := process_string_escapes(key);
		ir_emit_global(*compiler.ir, tprint("str%", value), terminated_bytes, .{}, 1, terminated_bytes.count);
	}
	
}
