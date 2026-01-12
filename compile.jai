
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

	// For pointers and stuff
	inner: *Resolved_Type;
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


	return info;
}

// This takes a declarator because the base decl stores all the comma separated declarators,
// so it's just easier for now to specify which one and get a type that.
type_from_decl :: (decl: *Node_Decl, declarator: *Node_Declarator) -> *Resolved_Type {

	declarator_type_info :: (base: *Resolved_Type, declarator: *Node_Declarator) -> *Resolved_Type {
		if !declarator return null;

		inner := declarator_type_info(base, declarator.inner);

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

	declarator_type_info(base_info, declarator);

	return base_info;
}

coerce_types :: (a: *Resolved_Type, b: *Resolved_Type) -> bool {
	if a.kind != b.kind return false;
	if !a return false;
	if !b return false;
	if a.kind != b.kind return false;
	if a.size_in_bytes != b.size_in_bytes return false;
	if a.atomic != b.atomic return false;

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

type_info_from_expr :: (expr: *Node_Expr) -> *Resolved_Type, bool {
	if !expr return null, false;
	if expr.expr_type == {
		case Node_Binary;
			left_info := type_info_from_expr(expr.(*Node_Binary).left);
			right_info := type_info_from_expr(expr.(*Node_Binary).right);
			if coerce_types(left_info, right_info) {
				return left_info, true;
			} else {
				return null, false;
			}
		case Node_Number;
			info := type_info_from_number(expr.(*Node_Number));
			return info, true;
		case Node_Identifier;

		case Node_Unary;
			info := type_info_from_expr(expr.(*Node_Unary).expr);
			return info, info.kind != .Composite;
		case Node_Cast;
			to := type_info_from_expr(expr.(*Node_Cast).expr);
			// Need to check if coercing to the cast type is possible
			info := base_type_info(expr.(*Node_Cast).base);
			return info, true;
	}

	return null, true;
}

typecheck :: (tu: *Node_Translation_Unit) {
	for decl: tu.declarations {
		for declarator: decl.declarators {
			decl_type := type_from_decl(decl, declarator);
			if declarator.init && declarator.init.initializer_type == Node_Scalar_Initializer {
				expr_type := type_info_from_expr(declarator.init.(*Node_Scalar_Initializer).expr);
				if !coerce_types(decl_type, expr_type) {
					print("Incompatible types");
				} else {
					decl.resolved_type = decl_type;
					declarator.init.(*Node_Scalar_Initializer).expr.resolved_type = expr_type;
				}
			}
		}
	}
}