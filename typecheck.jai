Struct_Member :: struct {
	offset: int;
	alignment: int;
	size: int;
}

Struct_Layout :: struct {
	members: [..]Struct_Member;
}

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

	// Only needed for printing
	symbol_name: string;
	composite: *Node_Composite;
	layout: Struct_Layout;

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

	// HACK(Oliver): Although I currently store the resolved_type
	// on the struct itself, we need a cache to know if we are currently
	// resolving a struct to avoid any further attempt at resolving it
	// incase of recursive types.
	_structs: Table(*Node_Struct, *Resolved_Type);

	current_function_return_type: *Resolved_Type;
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

resolve_base :: (tc: *Type_Checker, decl_info: Node_Decl_Info) -> *Resolved_Type {
	if decl_info.typedef {
		typedef := resolve_base(tc, decl_info.typedef.base);
		if decl_info.typedef_name {
			typedef.symbol_name = decl_info.typedef_name;
		}
		return typedef;
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

	info.size_in_bytes = 4;

	if counts[Type_Specifier.Int] {
		info.size_in_bytes = 4;
		info.alignment = 4;
	}
	
	if counts[Type_Specifier.Signed] {
		info.unsigned = false;
	}

	if counts[Type_Specifier.Unsigned] {
		info.unsigned = true;
	}

	if counts[Type_Specifier.Char] > 0 {
		info.size_in_bytes = 1;
		info.alignment = 1;
	}

	if counts[Type_Specifier.Short] > 0 {
		info.size_in_bytes = 2;
		info.alignment = 2;
	}

	if counts[Type_Specifier.Long] == 2 {
		info.size_in_bytes = 8;
		info.alignment = 8;
	}

	if counts[Type_Specifier.Float] {
		info.size_in_bytes = 4;
		info.kind = .Floating;
		info.alignment = 4;
	}

	if counts[Type_Specifier.Double] {
		info.size_in_bytes = 8;
		info.kind = .Floating;
		info.alignment = 8;
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

		_struct := decl_info._struct;
		if !table_contains(*tc._structs, _struct) {
			offset := 0;
			table_add(*tc._structs, _struct, info);
			max_alignment := 0;
			for member_decl, member_it: _struct.members {
				for member_declarator: member_decl.declarators {
					member_type := resolve_decl(tc, member_decl, member_declarator);
					if offset % member_type.alignment != 0 {
						align := member_type.alignment;
						bytes_to_pad := (align - (offset % align)) % align;
						offset += bytes_to_pad;
					}
					max_alignment = max(max_alignment, member_type.alignment);
					array_add(*info.layout.members, Struct_Member.{ offset, member_type.alignment, member_type.size_in_bytes});
					offset += member_type.size_in_bytes;
					member_declarator.resolved_type = member_type;
				}
			}
			info.size_in_bytes = (offset + max_alignment - 1) & ~(max_alignment - 1);
			info.alignment = max_alignment;
			table_add(*tc._structs, _struct, info);
		} else {
			_, info = table_find(*tc._structs, _struct);
		}
	}

	return info;
}

resolve_declarator :: (base: *Resolved_Type, declarator: *Node_Declarator) -> *Resolved_Type {
	if !declarator return base;

	if declarator.declarator_type == {
		case Node_Pointer_Declarator;
			ptr := New(Resolved_Type);
			ptr.kind = .Pointer;
			ptr.size_in_bytes = 8;
			ptr.inner = base;
			ptr.alignment = 8;
			return resolve_declarator(ptr, declarator.inner);
		case Node_Array_Declarator;
			inner := resolve_declarator(base, declarator.inner);
			array := New(Resolved_Type);
			array.kind = .Array;
			array.size_in_bytes = inner.size_in_bytes * declarator.(*Node_Array_Declarator).count;
			array.inner = inner;
			array.array_count = declarator.(*Node_Array_Declarator).count;
			array.alignment = inner.alignment;
			return array;
		case Node_Identifier_Declarator;
			return base;
	}

	return base;
}

// This takes a declarator because the base decl stores all the comma separated declarators,
// so it's just easier for now to specify which one and get a type that.
resolve_decl :: (tc: *Type_Checker, decl: *Node_Decl, declarator: *Node_Declarator) -> *Resolved_Type {
	if !decl return null;

	base_info := resolve_base(tc, decl.base);
	base_info = resolve_declarator(base_info, declarator);


	return base_info;
}

resolve_decl :: (tc: *Type_Checker, base: *Node_Decl_Info, declarator: *Node_Declarator) -> *Resolved_Type {
	if !base return null;

	base_info := resolve_base(tc, base);
	base_info = resolve_declarator(base_info, declarator);


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
		size_number.kind = .INTEGER;
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
		size_number.kind = .INTEGER;
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
	_, suffix := split_suffix_from_number(number_node.token_with_suffix.view);
	if number_node.kind == .FLOAT {
		info.kind = .Floating;
		info.size_in_bytes = 8;
		if suffix == "f" {
			info.size_in_bytes = 4;
		}
	} else {
		info.kind = .Integral;
		if suffix == "u" || suffix == "U" {
			if number_node.as_u64 <= 0xFFFFFFFF {
				info.size_in_bytes = 4;
			} else {
				info.size_in_bytes = 8;
			}
			info.unsigned = true;

		} else if suffix == "l" || suffix == "L" || suffix == "ll" || suffix == "LL" {
			info.size_in_bytes = 8;
			if number_node.unsigned && number_node.as_u64 > 0x7FFFFFFFFFFFFFFF {
				info.unsigned = true;
			}

		} else if suffix == "ul" || suffix == "UL" || suffix == "lu" || suffix == "LU"
			|| suffix == "ull" || suffix == "ULL" || suffix == "llu" || suffix == "LLU" {
			info.size_in_bytes = 8;
			info.unsigned = true;

		} else {
			if number_node.unsigned {
				if number_node.as_u64 <= 0x7FFFFFFF {
					info.size_in_bytes = 4;
				} else if number_node.as_u64 <= 0xFFFFFFFF {
					info.size_in_bytes = 4;
					info.unsigned = true;
				} else if number_node.as_u64 <= 0x7FFFFFFFFFFFFFFF {
					info.size_in_bytes = 8;
				} else {
					info.size_in_bytes = 8;
					info.unsigned = true;
				}
			} else {
				if number_node.as_u64 <= 0x7FFFFFFF {
					info.size_in_bytes = 4;
				} else {
					info.size_in_bytes = 8;
				}
			}
		}
	}
	return info;
}

decl_info_from_resolved_type :: (target: *Resolved_Type) -> Node_Decl_Info {
	info: Node_Decl_Info;
	if target.kind == {
		case .Floating;
			if target.size_in_bytes == 4  array_add(*info.specifiers, "float");
			else                          array_add(*info.specifiers, "double");
		case .Integral;
			if target.unsigned  array_add(*info.specifiers, "unsigned");
			if target.size_in_bytes == {
				case 1; array_add(*info.specifiers, "char");
				case 2; array_add(*info.specifiers, "short");
				case 4; array_add(*info.specifiers, "int");
				case 8; array_add(*info.specifiers, "long");
			}
		case .Composite;
			if target.symbol_name {
				array_add(*info.specifiers, target.symbol_name);
			} else {
				_struct := target.composite.(*Node_Struct);
				info._struct = _struct;
				info.reference = true;
			}
		case .Pointer;
			inner_info := decl_info_from_resolved_type(target.inner);
			ptr_decl := New(Node_Declarator);
			ptr_decl.declarator_type = Node_Pointer_Declarator;
			if inner_info.declarators.count > 0 {
				ptr_decl.inner = inner_info.declarators[0];
				inner_info.declarators[0] = ptr_decl;
			} else {
				array_add(*inner_info.declarators, ptr_decl);
			}
			info = inner_info;
	}
	return info;
}

insert_cast :: (tc: *Type_Checker, at: *Node_Expr, target: *Resolved_Type) -> *Node_Cast {
	c := New(Node_Cast);
	c.expr = at;
	c.resolved_type = target;
	c.base = decl_info_from_resolved_type(target);
	assert(c.resolved_type != null);
	assert(c.expr.resolved_type != null);
	return c;
}

coerce :: (tc: *Type_Checker, expr: **Node_Expr, target: *Resolved_Type) {
	if !target return;
	if !expr.*.resolved_type return;
	if types_equal(expr.*.resolved_type, target) return;
	expr.* = insert_cast(tc, expr.*, target);
}

function_declarator :: (declarator: *Node_Declarator) -> *Node_Function_Declarator {
	result := declarator;
	while result && result.declarator_type != Node_Function_Declarator {
		result = result.inner;
	}
	assert(result.declarator_type == Node_Function_Declarator);
	return result.(*Node_Function_Declarator);
}

resolve_expr :: (tc: *Type_Checker, expr: *Node_Expr) -> *Resolved_Type, bool {
	if !expr return null, false;
	if expr.expr_type == {
		case Node_Ternary;
			ternary := expr.(*Node_Ternary);
			resolve_expr(tc, ternary.cond);
			on_true, _ := resolve_expr(tc, ternary.on_true);
			on_false, _ := resolve_expr(tc, ternary.on_false);
			if on_true.kind == .Pointer || on_false.kind == .Pointer {
				if on_true.kind == .Pointer {
					expr.resolved_type = on_true;
				} else {
					expr.resolved_type = on_false;
				}
				return expr.resolved_type, expr.resolved_type != null;
			}

			ternary.on_true.resolved_type = on_true;
			ternary.on_false.resolved_type = on_false;

			if on_true.kind == .Composite && on_false.kind == .Composite {
				assert(on_true.composite == on_false.composite);
				expr.resolved_type = on_true;
				return on_true, true;
			}

			resolved_type := common_type(on_true, on_false);
			if !resolved_type return null, false;

			coerce(tc, *ternary.on_true, resolved_type);
			coerce(tc, *ternary.on_false, resolved_type);

			expr.resolved_type = resolved_type;
			return resolved_type, true;
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			resolved := New(Resolved_Type);
			resolved.kind = .Integral;
			resolved.size_in_bytes = 8;
			resolved.unsigned = true;
			resolved.alignment = 8;
			sizeof.resolved_type = resolved;
			resolve_expr(tc, sizeof.expr);
			return resolved, true;
		case Node_Sizeof_Type;
			sizeof := expr.(*Node_Sizeof_Type);
			resolved := New(Resolved_Type);
			resolved.kind = .Integral;
			resolved.size_in_bytes = 8;
			resolved.unsigned = true;
			resolved.alignment = 8;
			sizeof.resolved_type = resolved;
			decl := ifx sizeof.base.declarators.count > 0 then sizeof.base.declarators[0] else null;
			sizeof.target_type = resolve_decl(tc, *sizeof.base, decl);
			return resolved, true;
		case Node_Compound;
			compound := expr.(*Node_Compound);
			compound.resolved_type = resolve_decl(tc, *compound.base_info, compound.declarator);
			resolve_initializer(tc, compound.resolved_type, compound.init);
			return compound.resolved_type, true;
		case Node_Assign;
			assign := expr.(*Node_Assign);
			left_info := resolve_expr(tc, assign.left);
			right_info := resolve_expr(tc, assign.right);
			
			if !can_coerce_to(left_info, right_info) {
				return null, false;
			}
			
			coerce(tc, *assign.right, left_info);
			assign.left.resolved_type = left_info;
			assign.resolved_type = left_info;
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

			coerce(tc, *binary.left, resolved_type);
			coerce(tc, *binary.right, resolved_type);
					
			if binary.op.type == {
				case .Less; #through;
				case .Greater; #through;
				case .LessEqual; #through;
				case .GreaterEqual; #through;
				case .EqualEqual; #through;
				case .BangEqual;
					comparison_result := New(Resolved_Type);
					comparison_result.kind = .Integral;
					comparison_result.size_in_bytes = 4;
					comparison_result.alignment = 4;
					resolved_type = comparison_result;
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
			if left_type.composite == null {
				left_type = left_type.inner;
			}
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
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.kind = .Integral;
			info.unsigned = true;
			array_access.index = insert_cast(tc, array_access.index, info);
			array_access.resolved_type = array_access.left.resolved_type.inner;
			return array_access.left.resolved_type.inner, true;
		case Node_Identifier;
			id := expr.(*Node_Identifier).id.view;
			found, decl := find_decl_in_scope(tc, id);
			
			assert(found);
			expr.resolved_type = decl.declarator.resolved_type;
			return decl.declarator.resolved_type, true;
		case Node_Unary;
			info := resolve_expr(tc, expr.(*Node_Unary).expr);
			if expr.(*Node_Unary).op.type == {
				case .Ampersand;
					inner := info;
					info = New(Resolved_Type);
					info.kind = .Pointer;
					info.size_in_bytes = 8;
					info.alignment = 8;
					info.inner = inner;
				case .Asterisk;
					info = info.inner;
			}
			expr.resolved_type = info;
			return info, info.kind != .Composite;
		case Node_Cast;
			source := resolve_expr(tc, expr.(*Node_Cast).expr);
			target := resolve_base(tc, expr.(*Node_Cast).base);
			expr.(*Node_Cast).resolved_type = target;
			expr.(*Node_Cast).expr.resolved_type = source;
			return target, can_coerce_to(target, source);
		case Node_String;
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.alignment = 8;
			info.kind = .Pointer;
			expr.resolved_type = info;
			return info, true;
		case Node_Char;
			info := New(Resolved_Type);
			info.size_in_bytes = 4;
			info.alignment = 4;
			info.kind = .Integral;
			expr.resolved_type = info;
			return info, true;
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			found, decl := table_find(*tc.ordinary, name);
			assert(found);
			function := function_declarator(decl.(*Node_Decl).declarators[0]);
			
			for call.args {
				arg_type := resolve_expr(tc, it);
				it.resolved_type = arg_type;
				
				if it_index < function.params.count {
					param := function.params[it_index];
					param_type: *Resolved_Type;
					if param.declarators.count > 0{
						param_type = param.declarators[0].resolved_type;
					} else {
						param_type = resolve_base(tc, param.base);
					}
					if param_type {
						coerce(tc, *call.args[it_index], param_type);
					}
				}
			}
			
			ret_type := resolve_decl(tc, decl.(*Node_Decl), decl.(*Node_Decl).declarators[0]);
			call.resolved_type = ret_type;
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
			ret := stmt.(*Node_Return);
			ret.expr.resolved_type = resolve_expr(tc, ret.expr);
			coerce(tc, *ret.expr, tc.current_function_return_type);
		case Node_Decl_Statement;
			decl := stmt.(*Node_Decl_Statement).decl;
			for decl.declarators {
				lhs := resolve_decl(tc, decl, it);
				it.resolved_type = lhs;
				resolve_initializer(tc, lhs, it.init);
				push_decl(tc, decl.base, it);
			}
		case Node_For;
			_for := stmt.(*Node_For);
			typecheck_statement(tc, _for.init);
			resolve_expr(tc, _for.cond);
			resolve_expr(tc, _for.expr);
			typecheck_statement(tc, _for.body);
		case Node_While;
			_while := stmt.(*Node_While);
			resolve_expr(tc, _while.cond);
			typecheck_statement(tc, _while.body);
		case Node_If;
			_if := stmt.(*Node_If);
			resolve_expr(tc, _if.cond);
			typecheck_statement(tc, _if.on_false);
			typecheck_statement(tc, _if.on_true);
	}

}

type_from_struct_member :: (tc: *Type_Checker, _struct: *Node_Struct, name: string) -> *Resolved_Type {
	for member: _struct.members {
		for member.declarators {
			member_name := identifier_from_declarator(it);
			if member_name == name {
				return it.resolved_type;
			}
		}
	}
	assert(false);
	return null;
}

index_from_struct_member :: (tc: *Type_Checker, _struct: *Node_Struct, name: string) -> int {
	index := 0;
	for member: _struct.members {
		for member.declarators {
			member_name := identifier_from_declarator(it);
			if member_name == name {
				return index;
			}
			index += 1;
		}
	}
	assert(false);
	return index;
}

member_type_from_index :: (tc: *Type_Checker, _struct: *Node_Struct, index: int) -> *Resolved_Type {
	current_index := 0;
	for member: _struct.members {
		for member.declarators {
			if current_index == index {
				return it.resolved_type;
			}
			current_index += 1;
		}
	}
	assert(false);
	return null;
}

resolve_initializer :: (tc: *Type_Checker, target: *Resolved_Type, init: *Node_Initializer) -> *Resolved_Type {
	if !init return null;

	if init.initializer_type == {
		case Node_Designated_Initializer;
			index := 0;
			designations := init.(*Node_Designated_Initializer).designations;
			for designation: designations {
				type := target;
				offset := 0;
				
				if designation.designators.count > 0 {
					for designation.designators {
						if it.designator_type == {
							case Node_Field_Designator;
								field := it.(*Node_Field_Designator);
								index = index_from_struct_member(tc, type.composite.(*Node_Struct), field.name.view);
								offset += type.layout.members[index].offset;
								type = type_from_struct_member(tc, type.composite.(*Node_Struct), field.name.view);
							case Node_Index_Designator;
								array := it.(*Node_Index_Designator);
								constant_index := eval_constant_expr(array.index);
								if constant_index.kind == .S64 {
									index = constant_index.as_s64.(s64);
								} else if constant_index.kind == .U64 {
									index = constant_index.as_u64.(s64);
								} else {
									index = constant_index.as_f64.(s64);
								}
								offset += index * type.inner.size_in_bytes;
								type = type.inner;
						}
					}
				} else {
					if type.kind == .Composite {
						offset = type.layout.members[index].offset;
						type = member_type_from_index(tc, type.composite.(*Node_Struct), index);
					} else if type.kind == .Array {
						offset = index * type.inner.size_in_bytes;
						type = type.inner;
						print("array inner offset: %\n", offset);
					}
				}
				designation.byte_offset = offset;
				resolve_initializer(tc, type, designation.expr);
				index += 1;
			}
		case Node_Scalar_Initializer;
			scalar := init.(*Node_Scalar_Initializer).expr;
			expr_type := resolve_expr(tc, scalar);
			if !can_coerce_to(target, expr_type) {
				print("Scalar does not match left hand type\n");
			}
			if !types_equal(target, expr_type) {
				init.(*Node_Scalar_Initializer).expr = insert_cast(tc, scalar, target);
			} else {
				init.(*Node_Scalar_Initializer).expr.resolved_type = target;
			}
	}
	return target;
}

typecheck_decl :: (tc: *Type_Checker, decl: *Node_Decl) {
	if !decl return;
	if decl.body {
		function := function_declarator(decl.declarators[0]);
		decl.declarators[0].resolved_type = resolve_decl(tc, decl, decl.declarators[0]);
		prev_return_type := tc.current_function_return_type;
		tc.current_function_return_type = decl.declarators[0].resolved_type;
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
		tc.current_function_return_type = prev_return_type;
	} else {
		for declarator: decl.declarators {
			push_decl(tc, decl.base, declarator);
			name := identifier_from_declarator(declarator);
			decl_type := resolve_decl(tc, decl, declarator);
			declarator.resolved_type = decl_type;
			resolve_initializer(tc, decl_type, declarator.init);
		}
	}
}

typecheck :: (tc: *Type_Checker, tu: *Node_Translation_Unit) {
	push_scope(tc);
	for decl: tu.declarations {
		typecheck_decl(tc, decl);
	}
	pop_scope(tc);
}