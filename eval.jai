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
		case .U64; result = .{ kind = .S64, as_s64 = -v.as_u64.(s64) };
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

process_string_escapes :: (raw: string) -> []u8 {
	result: [..]u8;
	i := 0;
	while i < raw.count {
		if raw[i] == #char "\\" && i + 1 < raw.count {
			i += 1;
			val, len := parse_escape(raw, i);
			array_add(*result, cast(u8) val);
			i += len;
		} else {
			array_add(*result, raw[i]);
			i += 1;
		}
	}
	array_add(*result, 0);
	return result;
}

eval_char_literal :: (view: string) -> int {
	if view.count >= 2 && view[0] == #char "\\" {
		val, len := parse_escape(view, 1);
		return val;
	}
	if view.count == 1 return view[0];
	return view[view.count - 1];
}

parse_escape :: (s: string, start: int) -> (val: int, len: int) {
	c := s[start];

	hex_value :: (c: u8) -> int {
		if c >= #char "0" && c <= #char "9" return cast(int) (c - #char "0");
		if c >= #char "a" && c <= #char "f" return cast(int) (c - #char "a") + 10;
		if c >= #char "A" && c <= #char "F" return cast(int) (c - #char "A") + 10;
		return 0;
	}

	if c == #char "x" {
		// hex: \xNN...
		val := 0;
		i := start + 1;
		while i < s.count && (s[i] >= #char "0" && (s[i] <= #char "9") ||
			  (s[i] >= #char "a" && s[i] <= #char "f") ||
			  (s[i] >= #char "A" && s[i] <= #char "F")) {
			val = val * 16 + hex_value(s[i]);
			i += 1;
		}
		return val, i - start;
	}

	if c >= #char "0" && c <= #char "7" {
		// octal: up to 3 digits
		val := cast(int) (c - #char "0");
		i := start + 1;
		while i < s.count && i - start < 3 && s[i] >= #char "0" && s[i] <= #char "7" {
			val = val * 8 + cast(int) (s[i] - #char "0");
			i += 1;
		}
		return val, i - start;
	}

	if c == {
		case #char "n";  return 10, 1;
		case #char "t";  return  9, 1;
		case #char "r";  return 13, 1;
		case #char "\\"; return 92, 1;
		case #char "'";  return 39, 1;
		case #char "\""; return 34, 1;
		case #char "a";  return  7, 1;
		case #char "b";  return  8, 1;
		case #char "f";  return 12, 1;
		case #char "v";  return 11, 1;
	}

	// unknown escape: return the character itself
	return cast(int) c, 1;
}

eval_constant_expr :: (_enums: *Table(string, int), expr: *Node_Expr) -> Constant {
	if !expr return .{};
	if expr.expr_type == {
		case Node_Unary;
			unary := expr.(*Node_Unary);
			op := unary.op;
			if op.type == {
				case .Minus;
					return -eval_constant_expr(_enums, unary.expr);
				case .Plus;
					return +eval_constant_expr(_enums, unary.expr);
				case .Bang;
					return !eval_constant_expr(_enums, unary.expr);
				case .Tilde;
					return ~eval_constant_expr(_enums, unary.expr);
			}
		case Node_Binary;
			op := expr.(*Node_Binary).op;
			left  := eval_constant_expr(_enums, expr.(*Node_Binary).left);
			right := eval_constant_expr(_enums, expr.(*Node_Binary).right);

			if op.type == {
				case .Plus;
					return left + right;
				case .Minus;
					return left - right;
				case .Asterisk;
					return left * right;
				case .ForwardSlash;
					return left / right;
				case .Less;
					return left < right;
				case .Greater;
					return left > right;
				case .LessEqual;
					return left <= right;
				case .GreaterEqual;
					return left >= right;
				case .BangEqual;
					return left != right;
				case .EqualEqual;
					return left == right;
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
			return convert_constant(eval_constant_expr(_enums, c.expr), c.resolved_type);
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			return .{ kind = .U64, as_u64 = sizeof.expr.resolved_type.size_in_bytes.(u64) };
		case Node_Sizeof_Type;
			sizeof := expr.(*Node_Sizeof_Type);
			return .{ kind = .U64, as_u64 = sizeof.target_type.size_in_bytes.(u64) };
		case Node_Alignof_Type;
			alignof := expr.(*Node_Alignof_Type);
			return .{ kind = .U64, as_u64 = alignof.target_type.alignment.(u64) };
		case Node_Char;
			value := eval_char_literal(expr.(*Node_Char).token.view);
			return .{ kind = .U64, as_u64 = value.(u64) };
		case Node_Identifier;
			id := expr.(*Node_Identifier).id.view;
			found, value := table_find(_enums, id);
			assert(found, tprint("Unknown identifier in constant expression: %", id));
			return .{ kind = .U64, as_u64 = value.(u64) };
	}
	return .{};
}
