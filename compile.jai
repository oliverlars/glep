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
	max_stack_offset: int;

	variadic_stack_size: int;

	label_for_count: int;
	label_if_count: int;

	indent_level: int;
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
	if compiler.stack_offset > compiler.max_stack_offset  compiler.max_stack_offset = compiler.stack_offset;
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
	for 0..compiler.indent_level-1  append(*compiler.builder, "    ");
	append(*compiler.builder, to_append);
	append(*compiler.builder, "\n");
}

emit_comment :: (compiler: *Compiler, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	for 0..compiler.indent_level-1  append(*compiler.builder, "    ");
	append(*compiler.builder, "; ");
	append(*compiler.builder, to_append);
	append(*compiler.builder, "\n");
}

emit_label :: (compiler: *Compiler, fmt: string, args: ..Any) {
	to_append := tprint(fmt, ..args);
	append(*compiler.builder, to_append);
	append(*compiler.builder, ":\n");
	compiler.indent_level += 1;
}

emit_label_end :: (compiler: *Compiler) {
	if compiler.indent_level > 0  compiler.indent_level -= 1;
}

emit_blank_line :: (compiler: *Compiler) {
	append(*compiler.builder, "\n");
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

compile_lvalue :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Compound;
			compound := expr.(*Node_Compound);
			emit_comment(compiler, "lvalue: compound literal (% bytes)", compound.resolved_type.size_in_bytes);

			size := (compound.resolved_type.size_in_bytes + 7) & ~7;
			literal_offset := compiler.stack_offset;
			compiler.stack_offset += size;
			if compiler.stack_offset > compiler.max_stack_offset  compiler.max_stack_offset = compiler.stack_offset;


			// Zero initialise!
			emit_comment(compiler, "zero-init compound at sp+%", literal_offset);
			emit(compiler, "add x0, sp, #%", literal_offset);
			emit_mov_imm_integer(compiler, 0, 1, 8);
			emit_mov_imm_integer(compiler, xx compound.resolved_type.size_in_bytes, 2, 8);
			emit(compiler, "bl _memset");

			compile_initializer(compiler, compound.init, literal_offset);

			emit_comment(compiler, "result addr of compound -> x9");
			emit(compiler, "add x9, sp, #%", literal_offset);
		case Node_Identifier;
			name := expr.(*Node_Identifier).id.view;
			found, stack_slot := find_decl_on_stack(compiler, name);
			if !found {
				for compiler.globals {
					if it == name {
						emit_comment(compiler, "lvalue: global '%'", name);
						emit(compiler, "adrp x9, _%@PAGE", name);
						emit(compiler, "add x9, x9, _%@PAGEOFF", name);
						return;
					}
				}
				assert(false);
			} else {
				emit_comment(compiler, "lvalue: local '%' at sp+%", name, stack_slot.offset);
				emit(compiler, "add x9, sp, #%", stack_slot.offset);
			}
		case Node_Unary;
			op := expr.(*Node_Unary).op;
			if op.type == {
				case .Asterisk;
					emit_comment(compiler, "lvalue: deref *");
					compile_lvalue(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x9, [x9]");
			}
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);
			emit_comment(compiler, "lvalue: array access");

			compile_expr(compiler, array_access.index);
			offset := push_intermediate(compiler, array_access.index.resolved_type);

			compile_lvalue(compiler, array_access.left);
			if array_access.left.resolved_type.kind == .Pointer {
				emit(compiler, "ldr x9, [x9]");
			}
			pop_intermediate(compiler, array_access.index.resolved_type, offset);

			// Inner type points to the thing it's an array of, you could also divide
			// by count in the array but this also seems fine.
			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;

			emit_comment(compiler, "element size = %", bytes_per_element);
			emit_mov_imm_integer(compiler, xx bytes_per_element, 11, 8);
			emit(compiler, "mul x10, x10, x11");
			emit(compiler, "add x9, x9, x10");
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			emit_comment(compiler, "lvalue: member access .%", member_access.right.view);

			compile_lvalue(compiler, member_access.left);
			if member_access.left.resolved_type.kind == .Pointer {
				emit(compiler, "ldr x9, [x9]");
			}


			left_type := member_access.left.resolved_type;
			if left_type.composite == null {
				left_type = left_type.inner;
			}

			offset := offset_from_member_name(xx left_type.composite, left_type.layout, member_access.right.view);

			emit_comment(compiler, "member offset = %", offset);
			emit_mov_imm_integer(compiler, xx offset, 10, 8);
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
	} else if resolved_type.kind == .Array {
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

emit_mov_imm :: (compiler: *Compiler, imm: u64, reg: int, rt: *Resolved_Type) {
	if rt.kind == .Floating {
		emit_mov_imm_integer(compiler, imm, reg, 8);
		if rt.size_in_bytes == 8 {
			emit(compiler, "fmov d%, x%", reg, reg);
		} else {
			emit(compiler, "fmov s%, w%", reg, reg);
		}
	} else {
		emit_mov_imm_integer(compiler, imm, reg, rt.size_in_bytes);
	}
}

emit_mov_imm_integer :: (compiler: *Compiler, imm: u64, reg: int, size_in_bytes: int) {
	if size_in_bytes <= 4 {
		lo := imm & 0xFFFF;
		hi := (imm >> 16) & 0xFFFF;
		emit(compiler, "movz w%, #%", reg, lo);
		emit(compiler, "movk w%, #%, lsl #16", reg, hi);
	} else {
		emit(compiler, "movz x%, #%, lsl #0",  reg, imm & 0xFFFF);
		emit(compiler, "movk x%, #%, lsl #16", reg, (imm >> 16) & 0xFFFF);
		emit(compiler, "movk x%, #%, lsl #32", reg, (imm >> 32) & 0xFFFF);
		emit(compiler, "movk x%, #%, lsl #48", reg, (imm >> 48) & 0xFFFF);
	}
}

emit_load :: (compiler: *Compiler, rt: *Resolved_Type) {
	if rt.kind == .Floating {
		if rt.size_in_bytes == 4 {
			emit(compiler, "ldr s9, [x9]");
		} else {
			emit(compiler, "ldr d9, [x9]");
		}
	} else if rt.kind == .Integral || rt.kind == .Pointer {
		if rt.size_in_bytes == 1 {
			emit(compiler, "ldrb w9, [x9]");
		} else if rt.size_in_bytes == 2 {
			emit(compiler, "ldrh w9, [x9]");
		} else if rt.size_in_bytes == 4 {
			emit(compiler, "ldr w9, [x9]");
		} else {
			emit(compiler, "ldr x9, [x9]");
		}
	}
}

emit_store :: (compiler: *Compiler, rt: *Resolved_Type) {
	if rt.kind == .Floating {
		if rt.size_in_bytes == 4 {
			emit(compiler, "str s10, [x9]");
		} else {
			emit(compiler, "str d10, [x9]");
		}
	} else if rt.kind == .Integral || rt.kind == .Pointer {
		if rt.size_in_bytes == 1 {
			emit(compiler, "strb w10, [x9]");
		} else if rt.size_in_bytes == 2 {
			emit(compiler, "strh w10, [x9]");
		} else if rt.size_in_bytes == 4 {
			emit(compiler, "str w10, [x9]");
		} else {
			emit(compiler, "str x10, [x9]");
		}
	}
}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Sizeof_Type;
			sizeof := expr.(*Node_Sizeof_Type);
			emit_comment(compiler, "expr: sizeof(type) = %", sizeof.target_type.size_in_bytes);
			emit_mov_imm_integer(compiler, xx sizeof.target_type.size_in_bytes, 9, 8);
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			emit_comment(compiler, "expr: sizeof(expr) = %", sizeof.expr.resolved_type.size_in_bytes);
			emit_mov_imm_integer(compiler, xx sizeof.expr.resolved_type.size_in_bytes, 9, 8);
		case Node_Compound;
			compile_lvalue(compiler, expr);
		case Node_Ternary;
			emit_blank_line(compiler);
			emit_comment(compiler, "stmt: if");
			ternary := expr.(*Node_Ternary);
			count := compiler.label_if_count;
			compiler.label_if_count += 1;
			push_scope(compiler);
			compile_expr(compiler, ternary.cond);
			emit(compiler, "cbz %, _IF_ON_FALSE%", register(9, ternary.cond.resolved_type), count);
			compile_expr(compiler, ternary.on_true);
			emit(compiler, "b _IF_END%", count);
			emit(compiler, "_IF_ON_FALSE%:", count);
			compile_expr(compiler, ternary.on_false);
			pop_scope(compiler);
			emit(compiler, "_IF_END%:", count);
		case Node_Unary;
			unary := expr.(*Node_Unary);
			op := unary.op;
			if op.type == {
				case .Asterisk;
					emit_comment(compiler, "expr: deref *");
					compile_expr(compiler, expr.(*Node_Unary).expr);
					emit(compiler, "ldr x9, [x9]");
				case .Ampersand;
					emit_comment(compiler, "expr: addr-of &");
					compile_lvalue(compiler, expr.(*Node_Unary).expr);
				case .Bang;
					emit_comment(compiler, "expr: negate");
					unary := expr.(*Node_Unary);
					compile_expr(compiler, unary.expr);
					emit(compiler, "cmp %, #0", register(9, unary.expr.resolved_type));
					emit(compiler, "cset %, eq", register(9, unary.expr.resolved_type));
				case .Minus;
					compile_expr(compiler, unary.expr);
					emit(compiler, "neg %, %", register(9, unary.expr.resolved_type), register(9, unary.expr.resolved_type));
				case .PlusPlus;
					if unary.postfix {
						compile_lvalue(compiler, unary.expr);
						emit(compiler, "mov x10, x9");
						emit(compiler, "ldr %, [x10]", register(9, unary.expr.resolved_type));
						emit(compiler, "add %, %, #1", register(11, unary.expr.resolved_type), register(9, unary.expr.resolved_type));
						emit(compiler, "str %, [x10]", register(11, unary.expr.resolved_type));
					} else {
						compile_lvalue(compiler, unary.expr);
						emit(compiler, "mov x10, x9");
						emit(compiler, "ldr %, [x10]", register(9, unary.expr.resolved_type));
						emit(compiler, "add %, %, #1", register(9, unary.expr.resolved_type), register(9, unary.expr.resolved_type));
						emit(compiler, "str %, [x10]", register(9, unary.expr.resolved_type));
					}

			}
		case Node_Assign;
			// To avoid any clobbering of the expression using the register we store
			// the lvalue in, we just evaluate the expression first then load the
			// lvalue address
			assign := expr.(*Node_Assign);
			emit_comment(compiler, "expr: assign (op: %)", assign.op.view);
			if assign.right.resolved_type.kind == .Composite {

				emit_comment(compiler, "assign: composite memcpy (% bytes)", assign.right.resolved_type.size_in_bytes);
				compile_expr(compiler, assign.right);
				offset := push_intermediate(compiler, assign.right.resolved_type);

				compile_lvalue(compiler, assign.left);
				pop_intermediate(compiler, assign.right.resolved_type, offset);

				emit(compiler, "mov x0, x9");
				emit(compiler, "mov x1, x10");
				emit_mov_imm_integer(compiler, xx assign.right.resolved_type.size_in_bytes, 2, 8);
				emit(compiler, "bl _memcpy");
			} else {
				compile_expr(compiler, assign.right);
				offset := push_intermediate(compiler, assign.right.resolved_type);

				compile_lvalue(compiler, assign.left);
				pop_intermediate(compiler, assign.right.resolved_type, offset);
				if expr.(*Node_Assign).op.type == {
					case .Equals;
						emit_comment(compiler, "assign: store to [x9]");
						emit_store(compiler, assign.right.resolved_type);
				}
			}
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			emit_comment(compiler, "expr: load member .%", member_access.right.view);
			compile_lvalue(compiler, member_access);
			if member_access.resolved_type.kind != .Composite {
				emit_load(compiler, member_access.resolved_type);
			}
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);
			emit_comment(compiler, "expr: array access");

			compile_expr(compiler, array_access.index);
			offset := push_intermediate(compiler, array_access.index.resolved_type);

			compile_expr(compiler, array_access.left);
			pop_intermediate(compiler, array_access.index.resolved_type, offset);

			bytes_per_element := array_access.left.resolved_type.inner.size_in_bytes;

			emit_comment(compiler, "element size = %", bytes_per_element);
			if array_access.index.resolved_type.size_in_bytes < 8 {
				emit(compiler, "sxtw x10, w10");
			}
			emit_mov_imm_integer(compiler, xx bytes_per_element, 11, 8);
			emit(compiler, "mul x10, x10, x11");
			emit(compiler, "add x9, x9, x10");

			if array_access.left.resolved_type.inner.kind != .Composite {
				emit_load(compiler, array_access.left.resolved_type.inner);
			}
		case Node_Binary;
			binary := expr.(*Node_Binary);
			op := expr.(*Node_Binary).op;
			t := expr.resolved_type;
			emit_comment(compiler, "expr: binary '%'", op.view);
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
				case .Less;
					cmp := ifx t.unsigned then "lo" else "lt";
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, %", register(9, t), cmp);
				case .Greater;
					cmp := ifx t.unsigned then "hi" else "gt";
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, %", register(9, t), cmp);
				case .GreaterEqual;
					cmp := ifx t.unsigned then "hs" else "ge";
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, %", register(9, t), cmp);
				case .LessEqual;
					cmp := ifx t.unsigned then "ls" else "le";
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, %", register(9, t), cmp);
				case .EqualEqual;
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, eq", register(9, t));
				case .BangEqual;
					emit(compiler, "cmp %, %", register(10, t), register(9, t));
					emit(compiler, "cset %, ne", register(9, t));
				case .Ampersand;
					emit(compiler, "and %, %, %", register(9, t), register(10, t), register(9, t));
				case .Percent;
					if t.unsigned {
						emit(compiler, "udiv %, %, %", register(11, t), register(10, t), register(9, t));
						emit(compiler, "msub %, %, %, %", register(9, t), register(11, t), register(9, t), register(10, t));
					} else {
						emit(compiler, "sdiv %, %, %", register(11, t), register(10, t), register(9, t));
						emit(compiler, "msub %, %, %, %", register(9, t), register(11, t), register(9, t), register(10, t));
					}
			}
		case Node_Number;
 			number := expr.(*Node_Number);
			t := number.resolved_type;
			value := number.as_u64;
			if number.kind == .FLOAT {
				memcpy(*value, *number.as_f64, 8);
			}
			emit_comment(compiler, "expr: number literal %", value);
			emit_mov_imm(compiler, value, 9, t);
		case Node_Cast;
			cast_node := expr.(*Node_Cast);
			emit_comment(compiler, "expr: cast (% -> %)", cast_node.expr.resolved_type.kind, cast_node.resolved_type.kind);
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
			emit_comment(compiler, "expr: char literal '%'", expr.(*Node_Char).token.view);
			emit_mov_imm_integer(compiler, xx value, 9, 4);
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			emit_comment(compiler, "expr: call %() (% args)", name, call.args.count);

			_, decl := table_find(*compiler.ordinary, name);
			function := function_declarator(decl.(*Node_Decl).declarators[0]);
			param_count := function.params.count;
			variadic := function.variadic;

			arg_offsets: [..]int;
			arg_sizes: [..]int;
			for call.args {
				emit_comment(compiler, "arg % eval", it_index);
				if it.resolved_type.kind == .Composite {
					if it.expr_type == Node_Call {
						compile_expr(compiler, it);
					} else {
						compile_lvalue(compiler, it);
					}
					size := (it.resolved_type.size_in_bytes + 7) & ~7;
					offset := compiler.stack_offset;
					compiler.stack_offset += size;
					if compiler.stack_offset > compiler.max_stack_offset  compiler.max_stack_offset = compiler.stack_offset;
					emit(compiler, "add x0, sp, #%", offset);
					emit(compiler, "mov x1, x9");
					emit_mov_imm_integer(compiler, xx it.resolved_type.size_in_bytes, 2, 8);
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

			emit_comment(compiler, "load args into registers");
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
							emit(compiler, "add x%, sp, #%", reg_integer, offset);
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
				compiler.stack_offset -= it;
			}

			emit_comment(compiler, "call %", name);
			emit(compiler, "bl _%", name);

			emit_comment(compiler, "return value from %", name);
			if call.resolved_type.kind == .Floating {
				emit(compiler, "fmov %, %", register(9, call.resolved_type), register(0, call.resolved_type));
			} else if call.resolved_type.kind == .Integral || call.resolved_type.kind == .Pointer {
				emit(compiler, "mov %, %", register(9, call.resolved_type), register(0, call.resolved_type));
			} else {
				_struct := call.resolved_type.composite.(*Node_Struct);
				hfa, count, size := is_hfa(_struct);
				ret_offset := compiler.stack_offset;
				compiler.stack_offset += call.resolved_type.size_in_bytes;
				if compiler.stack_offset > compiler.max_stack_offset  compiler.max_stack_offset = compiler.stack_offset;
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
			emit_comment(compiler, "expr: string literal");
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
			emit_comment(compiler, "expr: load '%'", expr.(*Node_Identifier).id.view);
			compile_lvalue(compiler, expr);
			if expr.resolved_type.kind != .Composite {
				emit_load(compiler, expr.resolved_type);
			}
		}
}

compile_initializer :: (compiler: *Compiler, init: *Node_Initializer, cursor: int) -> int {
	if !init return cursor;
	if init.initializer_type == Node_Scalar_Initializer {
		expr := init.(*Node_Scalar_Initializer).expr;
		if expr.resolved_type.kind == .Composite {
			emit_comment(compiler, "init: scalar composite at sp+% (% bytes)", cursor, expr.resolved_type.size_in_bytes);
			compile_expr(compiler, expr);
			emit(compiler, "add x0, sp, #%", cursor);
			emit(compiler, "mov x1, x9");
			emit_mov_imm_integer(compiler, xx expr.resolved_type.size_in_bytes, 2, 8);
			emit(compiler, "bl _memcpy");
		} else {
			emit_comment(compiler, "init: scalar store at sp+%", cursor);
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
		case Node_For;
			emit_blank_line(compiler);
			emit_comment(compiler, "stmt: for");
			_for := stmt.(*Node_For);
			count := compiler.label_for_count;
			compiler.label_for_count += 1;
			push_scope(compiler);
			compile_decl(compiler, _for.init);
			emit(compiler, "_FOR_START%:", count);
			compile_expr(compiler, _for.cond);
			emit(compiler, "cbz %, _FOR_END%", register(9, _for.cond.resolved_type), count);
			compile_statement(compiler, _for.body);
			compile_expr(compiler, _for.expr);
			pop_scope(compiler);
			emit(compiler, "b _FOR_START%", count);
			emit(compiler, "_FOR_END%:", count);
		case Node_If;
			emit_blank_line(compiler);
			emit_comment(compiler, "stmt: if");
			_if := stmt.(*Node_If);
			count := compiler.label_if_count;
			compiler.label_if_count += 1;
			push_scope(compiler);
			compile_expr(compiler, _if.cond);
			emit(compiler, "cbz %, _IF_ON_FALSE%", register(9, _if.cond.resolved_type), count);
			compile_statement(compiler, _if.on_true);
			emit(compiler, "b _IF_END%", count);
			emit(compiler, "_IF_ON_FALSE%:", count);
			compile_statement(compiler, _if.on_false);
			pop_scope(compiler);
			emit(compiler, "_IF_END%:", count);
		case Node_Block;
			for stmt.(*Node_Block).statements {
				compile_statement(compiler, it);
			}
		case Node_Return;
			emit_blank_line(compiler);
			emit_comment(compiler, "stmt: return");
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
			emit_blank_line(compiler);
			emit_comment(compiler, "stmt: expr");
			compile_expr(compiler, stmt.(*Node_Expr_Statement).expr);
		case Node_Decl_Statement;
			decl := stmt.(*Node_Decl_Statement).decl;
			emit_blank_line(compiler);
			compile_decl(compiler, decl);
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
	for decl.declarators {
		name := identifier_from_declarator(it);
		emit_comment(compiler, "decl: '%' (% bytes)", name, ifx it.resolved_type then it.resolved_type.size_in_bytes else 0);
		// FIXME(Oliver): Enums won't work yet
		stack_slot: Stack_Slot;
		if it.resolved_type {
			stack_slot = push_decl(compiler, name, it.resolved_type.size_in_bytes, it);
		}
		compile_initializer(compiler, it.init, stack_slot.offset);
	}
}

push_intermediate :: (compiler: *Compiler, resolved_type: *Resolved_Type) -> int {
	offset := compiler.stack_offset;
	emit_comment(compiler, "push intermediate -> sp+%", offset);
	emit(compiler, "str %, [sp, #%]", register(9, resolved_type), offset);
	compiler.stack_offset += 8;
	if compiler.stack_offset > compiler.max_stack_offset  compiler.max_stack_offset = compiler.stack_offset;
	return offset;
}

pop_intermediate :: (compiler: *Compiler, resolved_type: *Resolved_Type, offset: int) {
	emit_comment(compiler, "pop intermediate <- sp+%", offset);
	emit(compiler, "ldr %, [sp, #%]", register(10, resolved_type), offset);
	compiler.stack_offset -= 8;
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
				name := identifier_from_declarator(declarator);
				emit_blank_line(compiler);
				emit_comment(compiler, "======== function: %() ========", name);
				emit_label(compiler, "_%", name);

				variadic_stack_size := stack_space_needed_for_variadic_functions(compiler, decl.body);
				compiler.stack_offset = variadic_stack_size;
				compiler.max_stack_offset = variadic_stack_size;

				// Compile params and body into a separate builder.
				// We don't know the total stack size yet, that's determined
				// by how much stack_offset grows during compilation.
				saved_builder := compiler.builder;
				compiler.builder = .{};

				function := function_declarator(declarator);
				reg_float := 0;
				reg_integer := 0;
				if function.params.count > 0 {
					emit_comment(compiler, "--- params ---");
				}
				for function.params {
					name := identifier_from_declarator(it.declarators[0]);
					emit_comment(compiler, "param '%'", name);
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
							bytes_remaining := type_struct.size_in_bytes;
							copy_offset := 0;
							while bytes_remaining >= 8 {
								emit(compiler, "ldr x9, [x%, #%]", reg_integer, copy_offset);
								emit(compiler, "str x9, [sp, #%]", compiler.stack_offset + copy_offset);
								copy_offset += 8;
								bytes_remaining -= 8;
							}
							if bytes_remaining >= 4 {
								emit(compiler, "ldr w9, [x%, #%]", reg_integer, copy_offset);
								emit(compiler, "str w9, [sp, #%]", compiler.stack_offset + copy_offset);
								copy_offset += 4;
								bytes_remaining -= 4;
							}
							if bytes_remaining >= 2 {
								emit(compiler, "ldrh w9, [x%, #%]", reg_integer, copy_offset);
								emit(compiler, "strh w9, [sp, #%]", compiler.stack_offset + copy_offset);
								copy_offset += 2;
								bytes_remaining -= 2;
							}
							if bytes_remaining >= 1 {
								emit(compiler, "ldrb w9, [x%, #%]", reg_integer, copy_offset);
								emit(compiler, "strb w9, [sp, #%]", compiler.stack_offset + copy_offset);
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

				compile_statement(compiler, decl.body);

				body_builder := compiler.builder;
				compiler.builder = saved_builder;

				// Now we know the final stack usage. Emit the real prologue.
				link_and_return_stack_size := 16;
				total_stack_space := (compiler.max_stack_offset + link_and_return_stack_size + 15) & ~15;
				link_and_return_offset := total_stack_space - link_and_return_stack_size;

				emit_comment(compiler, "--- prologue (stack: % bytes) ---", total_stack_space);
				emit(compiler, "sub sp, sp, #%", total_stack_space);
				emit(compiler, "str x30, [sp, #%]", link_and_return_offset);
				emit(compiler, "str x29, [sp, #%]", link_and_return_offset + 8);
				emit(compiler, "add x29, sp, #0");
				emit_blank_line(compiler);

				// Append the compiled body
				emit_comment(compiler, "--- body ---");
				append(*compiler.builder, builder_to_string(*body_builder));

				// Epilogue
				emit_blank_line(compiler);
				emit_comment(compiler, "--- epilogue ---");
				emit(compiler, "ldr x30, [sp, #%]", link_and_return_offset);
				emit(compiler, "ldr x29, [sp, #%]", link_and_return_offset + 8);
				emit(compiler, "add sp, sp, #%", total_stack_space);
				emit(compiler, "ret");
				emit_label_end(compiler);
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
			emit_label(compiler, "l_.str");
			emit(compiler, ".asciz \"%\"", key);
			emit_label_end(compiler);
		} else {
			emit_label(compiler, "l_.str.%", value);
			emit(compiler, ".asciz \"%\"", key);
			emit_label_end(compiler);
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
				compile_global_initializer(compiler, it.expr, bytes, cursor + it.byte_offset);
			}
		}
		return cursor;
	}

	emit(compiler, ".data");

	for tu.declarations {
		for declarator: it.declarators {
			if is_variable_declaration(it, declarator) {
				name := identifier_from_declarator(declarator);
				emit(compiler, ".globl _%", name);
				init_expr: *Node_Expr;
				if declarator.init {
					if declarator.init.initializer_type == Node_Scalar_Initializer {
						init_expr = declarator.init.(*Node_Scalar_Initializer).expr;
						assert(declarator.resolved_type != null);
						if declarator.resolved_type.size_in_bytes == {
							case 1;
								emit(compiler, ".p2align %", 0);
								emit_label(compiler, "_%", name);
								emit(compiler, ".byte %", eval_expr(init_expr));
								emit_label_end(compiler);
							case 2;
								emit(compiler, ".p2align %", 1);
								emit_label(compiler, "_%", name);
								emit(compiler, ".short %", eval_expr(init_expr));
								emit_label_end(compiler);
							case 4;
								emit(compiler, ".p2align %", 2);
								emit_label(compiler, "_%", name);
								emit(compiler, ".long %", eval_expr(init_expr));
								emit_label_end(compiler);
							case 8;
								emit(compiler, ".p2align %", 3);
								emit_label(compiler, "_%", name);
								emit(compiler, ".quad %", eval_expr(init_expr));
								emit_label_end(compiler);
						}
					} else {
						emit_label(compiler, "_%", name);
						bytes := NewArray(declarator.resolved_type.size_in_bytes, u8);
						compile_global_initializer(compiler, declarator.init, bytes, 0);
						for bytes {
							emit(compiler, ".byte %", it);
						}
						emit_label_end(compiler);
					}
				}
			}
		}
	}

	write_entire_file("out.s", *compiler.builder);
}