#import "Sort";


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

	// Where intermediate values get stored on the 
	intermediate_stack_offset: int;

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
				emit(compiler, "adrp x9, _%@PAGE", name);
				emit(compiler, "ldr x9, [x%, _%@PAGEOFF]", name);
				return;
			}
		}
		// We should have found it on the stack
		// TODO(Oliver): error checking
		assert(false);
	} else {
		emit(compiler, "ldr %, [sp, #%]", register(9, stack_slot.resolved_type), stack_slot.offset);
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
		case Node_Compound;
			compound := expr.(*Node_Compound);
			
			size := (compound.resolved_type.size_in_bytes + 7) & ~7;
			literal_offset := compiler.stack_offset;
			compiler.stack_offset += size;
			
			compile_initializer(compiler, compound.init, literal_offset);
			
			emit(compiler, "add x9, sp, #%", literal_offset);
		case Node_Identifier;
			name := expr.(*Node_Identifier).id.view;
			found, stack_slot := find_decl_on_stack(compiler, name);
			if !found {
				for compiler.globals {
					if it == name {
						emit(compiler, "adrp x9, _%@PAGE", name);
						emit(compiler, "add x9, x9, _%@PAGEOFF", name);
						return;
					}
				}
				assert(false);
			} else {
				emit(compiler, "add x9, sp, #%", stack_slot.offset);
			}
		case Node_Unary;
			op := expr.(*Node_Unary).op;
			if op.type == {
				case .Asterisk;
					compile_lvalue(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x9, [x9]");
			}
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);
			
			compile_expr(compiler, array_access.index);
			offset := push_intermediate(compiler, array_access.index.resolved_type);

			compile_lvalue(compiler, array_access.left);
			pop_intermediate(compiler, array_access.index.resolved_type, offset);

			// Inner type points to the thing it's an array of, you could also divide
			// by count in the array but this also seems fine.
			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;
			
			emit(compiler, "mov x11, #%", bytes_per_element);
			emit(compiler, "mul x10, x10, x11");
			emit(compiler, "add x9, x9, x10");
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);

			compile_lvalue(compiler, member_access.left);


			left_type := member_access.left.resolved_type;
			offset := 0;
			index := 0;
			for left_type.composite.(*Node_Struct).members {
				for declarator: it.declarators {
					name := identifier_from_declarator(declarator);
					if name == member_access.right.view {
						offset = left_type.layout.members[index].offset;
						break it;
					}
					index += 1;
				}
			}

			emit(compiler, "mov x10, #%", offset);
			emit(compiler, "add x9, x9, x10");

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
	} else if resolved_type.kind == .Composite {
		return tprint("x%", reg);
	}
	assert(false);
	return "";
}

Constant :: struct {
	kind: enum { F64; U64; S64; };
	as_f64: float64;
	#overlay(as_f64) as_u64: u64;
	#overlay(as_f64) as_s64: s64;
}

operator - :: (v: Constant) -> Constant {
	result: Constant = ---;
	if v.kind == {
		case .S64; result = .{ kind = .S64, as_s64 = -v.as_s64 };
		case .U64; result = .{ kind = .U64, as_u64 = 0 - v.as_u64 };
		case .F64; result = .{ kind = .F64, as_f64 = -v.as_f64 };
	}
	return result;
}

operator + :: (v: Constant) -> Constant {
	return v;
}

operator ~ :: (v: Constant) -> Constant {
	if v.kind == {
		case .S64; return .{ kind = .S64, as_s64 = ~v.as_s64 };
		case .U64; return .{ kind = .U64, as_u64 = ~v.as_u64 };
		case; assert(false); return .{};
	}
}

operator ! :: (v: Constant) -> Constant {
	if v.kind == {
		case .S64; return .{ kind = .S64, as_s64 = (v.as_s64 == 0).(s64) };
		case .U64; return .{ kind = .U64, as_u64 = (v.as_u64 == 0).(u64) };
		case .F64; return .{ kind = .S64, as_s64 = (v.as_f64 == 0).(s64) };
	}
	assert(false);
	return .{};
}

operator + :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .F64, as_f64 = to_f64(a) + to_f64(b) };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) + to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 + b.as_s64 };
	}
}

operator - :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .F64, as_f64 = to_f64(a) - to_f64(b) };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) - to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 - b.as_s64 };
	}
}

operator * :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .F64, as_f64 = to_f64(a) * to_f64(b) };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) * to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 * b.as_s64 };
	}
}

operator / :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .F64, as_f64 = to_f64(a) / to_f64(b) };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) / to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 / b.as_s64 };
	}
}

operator % :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) % to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 % b.as_s64 };
	}
}

operator << :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 {
		return .{ kind = .U64, as_u64 = a.as_u64 << to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 << to_u64(b) };
	}
}

operator >> :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 {
		return .{ kind = .U64, as_u64 = a.as_u64 >> to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 >> to_u64(b) };
	}
}

operator & :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) & to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 & b.as_s64 };
	}
}

operator | :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) | to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 | b.as_s64 };
	}
}

operator ^ :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .U64, as_u64 = to_u64(a) ^ to_u64(b) };
	} else {
		return .{ kind = .S64, as_s64 = a.as_s64 ^ b.as_s64 };
	}
}

operator == :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) == to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) == to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 == b.as_s64 then 1 else 0 };
	}
}

operator != :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) != to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) != to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 != b.as_s64 then 1 else 0 };
	}
}

operator < :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) < to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) < to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 < b.as_s64 then 1 else 0 };
	}
}

operator > :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) > to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) > to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 > b.as_s64 then 1 else 0 };
	}
}

operator <= :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) <= to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) <= to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 <= b.as_s64 then 1 else 0 };
	}
}

operator >= :: (a: Constant, b: Constant) -> Constant {
	if a.kind == .F64 || b.kind == .F64 {
		return .{ kind = .S64, as_s64 = ifx to_f64(a) >= to_f64(b) then 1 else 0 };
	} else if a.kind == .U64 || b.kind == .U64 {
		return .{ kind = .S64, as_s64 = ifx to_u64(a) >= to_u64(b) then 1 else 0 };
	} else {
		return .{ kind = .S64, as_s64 = ifx a.as_s64 >= b.as_s64 then 1 else 0 };
	}
}

to_f64 :: (v: Constant) -> float64 {
	if v.kind == {
		case .F64; return v.as_f64;
		case .S64; return cast(float64) v.as_s64;
		case .U64; return cast(float64) v.as_u64;
	}
}

to_u64 :: (v: Constant) -> u64 {
	if v.kind == {
		case .U64; return v.as_u64;
		case .S64; return cast(u64) v.as_s64;
		case .F64; return cast(u64) v.as_f64;
	}
	assert(false);
	return 0;
}

to_s64 :: (v: Constant) -> s64 {
	if v.kind == {
		case .S64; return v.as_s64;
		case .U64; return cast(s64) v.as_u64;
		case .F64; return cast(s64) v.as_f64;
	}
	assert(false);
	return 0;
}

convert_constant :: (v: Constant, target: *Resolved_Type) -> Constant {
	if target.kind == .Floating {
		return .{ kind = .F64, as_f64 = to_f64(v) };
	} else if target.unsigned {
		return .{ kind = .U64, as_u64 = to_u64(v) };
	} else {
		return .{ kind = .S64, as_s64 = to_s64(v) };
	}
}

eval_constant_expr :: (expr: *Node_Expr) -> Constant {
	if !expr return .{};
	if expr.expr_type == {
		case Node_Unary;
			unary := expr.(*Node_Unary);
			op := unary.op;
			if op.type == {
				case .Minus;
					return -eval_constant_expr(unary.expr);
				case .Plus;
					return ~eval_constant_expr(unary.expr);
				case .Bang;
					return !eval_constant_expr(unary.expr);
				case .Tilde;
					return ~eval_constant_expr(unary.expr);
			}
		case Node_Binary;
			op := expr.(*Node_Binary).op;
			left  := eval_constant_expr(expr.(*Node_Binary).left);
			right := eval_constant_expr(expr.(*Node_Binary).right);

			if op.type == {
				case .Equals;
				case .Plus;
					return left + right;
				case .Minus;
					return left - right;
				case .Asterisk;
					return left * right;
				case .ForwardSlash;
					return left / right;
			}
		case Node_Number;
			number := expr.(*Node_Number);
			if number.kind == .FLOAT  {
				return .{ kind = .F64, as_f64 = number.as_f64 };
			} else {
				return .{ kind = .U64, as_u64 = number.as_u64 };
			}
		case Node_Cast;
			c := expr.(*Node_Cast);
			return convert_constant(eval_constant_expr(c.expr), c.resolved_type);
		case Node_Char;
			value := 0;
			for expr.(*Node_Char).token.view {
				value += it;
			}
			return .{ kind = .U64, as_u64 = value.(u64) };
		case Node_Identifier;
			// TODO(Oliver): Enums
			assert(false);
	}
	return .{};
}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Compound;
			compile_lvalue(compiler, expr);
		case Node_Unary;
			op := expr.(*Node_Unary).op;
			if op.type == {
				case .Asterisk;
					compile_expr(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x9, [x9]");
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
					emit(compiler, "add x9, sp, #%", stack_slot.offset);
			}
		case Node_Assign;
			// To avoid any clobbering of the expression using the register we store
			// the lvalue in, we just evaluate the expression first then load the
			// lvalue address
			assign := expr.(*Node_Assign);
			if assign.right.resolved_type.kind == .Composite {

				compile_lvalue(compiler, assign.right);
				offset := push_intermediate(compiler, assign.right.resolved_type);
				

				compile_lvalue(compiler, assign.left);
				pop_intermediate(compiler, assign.right.resolved_type, offset);

				emit(compiler, "mov x0, x9");
				emit(compiler, "mov x1, x10");
				emit(compiler, "mov x2, #%", assign.right.resolved_type.size_in_bytes);
				emit(compiler, "bl _memcpy");
			} else {
				compile_expr(compiler, assign.right);
				offset := push_intermediate(compiler, assign.right.resolved_type);
				
				compile_lvalue(compiler, assign.left);
				pop_intermediate(compiler, assign.right.resolved_type, offset);
				if expr.(*Node_Assign).op.type == {
					case .Equals;
						emit(compiler, "str %, [x9]", register(10, assign.right.resolved_type));
				}
			}
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			compile_lvalue(compiler, member_access);
			emit(compiler, "ldr %, [x9]", register(9, member_access.resolved_type));
		case Node_Array_Access; 
			array_access := expr.(*Node_Array_Access);

			compile_expr(compiler, array_access.index);
			offset := push_intermediate(compiler, array_access.index.resolved_type);

			compile_lvalue(compiler, array_access.left);
			pop_intermediate(compiler, array_access.index.resolved_type, offset);
			
			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;

			emit(compiler, "mov x11, #%", bytes_per_element);
			emit(compiler, "mul x10, x10, x11");
			emit(compiler, "add x9, x9, x10");
			
			emit(compiler, "ldr %, [x9]", register(9, array_access.left.resolved_type.inner));
		case Node_Binary;
			binary := expr.(*Node_Binary);
			op := expr.(*Node_Binary).op;
			t := expr.resolved_type;
			compile_expr(compiler, binary.left);
			offset := push_intermediate(compiler, binary.left.resolved_type);

			compile_expr(compiler, binary.right);
			pop_intermediate(compiler, binary.left.resolved_type, offset);

			f := "";
			if t.kind == .Floating {
				f = "f";
			}
			if op.type == {
				case .Equals;
				case .Plus;
					emit(compiler, "%add %, %, %", f, register(9, t), register(10, t), register(9, t));
				case .Minus;
					emit(compiler, "%sub %, %, %", f, register(9, t), register(10, t), register(9, t));
				case .Asterisk;
					emit(compiler, "%mul %, %, %", f, register(9, t), register(10, t), register(9, t));
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
					emit(compiler, "% %, %, %", div, register(9, t), register(10, t), register(9, t));
			}
		case Node_Number;
			number := expr.(*Node_Number);
			t := number.resolved_type;
			reg := register(9, t);
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

			src := register(9, source);
			dst := register(9, target);

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
				if target.size_in_bytes != source.size_in_bytes {
					emit(compiler, "fcvt %, %", dst, src);
				}
			}
		case Node_Char;
			value := 0;
			for expr.(*Node_Char).token.view {
				value += it;
			}
			emit(compiler, "mov w%, #%", 9, value);
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			_, decl := table_find(*compiler.ordinary, name);
			function := function_declarator(decl.(*Node_Decl).declarators[0]);
			param_count := function.params.count;
			variadic := function.variadic;

			arg_offsets: [..]int;
			arg_sizes: [..]int;
			for call.args {
				if it.resolved_type.kind == .Composite {
					if it.expr_type == Node_Call {
						compile_expr(compiler, it);
					} else {
						compile_lvalue(compiler, it);
					}
					size := (it.resolved_type.size_in_bytes + 7) & ~7;
					offset := compiler.intermediate_stack_offset;
					compiler.intermediate_stack_offset += size;
					emit(compiler, "add x0, sp, #%", offset);
					emit(compiler, "mov x1, x9");
					emit(compiler, "mov x2, #%", it.resolved_type.size_in_bytes);
					emit(compiler, "bl _memcpy");
					array_add(*arg_offsets, offset);
					array_add(*arg_sizes, size);
				} else {
					compile_expr(compiler, it);
					offset := push_intermediate(compiler, it.resolved_type);
					array_add(*arg_offsets, offset);
					array_add(*arg_sizes, 8);
				}
			}
			
			vararg_offset := 0;
			reg_float := 0;
			reg_integer := 0;
			for call.args {
				offset := arg_offsets[it_index];
				
				if variadic && it_index >= param_count {
					if it.resolved_type.kind == .Floating {
						if it.resolved_type.size_in_bytes == 4 {
							emit(compiler, "ldr s10, [sp, #%]", offset);
							emit(compiler, "fcvt d10, s10");
						} else {
							emit(compiler, "ldr d10, [sp, #%]", offset);
						}
						emit(compiler, "str d10, [sp, #%]", vararg_offset);
					} else {
						emit(compiler, "ldr x10, [sp, #%]", offset);
						emit(compiler, "str x10, [sp, #%]", vararg_offset);
					}
					vararg_offset += 8;
				} else {
					if it.resolved_type.kind == .Composite {
						_struct := it.resolved_type.composite.(*Node_Struct);
						hfa, count, size := is_hfa(_struct);
						if hfa {
							if size == 4 {
								for 0..count-1 {
									emit(compiler, "ldr s%, [sp, #%]", reg_float, offset + it*4);
									reg_float += 1;
								}
							} else {
								for 0..count-1 {
									emit(compiler, "ldr d%, [sp, #%]", reg_float, offset + it*8);
									reg_float += 1;
								}
							}
						} else {
							compile_lvalue(compiler, it);
							emit(compiler, "mov x%, x9", reg_integer);
							reg_integer += 1;
						}
					} else if it.resolved_type.kind == .Floating {
						emit(compiler, "ldr %, [sp, #%]", register(reg_float, it.resolved_type), offset);
						reg_float += 1;
					} else {
						emit(compiler, "ldr %, [sp, #%]", register(reg_integer, it.resolved_type), offset);
						reg_integer += 1;
					}
				}
			}
			
			for arg_sizes {
				compiler.intermediate_stack_offset -= it;
			}

			emit(compiler, "bl _%", name);
			
			if call.resolved_type.kind == .Floating {
				emit(compiler, "fmov %, %", register(9, call.resolved_type), register(0, call.resolved_type));
			} else if call.resolved_type.kind == .Integral || call.resolved_type.kind == .Pointer {
				emit(compiler, "mov %, %", register(9, call.resolved_type), register(0, call.resolved_type));
			} else {
				_struct := call.resolved_type.composite.(*Node_Struct);
				hfa, count, size := is_hfa(_struct);
				ret_offset := compiler.intermediate_stack_offset;
				compiler.intermediate_stack_offset += call.resolved_type.size_in_bytes;
				if hfa {
					if size == 4 {
						for 0..count-1 {
							emit(compiler, "str s%, [sp, #%]", it, ret_offset + it*4);
						}
					} else {
						for 0..count-1 {
							emit(compiler, "str d%, [sp, #%]", it, ret_offset + it * 8);
						}
					}
				}
				emit(compiler, "add x9, sp, #%", ret_offset);
			}
		case Node_String;
			ok, count := table_find(*compiler.strings, expr.(*Node_String).token.view);
			assert(ok);
			if count == 0 {
				emit(compiler, "adrp x9, l_.str@PAGE");
				emit(compiler, "add x9, x9, l_.str@PAGEOFF");
			} else {
				emit(compiler, "adrp x9, l_.str.%@PAGE", count);
				emit(compiler, "add x9, x9, l_.str.%@PAGEOFF", count);
			}
		case Node_Identifier;
			load_variable_into_register(compiler, expr.(*Node_Identifier).id.view);
	}
}

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, cursor: int) -> int {
	if !init return cursor;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		if expr.resolved_type.kind == .Composite {
			compile_expr(compiler, expr);
			emit(compiler, "add x0, sp, #%", cursor);
			emit(compiler, "mov x1, x9");
			emit(compiler, "mov x2, #%", expr.resolved_type.size_in_bytes);
			emit(compiler, "bl _memcpy");
		} else {
			compile_expr(compiler, expr);
			emit(compiler, "str %, [sp, #%]", register(9, expr.resolved_type), cursor);
		}
		return cursor + expr.resolved_type.size_in_bytes;
	}

	base := cursor;
	for init.(*Node_Designated_Initializer).designations {
		cursor = base + it.byte_offset;
		cursor = compile_initializer(compiler, it.expr, cursor);
	}
	return cursor;
}

flatten_struct_member_types :: (_struct: *Node_Struct) -> [..]*Resolved_Type {
	
	result: [..]*Resolved_Type;
	flatten_struct_member_types :: (_struct: *Node_Struct, members: *[..]*Resolved_Type) {
		for _struct.members {
			for it.declarators {
				array_add(members, it.resolved_type);
			}
		}
	}

	flatten_struct_member_types(_struct, *result);
	return result;
}

is_hfa :: (_struct: *Node_Struct) -> bool, count: int, size: int {
	member_types := flatten_struct_member_types(_struct);
	if member_types.count > 4 return false, 0, 0;
	if member_types[0].kind != .Floating return false, 0, 0;
	size := member_types[0].size_in_bytes;
	for member_types {
		if it.kind != .Floating return false, 0, 0;
		if it.size_in_bytes != size return false, 0, 0;
	}
	return true, member_types.count, size;
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
			assert(t != null);
			print("RETURN TYPE: %\n", t.*);
			if t.kind == .Floating {
				emit(compiler, "fmov d0, d%", 9);
			} else if t.kind == .Integral || t.kind == .Pointer {
				emit(compiler, "mov x0, x%", 9);
			} else if t.kind == .Composite {
				_struct := t.composite.(*Node_Struct);
				hfa, count, size := is_hfa(_struct);
				if hfa {
					if size == 4 {
						for 0..count-1 {
							emit(compiler, "ldr s%, [x9, #%]", it, it*4);
						}
					} else {
						for 0..count-1 {
							emit(compiler, "ldr d%, [x9, #%]", it, it * 8);
						}
					}
				}
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
				emit(compiler, "str %, [sp, #%]", register(9, it.resolved_type), compiler.stack_offset);
			}
		}
	}
}

push_intermediate :: (compiler: *Compiler, resolved_type: *Resolved_Type) -> int {
	offset := compiler.intermediate_stack_offset;
	emit(compiler, "str %, [sp, #%]", register(9, resolved_type), offset);
	compiler.intermediate_stack_offset += 8;
	return offset;
}

pop_intermediate :: (compiler: *Compiler, resolved_type: *Resolved_Type, offset: int) {
	emit(compiler, "ldr %, [sp, #%]", register(10, resolved_type), offset);
	compiler.intermediate_stack_offset -= 8;
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
		} else if it.statement_type == Node_Expr_Statement {
			expr_stmt := it.(*Node_Expr_Statement);
			if expr_stmt.expr.expr_type == Node_Compound {
				compound := expr_stmt.expr.(*Node_Compound);
				stack_size += (compound.resolved_type.size_in_bytes + 7) & ~7;
			} else if expr_stmt.expr.expr_type == Node_Call {
				call := expr_stmt.expr.(*Node_Call);
				stack_size += (call.resolved_type.size_in_bytes + 7) & ~7;
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
				function := function_declarator(decl.(*Node_Decl).declarators[0]);
				param_count = function.params.count;
				variadic = function.variadic;
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
				name := identifier_from_declarator(declarator);
				emit(compiler, "_%:", name);
				link_and_return_stack_size := 16;
				locals_stack_size := stack_space_needed_for_variables(decl.body);
				variadic_stack_size := stack_space_needed_for_variadic_functions(compiler, decl.body);
				// HACK(Oliver): If you need more than this you got some brain damage
				temporaries_stack_size := 128;

				function := function_declarator(declarator);
				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type {
						locals_stack_size += it.declarators[0].resolved_type.size_in_bytes;
					}
				}
				// We should only need to resize the final total here
				total_stack_space_needed := locals_stack_size + variadic_stack_size + link_and_return_stack_size + temporaries_stack_size;
				total_stack_space_needed = (total_stack_space_needed + 15) & ~15; 
				// We have to align the stack offsets and size to be a multiple of 16
				variadic_offset := 0;
				locals_offset := variadic_stack_size;
				link_and_return_offset := total_stack_space_needed - link_and_return_stack_size;
				compiler.stack_offset = locals_offset;
				compiler.intermediate_stack_offset = locals_offset + locals_stack_size;
				emit(compiler, "sub sp, sp, #%", total_stack_space_needed);
				emit(compiler, "stp x29, x30, [sp, #%]", link_and_return_offset);
				emit(compiler, "add x29, sp, #0");

				reg_float := 0;
				reg_integer := 0;
				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					if it.declarators[0].resolved_type.kind == .Composite {
						type_struct := it.declarators[0].resolved_type;
						_struct := type_struct.composite.(*Node_Struct);
						hfa, count, size := is_hfa(_struct);
						if hfa {
							if size == 4 {
								for 0..count-1 {
									emit(compiler, "str s%, [sp, #%]", reg_float, compiler.stack_offset + it*4);
									reg_float += 1;
								}
							} else {
								for 0..count-1 {
									emit(compiler, "str d%, [sp, #%]", reg_float, compiler.stack_offset + it*8);
									reg_float += 1;
								}
							}
						} else if type_struct.size_in_bytes >= 16 {
							if reg_integer < 2 {
								emit(compiler, "mov x12, x0");
								emit(compiler, "mov x13, x1");
							}
							emit(compiler, "mov x1, x%", reg_integer);
							emit(compiler, "mov x0, sp");
							emit(compiler, "add x0, x0, #%", compiler.stack_offset);
							emit(compiler, "mov x2, #%", type_struct.size_in_bytes);
							emit(compiler, "bl _memcpy");
							if reg_integer < 2 {
								emit(compiler, "mov x0, x12");
								emit(compiler, "mov x1, x13");
							}
							reg_integer += 1;
						}
					} else if it.declarators[0].resolved_type.kind == .Integral ||
					   it.declarators[0].resolved_type.kind == .Pointer {
						emit(compiler, "str x%, [sp, #%]", reg_integer, compiler.stack_offset);
						reg_integer += 1;
					} else if it.declarators[0].resolved_type.kind == .Floating {
						if it.declarators[0].resolved_type.size_in_bytes == 8 {
							emit(compiler, "str d%, [sp, #%]", reg_float, compiler.stack_offset);
						} else {
							emit(compiler, "str s%, [sp, #%]", reg_float, compiler.stack_offset);
						}
						reg_float += 1;
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

	compile_global_initializer :: (compiler: *Compiler, init: *Node_Initializer, bytes: []u8, cursor := 0) -> int {
		if !init return cursor;

		if init.initializer_type == Node_Scalar_Initializer {
			expr := init.(*Node_Scalar_Initializer).expr;
			value := eval_constant_expr(expr);
			size_in_bytes := expr.resolved_type.size_in_bytes;
			if expr.resolved_type.kind == .Floating {

				if expr.resolved_type.size_in_bytes == {
					case 4;
						to_write: u32;
						value_as_f32 := value.as_f64.(float32);
						memcpy(*to_write, *value_as_f32, 4);
						while size_in_bytes > 0 {
							bytes[cursor] = (to_write & 255).(u8);
							size_in_bytes -= 1;
							cursor += 1;
							to_write = to_write >> 8;
						}
					case 8;
						to_write: u64;
						memcpy(*to_write, *value.as_f64, 8);
						while size_in_bytes > 0 {
							bytes[cursor] = (to_write & 255).(u8);
							size_in_bytes -= 1;
							cursor += 1;
							to_write = to_write >> 8;
						}
				}
			} else if expr.resolved_type.kind == .Integral ||
					  expr.resolved_type.kind == .Pointer {
					to_write := value.as_u64;
					while size_in_bytes > 0 {
						bytes[cursor] = (to_write & 255).(u8);
						size_in_bytes -= 1;
						to_write = to_write >> 8;
						cursor += 1;
					}
			}
			//cursor += expr.resolved_type.size_in_bytes/8;
			return cursor;
		} else {
			for init.(*Node_Designated_Initializer).designations {
				cursor = it.byte_offset;
				cursor = compile_global_initializer(compiler, it.expr, bytes, cursor);
			}
		}
		return cursor;
	}

	for tu.declarations {
		for declarator: it.declarators {
			if is_variable_declaration(it, declarator) { 
				name := identifier_from_declarator(declarator);
				emit(compiler, ".globl _%", name);
				init_expr: *Node_Expr;
				if declarator.init {
					emit(compiler, "_%:", name);
					if declarator.init.initializer_type == Node_Scalar_Initializer {
						init_expr = declarator.init.(*Node_Scalar_Initializer).expr;
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
					} else {
						bytes := NewArray(declarator.resolved_type.size_in_bytes, u8);
						compile_global_initializer(compiler, declarator.init, bytes, 0);
						for bytes {
							emit(compiler, ".byte %", it);
						}
					}
				}
			}
		}
	}

	write_entire_file("out.s", *compiler.builder);
}