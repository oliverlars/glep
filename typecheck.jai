Resolved_Type :: struct {
	kind: enum {
		Integral;
		Composite;
		Floating;
		Pointer;
		Array;
	};

	array_count: int;
	size_in_bytes: int;
	alignment: int;
	unsigned: bool;
	atomic: bool;

	composite: *Node_Composite;

	// For pointers and stuff
	inner: *Resolved_Type;
}

// TODO(Oliver): Improve this maybe ?
// I just split the multi-declarator stuff from the
// original Node_Decl to make this easier to process when
// typechecking.
Decl :: struct {
	base: Node_Decl_Info;
	declarator: *Node_Declarator;
}

Scope :: struct {
	decls: [..]Decl;
}

Type_Checker :: struct {
	scopes: [..]Scope;

	ordinary: Table(string, *Node);
}

current_scope :: (tc: *Type_Checker) -> *Scope {
	assert(tc.scopes.count > 0);
	return *tc.scopes[tc.scopes.count - 1];
}

push_scope :: (tc: *Type_Checker) {
	scope: Scope;
	array_add(*tc.scopes, scope);
}

push_decl :: (tc: *Type_Checker, base: Node_Decl_Info, declarator: *Node_Declarator) {
	scope := current_scope(tc);
	decl: Decl;
	decl.base = base;
	decl.declarator = declarator;
	array_add(*scope.decls, decl);
}

pop_scope :: (tc: *Type_Checker) {
	assert(tc.scopes.count > 0);
	tc.scopes.count -= 1;
}

find_decl_in_scope :: (tc: *Type_Checker, name: string) -> bool, Decl {
	scope_index := tc.scopes.count - 1;
	while scope_index >= 0 {
		for tc.scopes[scope_index].decls {
			id := identifier_from_declarator(it.declarator);
			if id == name return true, it;
		}
		scope_index -= 1;
	}
	return false, .{};
}

resolve_base :: (decl_info: Node_Decl_Info) -> *Resolved_Type {
	if decl_info.typedef {
		return resolve_base(decl_info.typedef.base);
	}
	Type_Specifier :: enum {
		Void;
		Char;
		Short;
		Int;
		Long;
		Float;
		Double;
		Signed;
		Unsigned;
	};

	counts: [9]int;
	for decl_info.specifiers {
		if it == {
			case "char";     counts[Type_Specifier.Char] += 1;
			case "short";    counts[Type_Specifier.Short] += 1;
			case "int";      counts[Type_Specifier.Int] += 1;
			case "long";     counts[Type_Specifier.Long] += 1;
			case "float";    counts[Type_Specifier.Float] += 1;
			case "double";   counts[Type_Specifier.Double] += 1;
			case "signed";   counts[Type_Specifier.Signed] += 1;
			case "unsigned"; counts[Type_Specifier.Unsigned] += 1;
		}
	}

	info := New(Resolved_Type);
	
	if counts[Type_Specifier.Signed] {
		info.unsigned = false;
	}

	if counts[Type_Specifier.Unsigned] {
		info.unsigned = true;
	}

	if counts[Type_Specifier.Char] > 0 {
		info.size_in_bytes = 1;
	}

	if counts[Type_Specifier.Short] > 0 {
		info.size_in_bytes = 2;
	}

	if counts[Type_Specifier.Long] == 2 {
		info.size_in_bytes = 8;
	}

	if counts[Type_Specifier.Float] {
		info.size_in_bytes = 4;
		info.kind = .Floating;
	}

	if counts[Type_Specifier.Double] {
		info.size_in_bytes = 8;
		info.kind = .Floating;
	}

	if counts[Type_Specifier.Int] {
		info.size_in_bytes = 4;
	}

	for decl_info.qualifiers {
		if it == "_Atomic" info.atomic = true;
	}

	if decl_info._enum {
		info.kind = .Composite;
		info.composite = decl_info._enum;
	}

	if decl_info._struct {
		info.kind = .Composite;
		info.composite = decl_info._struct;
	}

	return info;
}

// This takes a declarator because the base decl stores all the comma separated declarators,
// so it's just easier for now to specify which one and get a type that.
resolve_decl :: (tc: *Type_Checker, decl: *Node_Decl, declarator: *Node_Declarator) -> *Resolved_Type {
	if !decl || !declarator return null;

	resolve_declarator :: (base: *Resolved_Type, declarator: *Node_Declarator) -> *Resolved_Type {
		if !declarator return base;

		if declarator.declarator_type == {
			case Node_Pointer_Declarator;
				ptr := New(Resolved_Type);
				ptr.kind = .Pointer;
				ptr.size_in_bytes = 8;
				ptr.inner = base;
				return resolve_declarator(ptr, declarator.inner);
			case Node_Array_Declarator;
				inner := resolve_declarator(base, declarator.inner);
				array := New(Resolved_Type);
				array.kind = .Array;
				array.size_in_bytes = inner.size_in_bytes * declarator.(*Node_Array_Declarator).count;
				array.inner = inner;
				array.array_count = declarator.(*Node_Array_Declarator).count;
				return array;
			case Node_Identifier_Declarator;
				return base;
		}

		return base;
	}

	base_info := resolve_base(decl.base);
	base_info = resolve_declarator(base_info, declarator);

	padding_decl :: (tc: *Type_Checker, size_in_bytes: int) -> *Node_Decl {
		padding := New(Node_Decl);
		array_add(*padding.base.qualifiers, "char");
		declarator := New(Node_Array_Declarator);
		declarator.count = size_in_bytes / 8;
		declarator.inner = New(Node_Identifier_Declarator);
		// HACK(Oliver): the name isnt unique
		declarator.inner.(*Node_Identifier_Declarator).name = "padding";

		array_add(*padding.base.declarators, declarator);
		declarator.resolved_type = resolve_decl(tc, padding, declarator);
		
		return padding;
	}

	if base_info.composite && base_info.composite.type == Node_Struct {
		_struct := base_info.composite.(*Node_Struct);
		offset := 0;
		for member_decl, member_it: _struct.members {
			for member_declarator: member_decl.declarators {
				member_type := resolve_decl(tc, member_decl, member_declarator);
				if offset % member_type.size_in_bytes != 0 {
					size := member_type.size_in_bytes;
					bytes_to_pad := (size - (offset % size)) % size;
					padding := padding_decl(tc, bytes_to_pad);
					array_insert_at(*_struct.members, padding, member_it);
					member_it += 1;
					offset += bytes_to_pad;
				}
				offset += member_type.size_in_bytes;
				member_declarator.resolved_type = member_type;
			}
		}
		base_info.size_in_bytes = (offset + 3) & ~3;
		print("This struct is % bytes\n", base_info.size_in_bytes);
	}

	return base_info;
}

types_equal :: (a: *Resolved_Type, b: *Resolved_Type) -> bool {
	if !a && !b return true;
	if !a return false;
	if !b return false;
	inner_equal := types_equal(a.inner, b.inner);
	result := true;
	result &= a.kind == b.kind;
	result &= a.alignment == b.alignment;
	result &= a.atomic == b.atomic;
	result &= a.composite == b.composite;
	result &= a.size_in_bytes == b.size_in_bytes;
	result &= a.unsigned == b.unsigned;
	result &= a.array_count == b.array_count;
	result &= inner_equal;
	return result;
}


 
common_type :: (a: *Resolved_Type, b: *Resolved_Type) -> *Resolved_Type {
	resolved: *Resolved_Type;
	if a.kind == .Floating || b.kind == .Floating {
		resolved = New(Resolved_Type);
		if a.kind != .Floating {
			resolved.* = b.*;
		} else if b.kind != .Floating {
			resolved.* = a.*;
		} else {
			// Both are floating point, pick one side then pick the larger
			// size of the two, incase one is double
			resolved.* = a.*;
			resolved.size_in_bytes = max(a.size_in_bytes, b.size_in_bytes);
		}
	} else if a.kind == .Integral && b.kind == .Integral {
		resolved = New(Resolved_Type);
		resolved.* = a.*;
		resolved.unsigned = b.unsigned || a.unsigned;
		resolved.size_in_bytes = max(max(a.size_in_bytes, b.size_in_bytes), 4);
	} else {
		assert(false);
	}
	
	return resolved;
}

pointer_arithmetic_type :: (binary: *Node_Binary, left: *Resolved_Type, right: *Resolved_Type) -> *Resolved_Type {
	add := binary.op.type == .Plus;
	subtract := binary.op.type == .Minus;

	insert_scale :: (at: *Node_Binary, side: enum { Left; Right; }, size_in_bytes: int) {
		scale := New(Node_Binary);
		scale.op.view = "*";
		scale.op.type = .Asterisk;
		scale.resolved_type = New(Resolved_Type);

		size_number := New(Node_Number);
		size_number.is = .Decimal;
		size_number.as_u64 = xx size_in_bytes;
		size_number.resolved_type = resolve_number(size_number);

		scale.resolved_type.* = size_number.resolved_type.*;

		if side == .Left {
			scale.left = at.left;
			scale.right = size_number;
			at.left = scale;
		} else {
			scale.left = at.right;
			scale.right = size_number;
			at.right = scale;
		}
	}

	insert_divide_by_size :: (at: *Node_Binary, size_in_bytes: int) {
		div := New(Node_Binary);
		div.op.view = "/";
		div.op.type = .ForwardSlash;
		div.resolved_type = New(Resolved_Type);

		size_number := New(Node_Number);
		size_number.is = .Decimal;
		size_number.as_u64 = xx size_in_bytes;
		size_number.resolved_type = resolve_number(size_number);

		div.resolved_type.* = size_number.resolved_type.*;

		div.left = at.left;
		div.right = size_number;
		at.left = div;
	}

	resolved: *Resolved_Type;
	if left.kind == .Pointer && right.kind == .Integral {
		insert_scale(binary, .Right, left.inner.size_in_bytes);
		resolved = left;
	} else if left.kind == .Integral && right.kind == .Pointer {
		insert_scale(binary, .Left, right.inner.size_in_bytes);
		resolved = right;
	} else if subtract && left.kind == .Pointer && right.kind == .Pointer {
		assert(left.inner.size_in_bytes == right.inner.size_in_bytes);
		insert_divide_by_size(binary, left.inner.size_in_bytes);
		resolved = New(Resolved_Type);
		resolved.kind = .Integral;
		resolved.size_in_bytes = 8;
		resolved.unsigned = false;
	}
	return resolved;
}

can_coerce_to :: (target: *Resolved_Type, source: *Resolved_Type) -> bool {
	if !target || !source return false;

	if target.kind == .Integral && source.kind == .Integral return true;
	if target.kind == .Floating && source.kind == .Floating return true;
	if target.kind == .Integral && source.kind == .Floating return true;
	if target.kind == .Floating && source.kind == .Integral return true;

	if target.kind == .Pointer && source.kind == .Pointer return true; 
	if target.kind == .Pointer && source.kind == .Integral return true;
	if target.kind == .Integral && source.kind == .Pointer return true;

	if target.kind == .Composite && source.kind == .Composite {
		return target.composite == source.composite;
	}

	return false;
}

split_suffix_from_number :: (number_with_suffix: string) -> string, string {
	suffix := number_with_suffix;
	suffix.count = 0;
	number := number_with_suffix;
	for < number_with_suffix {
		if is_suffix(it) {
			number.count -= 1;
			suffix.count += 1;
		}
	}
	suffix.data = number.data + number.count;
	return number, suffix;
}

resolve_number :: (number_node: *Node_Number) -> *Resolved_Type {
	info := New(Resolved_Type);
	number, suffix := split_suffix_from_number(number_node.token_with_suffix.view);
	if number_node.is == {
		case .Float;
			info.kind = .Floating;
			info.size_in_bytes = 8;
			if suffix == "f" {
				info.size_in_bytes = 4;
			} else {
				info.size_in_bytes = 8;
			}
		case;
			info.kind = .Integral;
			info.size_in_bytes = 4;
			if suffix == "ll" {
				info.size_in_bytes = 8;
			} else if suffix == "llu" {
				info.size_in_bytes = 8;
				info.unsigned = true;
			} else if suffix == "ull" {
				info.size_in_bytes = 8;
				info.unsigned = true;
			} else if suffix == "u" {
				info.size_in_bytes = 4;
				info.unsigned = true;
			}
	}
	return info;
}

insert_cast :: (tc: *Type_Checker, at: *Node_Expr, target: *Resolved_Type) -> *Node_Cast {
	c := New(Node_Cast);
	c.expr = at;
	c.resolved_type = target;
	assert(c.resolved_type != null);
	assert(c.expr.resolved_type != null);
	return c;
}

resolve_expr :: (tc: *Type_Checker, expr: *Node_Expr) -> *Resolved_Type, bool {
	if !expr return null, false;
	if expr.expr_type == {
		case Node_Assign;
			assign := expr.(*Node_Assign);
			left_info := resolve_expr(tc, assign.left);
			right_info := resolve_expr(tc, assign.right);
			
			if !can_coerce_to(left_info, right_info) {
				return null, false;
			}
			
			if !types_equal(right_info, left_info) {
				assign.right = insert_cast(tc, assign.right, left_info);
				assign.right.resolved_type = left_info;
			} else {
				assign.right.resolved_type = left_info;
			}
			assign.left.resolved_type = left_info;
			assign.resolved_type = left_info;

			assert(assign.resolved_type != null);
			assert(assign.left.resolved_type != null);
			assert(assign.right.resolved_type != null);
			return left_info, true;
		case Node_Binary;
			binary := expr.(*Node_Binary);
			left_info := resolve_expr(tc, binary.left);
			right_info := resolve_expr(tc, binary.right);

			if left_info.kind == .Pointer || right_info.kind == .Pointer {
				resolved_type := pointer_arithmetic_type(binary, left_info, right_info);
				expr.resolved_type = resolved_type;
				return resolved_type, resolved_type != null;
			}

			resolved_type := common_type(left_info, right_info);
			if !resolved_type return null, false;

			if !types_equal(left_info, resolved_type) {
				binary.left = insert_cast(tc, binary.left, resolved_type);
			}
			if !types_equal(right_info, resolved_type) {
				binary.right = insert_cast(tc, binary.right, resolved_type);
			}
			
			binary.resolved_type = resolved_type;
			return resolved_type, true;
		case Node_Number;
			info := resolve_number(expr.(*Node_Number));
			expr.(*Node_Number).resolved_type = info;
			return info, true;
		case Node_Member_Access;
			member_access := expr.(*Node_Member_Access);
			member_access.left.resolved_type = resolve_expr(tc, member_access.left);
			left_type := member_access.left.resolved_type;
			id := member_access.right.view;
			assert(left_type.composite != null);
			assert(left_type.composite.type == Node_Struct);
			for left_type.composite.(*Node_Struct).members {
				for declarator: it.declarators {
					if id == identifier_from_declarator(declarator) {
						rt := resolve_decl(tc, it, declarator);
						member_access.resolved_type = rt;
						return member_access.resolved_type, true;
					}
				}
			}
		case Node_Array_Access;
			array_access := expr.(*Node_Array_Access);
			array_access.left.resolved_type = resolve_expr(tc, array_access.left);
			array_access.index.resolved_type = resolve_expr(tc, array_access.index);
			return array_access.left.resolved_type.inner, true;
		case Node_Identifier;
			id := expr.(*Node_Identifier).id.view;
			found, decl := find_decl_in_scope(tc, id);
			assert(found);
			expr.(*Node_Identifier).resolved_type = decl.declarator.resolved_type;
			return decl.declarator.resolved_type, true;
		case Node_Unary;
			info := resolve_expr(tc, expr.(*Node_Unary).expr);
			if expr.(*Node_Unary).op.type == {
				case .Ampersand;
					inner := info;
					info = New(Resolved_Type);
					info.kind = .Pointer;
					info.size_in_bytes = 8;
					info.inner = inner;
				case .Asterisk;
					info = info.inner;
			}
			return info, info.kind != .Composite;
		case Node_Cast;
			source := resolve_expr(tc, expr.(*Node_Cast).expr);
			target := resolve_base(expr.(*Node_Cast).base);
			expr.(*Node_Cast).resolved_type = target;
			expr.(*Node_Cast).expr.resolved_type = source;
			return target, can_coerce_to(target, source);
		case Node_String;
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.kind = .Pointer;
			return info, true;
		case Node_Call;
			for expr.(*Node_Call).args {
				arg_type := resolve_expr(tc, it);
				it.resolved_type = arg_type;
			}
			name := expr.(*Node_Call).id.(*Node_Identifier).id.view;
			print("\nTYPECHECKING CALL: %\n", name);
			found, decl := table_find(*tc.ordinary, name);
			assert(found);
			function := function_declarator(decl.(*Node_Decl).declarators[0]);
			ret_type := resolve_decl(tc, decl.(*Node_Decl), decl.(*Node_Decl).declarators[0]);
			expr.(*Node_Call).resolved_type = ret_type;
			return ret_type, true;
	}

	return null, false;
}

typecheck_statement :: (tc: *Type_Checker, stmt: *Node_Statement) {
	if !stmt return;
	if stmt.statement_type == {
		case Node_Block;
			push_scope(tc);
			for stmt.(*Node_Block).statements {
				typecheck_statement(tc, it);
			}
			pop_scope(tc);
		case Node_Expr_Statement;
			resolve_expr(tc, stmt.(*Node_Expr_Statement).expr);
		case Node_Return;
			resolve_expr(tc, stmt.(*Node_Return).expr);
		case Node_Decl_Statement;
			decl := stmt.(*Node_Decl_Statement).decl;
			print("TYPECHECKING DECL: %\n", decl.*);
			for decl.declarators {
				print("TYPECHECKING DECLARATOR: %\n", it.*);
				print("TYPECHECKING INIT: %\n", it.init.*);
				lhs := resolve_decl(tc, decl, it);
				it.resolved_type = lhs;
				resolve_initializer(tc, lhs, it.init);
				push_decl(tc, decl.base, it);
			}
	}
}

resolve_initializer :: (tc: *Type_Checker, target: *Resolved_Type, init: *Node_Initializer) -> *Resolved_Type {
	resolved := New(Resolved_Type);
	if !init {
		resolved.* = target.*;
		return resolved;
	}
	if init.initializer_type == Node_Designated_Initializer {
		for init.(*Node_Designated_Initializer).designations {
			assert(target.composite != null);
			_struct := target.composite.(*Node_Struct);
			type: *Resolved_Type;
			for designator: it.designators {
				if designator.designator_type == Node_Field_Designator {
					field := designator.(*Node_Field_Designator);
					member_offset := 0;
					for member: _struct.members {
						for declarator: member.declarators {
							member_name := identifier_from_declarator(declarator);
							if member_name == field.name.view {
								type = declarator.resolved_type;
								field.resolved_type = type;
								field.offset = member_offset;
								_struct = type.composite.(*Node_Struct);
								break member;
							}
							member_offset += declarator.resolved_type.size_in_bytes;
						}
					}
				} else {
					array := designator.(*Node_Index_Designator);
					type = type.inner;
					array.resolved_type = type;
					array.offset = type.size_in_bytes * eval_expr(array.index);
				}
			}
			expr_type := resolve_initializer(tc, type, it.expr);
		}
		resolved.* = target.*;
	} else {
		// Scalar
		print("INITIALIZER TYPE: %", init.initializer_type);
		assert(init.initializer_type == Node_Scalar_Initializer);
		scalar := init.(*Node_Scalar_Initializer);
		source := resolve_expr(tc, scalar.expr);
		if !can_coerce_to(target, source) {
			print("Uh oh\n");
			return null;
		}

		if !types_equal(target, source) {
			scalar.expr = insert_cast(tc, scalar.expr, target);
			scalar.expr.resolved_type = target;
		} else {
			scalar.expr.resolved_type = target;
			resolved = target;
		}
	}

	return resolved;
}

typecheck_decl :: (tc: *Type_Checker, decl: *Node_Decl) {
	if !decl return;
	if decl.body {
		function := function_declarator(decl.declarators[0]);
		push_scope(tc);
		for function.params {
			typecheck_decl(tc, it);
			// 'void' is the only type you can have as a function
			// parameter without a declarator
			if it.base.specifiers[0] != "void" {
				push_decl(tc, it.base, it.declarators[0]);
			}
		}
		typecheck_statement(tc, decl.body);
		pop_scope(tc);
	} else {
		for declarator: decl.declarators {
			decl_type := resolve_decl(tc, decl, declarator);
			name := identifier_from_declarator(declarator);
			print("typechecking: %\n", name);
			declarator.resolved_type = decl_type;
			resolve_initializer(tc, decl_type, declarator.init);
		}
	}
}

typecheck :: (tc: *Type_Checker, tu: *Node_Translation_Unit) {
	for decl: tu.declarations {
		typecheck_decl(tc, decl);
	}
}