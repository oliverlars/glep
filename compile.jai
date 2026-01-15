
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
		if !base || !declarator return null;

		inner := declarator_type_info(base, declarator.inner);
		if !inner return null;

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

match_types :: (a: *Resolved_Type, b: *Resolved_Type) -> bool, *Resolved_Type {
	// This leaks
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
		return matched, type;
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

type_info_from_expr :: (expr: *Node_Expr) -> *Resolved_Type, bool {
	if !expr return null, false;
	if expr.expr_type == {
		case Node_Binary;
			left_info := type_info_from_expr(expr.(*Node_Binary).left);
			right_info := type_info_from_expr(expr.(*Node_Binary).right);
			matched, resolved_type := match_types(left_info, right_info);
			if matched {
				return resolved_type, true;
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
			source := type_info_from_expr(expr.(*Node_Cast).expr);
			target := base_type_info(expr.(*Node_Cast).base);
			return target, can_coerce_to(target, source);
		case Node_String;
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.kind = .Pointer;
			return info, true;
		case Node_Call;
			for expr.(*Node_Call).args {
				arg_type := type_info_from_expr(it);
				it.resolved_type = arg_type;
			}
	}

	return null, true;
}

typecheck_statement :: (stmt: *Node_Statement) {
	if !stmt return;
	if stmt.statement_type == {
		case Node_Block;
			for stmt.(*Node_Block).statements {
				typecheck_statement(it);
			}
		case Node_Expr_Statement;
			type_info_from_expr(stmt.(*Node_Expr_Statement).expr);
	}
}

typecheck :: (tu: *Node_Translation_Unit) {
	for decl: tu.declarations {
		if decl.body {
			typecheck_statement(decl.body);
		} else {
			for declarator: decl.declarators {
				decl_type := type_from_decl(decl, declarator);
				if declarator.init && declarator.init.initializer_type == Node_Scalar_Initializer {
					expr_type, valid := type_info_from_expr(declarator.init.(*Node_Scalar_Initializer).expr);
					if !valid || !can_coerce_to(decl_type, expr_type) {
						print("Incompatible types");
					} else {
						decl.resolved_type = decl_type;
						declarator.init.(*Node_Scalar_Initializer).expr.resolved_type = expr_type;
					}
				}
			}
		}
	}
}

Compiler :: struct {
	builder: String_Builder;
	strings: Table(string, int);
	register := 9;

	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);
}

emit :: (compiler: *Compiler, fmt: string, args: ..Any) {
	append(*compiler.builder, tprint(fmt, ..args));
	append(*compiler.builder, "\n");
}

compile_expr :: (compiler: *Compiler, expr: *Node_Expr) {
	if !expr return;
	if expr.expr_type == {
		case Node_Binary;
			compile_expr(compiler, expr.(*Node_Binary).left);
			dst := compiler.register;
			compiler.register += 1;
			compile_expr(compiler, expr.(*Node_Binary).right);
			if expr.(*Node_Binary).op.type == {
				case .Plus;
					emit(compiler, "add w%, w%, w%", dst, dst, compiler.register);
				case .Minus;
					emit(compiler, "sub w%, w%, w%", dst, dst, compiler.register);
				case .Asterisk;
					emit(compiler, "mul w%, w%, w%", dst, dst, compiler.register);
				case .ForwardSlash;
					emit(compiler, "div w%, w%, w%", dst, dst, compiler.register);
			}
			compiler.register -= 1;
		case Node_Number;
			emit(compiler, "mov w%, %", compiler.register, expr.(*Node_Number).as_u64.(u32));
		case Node_Char;
			value := 0;
			for expr.(*Node_Char).token.view {
				value += it;
			}
			emit(compiler, "mov w%, %", compiler.register, value);
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			_, decl := table_find(*compiler.ordinary, name);
			param_count := 0;
			variadic := false;
			for decl.(*Node_Decl).declarators {
				if it.declarator_type == Node_Function_Declarator {
					param_count = it.(*Node_Function_Declarator).params.count;
					variadic = it.(*Node_Function_Declarator).variadic;
				}
			}
			variadic_stack_register := compiler.register;
			if variadic {
				emit(compiler, "mov x%, sp", variadic_stack_register);
				compiler.register += 1;
			}
			for call.args {
				compile_expr(compiler, it);


				if it_index >= param_count {
					emit(compiler, "str x%, [x%]", compiler.register, variadic_stack_register);
				} else {
					if it.resolved_type && it.resolved_type.size_in_bytes == 8 {
						emit(compiler, "mov x%, x%", it_index, compiler.register);
					} else {
						emit(compiler, "mov w%, w%", it_index, compiler.register);
					}
				}
			}
			assert(call.id.expr_type == Node_Identifier);
			// NOTE(Oliver): All C symbols need underscores? what the hell?
			emit(compiler, "bl _%", name);
		case Node_String;
			ok, count := table_find(*compiler.strings, expr.(*Node_String).token.view);
			assert(ok);
			if count == 0 {
				emit(compiler, "adrp x%, l_.str@PAGE", compiler.register);
				emit(compiler, "add x%, x%, l_.str@PAGEOFF", compiler.register, compiler.register);
			} else {
				emit(compiler, "adrp x%, l_.str.%@PAGE", compiler.register, count);
				emit(compiler, "add x%, x%, l_.str.%@PAGEOFF", compiler.register, compiler.register, count);
			}
	}
}

compile_statement :: (compiler: *Compiler, stmt: *Node_Statement) {
	if !stmt return;
	if stmt.statement_type == {
		case Node_Block;
			for stmt.(*Node_Block).statements {
				compile_statement(compiler, it);
			}
		case Node_Return;
			compile_expr(compiler, stmt.(*Node_Return).expr);
			emit(compiler, "mov x0, x%", compiler.register);
		case Node_Expr_Statement;
			compile_expr(compiler, stmt.(*Node_Expr_Statement).expr);
	}
}

compile_decl :: (compiler: *Compiler, decl: *Node_Decl) {
	// Better way to check if it's a function?
	if decl.body {
		// NOTE(Oliver): All C symbols need underscores? what the hell?
		emit(compiler, "_%:", identifier_from_declarator(decl.declarators[0]));
		// TODO(Oliver): Figure out this magic shit
		emit(compiler, "sub sp, sp, #32");
		emit(compiler, "stp x29, x30, [sp, #16]");
		emit(compiler, "add x29, sp, #16");
		compile_statement(compiler, decl.body);
		emit(compiler, "ldp x29, x30, [sp, #16]");
		emit(compiler, "add sp, sp, #32");
		emit(compiler, "ret");
	} else {

	}
}

compile :: (compiler: *Compiler, tu: Node_Translation_Unit) {
	emit(compiler, ".globl _main"); // Set _main to be the entry point
	emit(compiler, ".p2align 2"); // Align to 4 bytes, power of 2: 2^2
	for tu.declarations {
		compile_decl(compiler, it);
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
	write_entire_file("out.s", *compiler.builder);
}