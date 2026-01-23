Resolved_Type :: struct {
	kind: enum {
		Integral;
		Composite;
		Floating;
		Pointer;
		Array;
	};

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

base_type_info :: (decl_info: Node_Decl_Info) -> *Resolved_Type {

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
type_from_decl :: (decl: *Node_Decl, declarator: *Node_Declarator) -> *Resolved_Type {
	if !decl || !declarator return null;

	declarator_type_info :: (base: *Resolved_Type, declarator: *Node_Declarator) -> *Resolved_Type {
		if !base || !declarator return base;

		inner := declarator_type_info(base, declarator.inner);
		if !inner return base;

		result: *Resolved_Type;
		if declarator.declarator_type == {
			case Node_Pointer_Declarator;
				result = New(Resolved_Type);
				result.kind = .Pointer;
				result.size_in_bytes = 8;
				result.inner = inner;
			case Node_Array_Declarator;
				result = New(Resolved_Type);
				result.kind = .Array;
				result.size_in_bytes = inner.size_in_bytes * declarator.(*Node_Array_Declarator).count;
				result.inner = inner;
			case;
				result = inner;
		}
		
		return result;
	}

	base_info := base_type_info(decl.base);

	base_info = declarator_type_info(base_info, declarator);

	return base_info;
}

match_types :: (a: *Resolved_Type, b: *Resolved_Type) -> bool, *Resolved_Type {
	// This leaks
	if !a || !b return false, null;
	// TODO(Oliver): These should emit casts otherwise their types are gonna
	// be weird
	result := New(Resolved_Type);
	if a.kind == .Floating && b.kind != .Floating {
		result.kind = .Floating;
		result.size_in_bytes = a.size_in_bytes;
	} else if b.kind == .Floating && a.kind != .Floating {
		result.kind = .Floating;
		result.size_in_bytes = b.size_in_bytes;
	} else if a.kind == .Integral && b.kind == .Integral {
		result.kind = .Integral;
		result.size_in_bytes = max(a.size_in_bytes, b.size_in_bytes);
		result.unsigned = a.unsigned || b.unsigned;
	} else if a.kind == .Floating && b.kind == .Floating {
		result.kind = .Floating;
		result.size_in_bytes = max(a.size_in_bytes, b.size_in_bytes);
	} else if a.kind == .Pointer && b.kind == .Pointer {
		matched, type := match_types(a.inner, b.inner);
		return matched, a;
	} else if a.kind == .Integral && b.kind == .Pointer {
		return true, b;
	} else if a.kind == .Pointer && b.kind == .Integral {
		return true, a;
	} else {
		return false, null;
	}
	
	return true, result;
}

can_coerce_to :: (target: *Resolved_Type, source: *Resolved_Type) -> bool {
	result: bool;
	if target.kind == {
		case .Integral; #through;
		case .Floating;
			return !(source.kind == .Composite || source.kind == .Array);
		case .Composite;
			// HACK(Oliver): We rely on the type pointing to the same thing in memory
			// maybe that is dumb?
			if source.kind != .Composite return false;
			return target.composite == source.composite;
		case .Array;
			 return source.kind == .Array;
	}
	return true;
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

type_info_from_number :: (number_node: *Node_Number) -> *Resolved_Type {
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

type_info_from_expr :: (tc: *Type_Checker, expr: *Node_Expr) -> *Resolved_Type, bool {
	if !expr return null, false;
	if expr.expr_type == {
		case Node_Assign;
			left_info := type_info_from_expr(tc, expr.(*Node_Assign).left);
			right_info := type_info_from_expr(tc, expr.(*Node_Assign).right);
			matched, resolved_type := match_types(left_info, right_info);
			return resolved_type, true;
		case Node_Binary;
			left_info := type_info_from_expr(tc, expr.(*Node_Binary).left);
			right_info := type_info_from_expr(tc, expr.(*Node_Binary).right);
			if left_info.kind == .Pointer && right_info.kind == .Integral {
				bin := New(Node_Binary);
				bin.left = New(Node_Number);
				bin.left.(*Node_Number).is = .Decimal;
				bin.left.(*Node_Number).as_u64 = xx left_info.inner.size_in_bytes;
				bin.op.view = "*";
				bin.op.type = .Asterisk;
				bin.right = expr.(*Node_Binary).right;
				expr.(*Node_Binary).right = bin;
				right_info = type_info_from_expr(tc, expr.(*Node_Binary).right);
			} if left_info.kind == .Integral && right_info.kind == .Pointer {
				bin := New(Node_Binary);
				bin.right = New(Node_Number);
				bin.right.(*Node_Number).is = .Decimal;
				bin.right.(*Node_Number).as_u64 = xx right_info.inner.size_in_bytes;
				bin.op.view = "*";
				bin.op.type = .Asterisk;
				bin.left = expr.(*Node_Binary).left;
				expr.(*Node_Binary).left = bin;
				left_info = type_info_from_expr(tc, expr.(*Node_Binary).left);
			}
			matched, resolved_type := match_types(left_info, right_info);
			expr.resolved_type = resolved_type;
			if matched {
				return resolved_type, true;
			} else {
				return null, false;
			}
		case Node_Number;
			info := type_info_from_number(expr.(*Node_Number));
			return info, true;
		case Node_Identifier;
			id := expr.(*Node_Identifier).id.view;
			if id == "argc" {
				a := 5;
			}
			found, decl := find_decl_in_scope(tc, id);
			assert(found);
			return decl.declarator.resolved_type, true;
		case Node_Unary;
			info := type_info_from_expr(tc, expr.(*Node_Unary).expr);
			if expr.(*Node_Unary).op.type == {
				case .Ampersand;
					inner := info;
					info = New(Resolved_Type);
					info.kind = .Pointer;
					info.size_in_bytes = 8;
					info.inner = inner;
			}
			return info, info.kind != .Composite;
		case Node_Cast;
			source := type_info_from_expr(tc, expr.(*Node_Cast).expr);
			target := base_type_info(expr.(*Node_Cast).base);
			return target, can_coerce_to(target, source);
		case Node_String;
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.kind = .Pointer;
			return info, true;
		case Node_Call;
			for expr.(*Node_Call).args {
				arg_type := type_info_from_expr(tc, it);
				it.resolved_type = arg_type;
			}
			name := expr.(*Node_Call).id.(*Node_Identifier).id.view;
			print("TYPECHECKING: %\n", name);
			found, decl := table_find(*tc.ordinary, name);
			assert(found);
			for decl.(*Node_Decl).declarators {
				if it.declarator_type == Node_Function_Declarator {
					ret_type := type_from_decl(decl.(*Node_Decl), it);
					expr.(*Node_Call).resolved_type = ret_type;
					return ret_type, true;
				}
			}
	}

	return null, true;
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
			type_info_from_expr(tc, stmt.(*Node_Expr_Statement).expr);
		case Node_Decl_Statement;
			decl := stmt.(*Node_Decl_Statement).decl;
			for decl.declarators {
				if it.init.initializer_type == Node_Scalar_Initializer {
					type_info_from_expr(tc, it.init.(*Node_Scalar_Initializer).expr);
				}
				it.resolved_type = type_from_decl(decl, it);
				push_decl(tc, decl.base, it);
			}
	}
}

typecheck_decl :: (tc: *Type_Checker, decl: *Node_Decl) {
	if !decl return;
	if decl.body {
		function := function_declarator(decl.declarators[0]);
		push_scope(tc);
		for function.params {
			typecheck_decl(tc, it);
			push_decl(tc, it.base, it.declarators[0]);
		}
		typecheck_statement(tc, decl.body);
		pop_scope(tc);
	} else {
		for declarator: decl.declarators {
			decl_type := type_from_decl(decl, declarator);
			if declarator.init && declarator.init.initializer_type == Node_Scalar_Initializer {
				expr_type, valid := type_info_from_expr(tc, declarator.init.(*Node_Scalar_Initializer).expr);
				if !valid || !can_coerce_to(decl_type, expr_type) {
					print("Incompatible types");
				} else {
					declarator.resolved_type = decl_type;
					declarator.init.(*Node_Scalar_Initializer).expr.resolved_type = expr_type;
				}
			} else {
				declarator.resolved_type = decl_type;
			}
		}
	}
}

typecheck :: (tc: *Type_Checker, tu: *Node_Translation_Unit) {
	for decl: tu.declarations {
		typecheck_decl(tc, decl);
	}
}