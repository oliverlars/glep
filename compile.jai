
Node_Type_Info :: struct {
	kind: enum {
		Integral;
		Composite;
		Floating;
	};
	size_in_bytes: int;
	alignment: int;
	unsigned: bool;
	atomic: bool;
}

type_info_from_decl :: (decl: *Node_Decl) -> Node_Type_Info {
	result: Node_Type_Info;
	for decl.qualifiers {
		if it == "_Atomic" result.atomic = true;
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
	for decl.specifiers {
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
	
	if counts[Type_Specifier.Signed] {
		result.unsigned = false;
	}

	if counts[Type_Specifier.Unsigned] {
		result.unsigned = true;
	}

	if counts[Type_Specifier.Char] > 0 {
		result.size_in_bytes = 1;
	}

	if counts[Type_Specifier.Short] > 0 {
		result.size_in_bytes = 2;
	}

	if counts[Type_Specifier.Long] == 2 {
		result.size_in_bytes = 8;
	}

	if counts[Type_Specifier.Float] {
		result.size_in_bytes = 4;
		result.kind = .Floating;
	}

	if counts[Type_Specifier.Double] {
		result.size_in_bytes = 8;
		result.kind = .Floating;
	}

	if counts[Type_Specifier.Int] {
		result.size_in_bytes = 4;
	}

	return result;
}

types_compatible :: (a: Node_Type_Info, b: Node_Type_Info) -> bool {
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



type_info_from_number :: (number_node: *Node_Number) -> Node_Type_Info {
	info: Node_Type_Info;
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

type_info_from_expr :: (expr: *Node_Expr) ->  Node_Type_Info, bool {
	if !expr return .{}, false;
	if expr.expr_type == {
		case Node_Binary;
			left_info := type_info_from_expr(expr.(*Node_Binary).left);
			right_info := type_info_from_expr(expr.(*Node_Binary).right);
			if types_compatible(left_info, right_info) {
				return left_info, true;
			} else {
				return .{}, false;
			}
		case Node_Number;
			info := type_info_from_number(expr.(*Node_Number));
			return info, true;
		case Node_Unary;
			info := type_info_from_expr(expr.(*Node_Unary).expr);
			return info, info.kind != .Composite;
	}

	return .{}, true;
}