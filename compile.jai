
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

type_from_literal :: (literal: Node_Expr) -> Node_Type_Info {

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
}

types_compatible :: (a: Node_Type_Info, b: Node_Type_Info) -> bool {
	if a.kind != b.kind return false;
	if a.size_in_bytes != b.size_in_bytes return false;
	if a.atomic != b.atomic return false;
}

is_expr_valid :: (expr: *Node_Expr) -> bool {
	result: bool;
	if expr.expr_type == {
		case Node_Binary;
			result |= is_expr_valid(expr.(*Node_Binary).left);
			result |= is_expr_valid(expr.(*Node_Binary).left);
	}
}