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

process_string_escapes :: (raw: string) -> []u8 {
	result: [..]u8;
	i := 0;
	while i < raw.count {
		if raw[i] == #char "\\" && i + 1 < raw.count {
			escape := raw[i + 1];
			if escape == {
				case #char "n";  array_add(*result, 10);
				case #char "t";  array_add(*result, 9);
				case #char "r";  array_add(*result, 13);
				case #char "0";  array_add(*result, 0);
				case #char "\\"; array_add(*result, 92);
				case #char "'";  array_add(*result, 39);
				case #char "\""; array_add(*result, 34);
				case #char "a";  array_add(*result, 7);
				case #char "b";  array_add(*result, 8);
				case #char "f";  array_add(*result, 12);
				case #char "v";  array_add(*result, 11);
				case;
					// Unknown escape: keep both chars
					array_add(*result, raw[i]);
					array_add(*result, escape);
			}
			i += 2;
		} else {
			array_add(*result, raw[i]);
			i += 1;
		}
	}
	array_add(*result, 0); // null terminator
	return result;
}

eval_char_literal :: (view: string) -> int {
	if view.count >= 2 && view[0] == #char "\\" {
		if view[1] == {
			case #char "n";  return 10;
			case #char "t";  return 9;
			case #char "r";  return 13;
			case #char "0";  return 0;
			case #char "\\"; return 92;
			case #char "'";  return 39;
			case #char "\""; return 34;
			case #char "a";  return 7;
			case #char "b";  return 8;
			case #char "f";  return 12;
			case #char "v";  return 11;
		}
	}
	if view.count == 1 return view[0];
	// Multi-char constant: just use the last byte
	return view[view.count - 1];
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
			value := eval_char_literal(expr.(*Node_Char).token.view);
			return .{ kind = .U64, as_u64 = value.(u64) };
		case Node_Identifier;
			// TODO(Oliver): Enums
			assert(false, "Enums in constant expr are not handled");
	}
	return .{};
}