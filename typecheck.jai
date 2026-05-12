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

	memoryless: bool;
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
	resolved_type: *Resolved_Type;
	name: string;
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

	_enums: Table(string, int);

	current_function_return_type: *Resolved_Type;

	// HACK(Oliver): Expect to have more of these...
	filename: string;

	// Put more info in this
	errors: [..]string;
}

current_scope :: (tc: *Type_Checker) -> *Scope {
	assert(tc.scopes.count > 0);
	return *tc.scopes[tc.scopes.count - 1];
}

push_scope :: (tc: *Type_Checker) {
	scope: Scope;
	array_add(*tc.scopes, scope);
}

push_decl :: (tc: *Type_Checker,  declarator: *Node_Declarator) {
	scope := current_scope(tc);
	decl: Decl;
	decl.resolved_type = declarator.resolved_type;
	decl.name = identifier_from_declarator(declarator);
	array_add(*scope.decls, decl);
}

push_decl :: (tc: *Type_Checker, name: string, resolved_type: *Resolved_Type) {
	scope := current_scope(tc);
	decl: Decl;
	decl.resolved_type = resolved_type;
	decl.name = name;
	array_add(*scope.decls, decl);
}

enum_constant_type :: () -> *Resolved_Type {
	info := New(Resolved_Type);
	info.kind = .Integral;
	info.size_in_bytes = 4;
	info.alignment = 4;
	info.memoryless = true;
	return info;
}

constant_to_int :: (constant: Constant) -> int {
	if constant.kind == .S64 return constant.as_s64.(int);
	if constant.kind == .U64 return constant.as_s64.(int);
	return constant.as_f64.(int);
}

resolve_enum_members :: (tc: *Type_Checker, _enum: *Node_Enum, type: *Resolved_Type) {
	if !_enum return;
	if _enum.members.count > 0 && table_contains(*tc._enums, _enum.members[0].name.view) return;

	next_value := 0;
	for _enum.members {
		value := next_value;
		if it.expr {
			value = constant_to_int(eval_constant_expr(*tc._enums, it.expr));
		}
		table_set(*tc._enums, it.name.view, value);
		push_decl(tc, it.name.view, type);
		next_value = value + 1;
	}
}

seed_builtin_enum_constants :: (tc: *Type_Checker) {
	table_set(*tc._enums, "__ATOMIC_RELAXED", 0);
	table_set(*tc._enums, "__ATOMIC_CONSUME", 1);
	table_set(*tc._enums, "__ATOMIC_ACQUIRE", 2);
	table_set(*tc._enums, "__ATOMIC_RELEASE", 3);
	table_set(*tc._enums, "__ATOMIC_ACQ_REL", 4);
	table_set(*tc._enums, "__ATOMIC_SEQ_CST", 5);
}

Builtin_Param :: struct {
	name: string;
	specifiers: []string;
	pointer: bool;
}

make_builtin_decl :: (
	name: string,
	return_specifiers: []string,
	return_pointer: bool,
	params: []Builtin_Param
) -> *Node_Decl {
	decl := New(Node_Decl);
	for return_specifiers array_add(*decl.specifiers, it);

	ident := New(Node_Identifier_Declarator);
	ident.name = name;

	inner_decl: *Node_Declarator = ident;
	if return_pointer {
		ptr := New(Node_Pointer_Declarator);
		ptr.inner = ident;
		inner_decl = ptr;
	}

	fn := New(Node_Function_Declarator);
	fn.inner = inner_decl;

	for params {
		p := New(Node_Decl);
		for sp: it.specifiers array_add(*p.specifiers, sp);

		pident := New(Node_Identifier_Declarator);
		pident.name = it.name;

		pdecl: *Node_Declarator = pident;
		if it.pointer {
			ptr := New(Node_Pointer_Declarator);
			ptr.inner = pident;
			pdecl = ptr;
		}
		array_add(*p.declarators, pdecl);
		array_add(*fn.params, p);
	}

	array_add(*decl.declarators, fn);
	return decl;
}

register_builtin_decls :: (ordinary: *Table(string, *Node)) {
	INT  :: string.["int"];
	VOID :: string.["void"];
	CHAR :: string.["char"];

	add :: (ordinary: *Table(string, *Node), name: string, ret: []string, ret_ptr: bool, params: []Builtin_Param) #expand {
		decl := make_builtin_decl(name, ret, ret_ptr, params);
		table_set(ordinary, name, decl);
	}

	add(ordinary, "__c11_atomic_load", INT, false, .[
		.{ "ptr",   INT, true  },
		.{ "order", INT, false },
	]);

	add(ordinary, "__c11_atomic_store", VOID, false, .[
		.{ "ptr",   INT, true  },
		.{ "val",   INT, false },
		.{ "order", INT, false },
	]);

	add(ordinary, "__c11_atomic_fetch_add", INT, false, .[
		.{ "ptr",   INT, true  },
		.{ "val",   INT, false },
		.{ "order", INT, false },
	]);

	add(ordinary, "__builtin_va_start", VOID, false, .[
		.{ "ap",   CHAR, true  },
		.{ "last", INT,  false },
	]);

	add(ordinary, "__builtin_va_end", VOID, false, .[
		.{ "ap", CHAR, true },
	]);

	add(ordinary, "__builtin_va_copy", VOID, false, .[
		.{ "dst", CHAR, true },
		.{ "src", CHAR, true },
	]);
}

register_builtin_typedefs :: (typedefs: *Table(string, *Node_Decl)) {
	// __builtin_va_list = char *
	decl := New(Node_Decl);
	decl.storage_class = "typedef";
	array_add(*decl.specifiers, "char");

	ident := New(Node_Identifier_Declarator);
	ident.name = "__builtin_va_list";

	ptr := New(Node_Pointer_Declarator);
	ptr.inner = ident;

	array_add(*decl.declarators, ptr);
	table_set(typedefs, "__builtin_va_list", decl);
}

pop_scope :: (tc: *Type_Checker) {
	assert(tc.scopes.count > 0);
	tc.scopes.count -= 1;
}

find_decl_in_scope :: (tc: *Type_Checker, name: string) -> bool, Decl {
	scope_index := tc.scopes.count - 1;
	while scope_index >= 0 {
		for tc.scopes[scope_index].decls {
			if it.name == name return true, it;
		}
		scope_index -= 1;
	}
	return false, .{};
}

// HACK(Oliver): weird
__poison_type: Resolved_Type;
poison_type :: () -> *Resolved_Type {
	return *__poison_type;
}

copy_type :: (type: *Resolved_Type) -> *Resolved_Type {
	if !type || type == poison_type() return type;
	result := New(Resolved_Type);
	result.* = type.*;
	return result;
}

find_typedef_declarator :: (decl: *Node_Decl, name: string) -> *Node_Declarator {
	if !decl return null;
	for declarator: decl.declarators {
		if name == "" || identifier_from_declarator(declarator) == name {
			return declarator;
		}
	}
	return null;
}

resolve_typedef :: (tc: *Type_Checker, decl_info: Node_Decl_Info) -> *Resolved_Type {
	declarator := find_typedef_declarator(decl_info.typedef, decl_info.typedef_name);
	if !declarator return poison_type();

	base := resolve_base(tc, decl_info.typedef.base);
	type := resolve_declarator(tc, base, declarator);
	type = copy_type(type);
	if decl_info.typedef_name {
		type.symbol_name = decl_info.typedef_name;
	}
	return type;
}

resolve_base :: (tc: *Type_Checker, decl_info: Node_Decl_Info) -> *Resolved_Type {
	if decl_info.typedef {
		return resolve_typedef(tc, decl_info);
	}
	// _Atomic(T) wraps the inner type in decl_info.atomic. Resolve the inner
	// type and stamp atomic = true so the real size/signedness flows through.
	if decl_info.atomic {
		inner := resolve_base(tc, decl_info.atomic.*);
		if inner && inner != poison_type() {
			result := copy_type(inner);
			result.atomic = true;
			return result;
		}
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
			case "void";     counts[Type_Specifier.Void] += 1;
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
	info.alignment     = 4;

	if counts[Type_Specifier.Void] {
		info.size_in_bytes = 0;
		info.alignment = 1;
		info.memoryless = true;
	}

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

	if counts[Type_Specifier.Long] == 1 {
		// On Darwin / Linux arm64 LP64, `long` is 8 bytes.
		info.size_in_bytes = 8;
		info.alignment = 8;
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
					if member_type.alignment > 0 && offset % member_type.alignment != 0 {
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

	if decl_info._enum {
		info.kind = .Integral;
		info.size_in_bytes = 4;
		info.alignment = 4;
		resolve_enum_members(tc, decl_info._enum, info);
	}

	return info;
}

resolve_declarator :: (tc: *Type_Checker, base: *Resolved_Type, declarator: *Node_Declarator) -> *Resolved_Type {
	if !declarator return base;

	if declarator.declarator_type == {
		case Node_Pointer_Declarator;
			ptr := New(Resolved_Type);
			ptr.kind = .Pointer;
			ptr.size_in_bytes = 8;
			ptr.inner = base;
			ptr.alignment = 8;
			return resolve_declarator(tc, ptr, declarator.inner);
		case Node_Array_Declarator;
			array_declarator := declarator.(*Node_Array_Declarator);
			inner := resolve_declarator(tc, base, declarator.inner);
			if array_declarator.count_expr {
				array_declarator.count_expr.resolved_type = resolve_expr(tc, array_declarator.count_expr);
				array_declarator.count = constant_to_int(eval_constant_expr(*tc._enums, array_declarator.count_expr));
			}
			array := New(Resolved_Type);
			array.kind = .Array;
			array.size_in_bytes = inner.size_in_bytes * array_declarator.count;
			array.inner = inner;
			array.array_count = array_declarator.count;
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
	if !decl return poison_type();

	base_info := resolve_base(tc, decl.base);
	base_info = resolve_declarator(tc, base_info, declarator);

	return base_info;
}

resolve_decl :: (tc: *Type_Checker, base: *Node_Decl_Info, declarator: *Node_Declarator) -> *Resolved_Type {
	if !base return poison_type();

	base_info := resolve_base(tc, base);
	base_info = resolve_declarator(tc, base_info, declarator);


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
	resolved := poison_type();
	if is_void_type(a) && is_void_type(b) {
		resolved = a;
	} else if a.kind == .Array || b.kind == .Array {
		resolved = New(Resolved_Type);
		resolved.kind = .Pointer;
		resolved.size_in_bytes = 8;
		resolved.alignment = 8;
		resolved.unsigned = true;
		if a.kind == .Array {
			resolved.inner = a.inner;
		} else {
			resolved.inner = b.inner;
		}
	} else if a.kind == .Floating || b.kind == .Floating {
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
	} else if a.kind == .Pointer && b.kind == .Integral {
		resolved = New(Resolved_Type);
		resolved.* = a.*;
	} else if b.kind == .Pointer && a.kind == .Integral {
		resolved = New(Resolved_Type);
		resolved.* = b.*;
	} else if a.kind == .Pointer && b.kind == .Pointer {
		resolved = New(Resolved_Type);
		resolved.alignment = 8;
		resolved.size_in_bytes = 8;
		resolved.unsigned = true;
	}
	
	return resolved;
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
	info.memoryless = true;
	return info;
}

coerceable :: (target: *Resolved_Type, source: *Resolved_Type) -> bool {
	if target == poison_type() || source == poison_type() return false;
	if !target || !source return false;

	if is_void_type(target) && source.kind == .Pointer return true;

	if target.kind == .Integral && source.kind == .Integral return true;
	if target.kind == .Floating && source.kind == .Floating return true;
	if target.kind == .Integral && source.kind == .Floating return true;
	if target.kind == .Floating && source.kind == .Integral return true;

	if target.kind == .Pointer && source.kind == .Pointer return true; 
	if target.kind == .Pointer && source.kind == .Integral return true;
	if target.kind == .Integral && source.kind == .Pointer return true;
	if target.kind == .Pointer && source.kind == .Array return true;

	if target.kind == .Composite && source.kind == .Composite {
		return target.composite == source.composite;
	}

	return false;
}

normalise_function_call_type :: (type: *Resolved_Type) -> *Resolved_Type {
	if !type || type == poison_type() return type;
	if type.kind != .Array return type;

	ptr := New(Resolved_Type);
	ptr.kind = .Pointer;
	ptr.size_in_bytes = 8;
	ptr.alignment = 8;
	ptr.unsigned = true;
	ptr.inner = type.inner;
	return ptr;
}

resolve_function_call_param_type :: (tc: *Type_Checker, param: *Node_Decl) -> *Resolved_Type {
	param_type: *Resolved_Type;
	if param.declarators.count > 0 {
		param_type = resolve_decl(tc, *param.base, param.declarators[0]);
	} else {
		param_type = resolve_base(tc, param.base);
	}
	return normalise_function_call_type(param_type);
}

function_declarator :: (declarator: *Node_Declarator) -> *Node_Function_Declarator {
	result := declarator;
	while result && result.declarator_type != Node_Function_Declarator {
		result = result.inner;
	}
	assert(result.declarator_type == Node_Function_Declarator);
	return result.(*Node_Function_Declarator);
}

report_error :: (tc: *Type_Checker, line: int, col: int, fmt: string, args: ..Any) {
	report_error_at(tc, tc.filename, line, col, fmt, ..args);
}

report_error_at :: (tc: *Type_Checker, source_path: string, line: int, col: int, fmt: string, args: ..Any) {
	error := tprint(fmt, ..args);
	filename := ifx source_path.count > 0 then source_path else tc.filename;
	array_add(*tc.errors, tprint("%: %:%:%: %", colour("ERROR", .RED), filename, line, col, error));
}

report_error :: (tc: *Type_Checker, fmt: string, args: ..Any) {
	error := tprint(fmt, ..args);
	array_add(*tc.errors, tprint("%: %", colour("ERROR", .RED), error));
} 

resolve_expr :: (tc: *Type_Checker, expr: *Node_Expr, sizeof := false) -> *Resolved_Type {
	if !expr return poison_type();
	if expr.expr_type == {
		case Node_Ternary;
			ternary := expr.(*Node_Ternary);
			resolve_expr(tc, ternary.cond);
			on_true := resolve_expr(tc, ternary.on_true);
			on_false := resolve_expr(tc, ternary.on_false);
			if on_true.kind == .Pointer || on_false.kind == .Pointer {
				if on_true.kind == .Pointer {
					expr.resolved_type = on_true;
				} else {
					expr.resolved_type = on_false;
				}
				return expr.resolved_type;
			}

			ternary.on_true.resolved_type = on_true;
			ternary.on_false.resolved_type = on_false;

			if on_true.kind == .Composite && on_false.kind == .Composite {
				assert(on_true.composite == on_false.composite);
				expr.resolved_type = on_true;
				return on_true;
			}

			resolved_type := common_type(on_true, on_false);
			if resolved_type == poison_type() {
				report_error_at(tc, expr.source_path, expr.line, expr.col, "Unable to operate on types");
				return resolved_type;
			}

			if !coerceable(on_true, resolved_type) {
				report_error_at(tc, expr.source_path, expr.line, expr.col, "Couldnt convert % to %", on_true.*, resolved_type.*);
			}
			if !coerceable(on_false, resolved_type) {
				report_error(tc, "Couldnt convert ternary % to %", on_false.*, resolved_type.*);
			}

			expr.resolved_type = resolved_type;
			return resolved_type;
		case Node_Sizeof_Expr;
			sizeof := expr.(*Node_Sizeof_Expr);
			resolved := New(Resolved_Type);
			resolved.kind = .Integral;
			resolved.size_in_bytes = 8;
			resolved.unsigned = true;
			resolved.alignment = 8;
			sizeof.resolved_type = resolved;
			sizeof.expr.resolved_type = resolve_expr(tc, sizeof.expr, true);
			return resolved;
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
			return resolved;
		case Node_Compound;
			compound := expr.(*Node_Compound);
			compound.resolved_type = resolve_decl(tc, *compound.base_info, compound.declarator);
			resolve_initializer(tc, compound.resolved_type, compound.init);
			return compound.resolved_type;
		case Node_Assign;
			assign := expr.(*Node_Assign);
			if assign.op.line == 438 && assign.op.col == 22 {
				a := 5;
			}
			left_info := resolve_expr(tc, assign.left);
			right_info := resolve_expr(tc, assign.right);
			
			if !coerceable(left_info, right_info) {
				return null;
			}

			assign.left.resolved_type = left_info;
			assign.resolved_type = left_info;
			return left_info;
			case Node_Binary;
				binary := expr.(*Node_Binary);
				left_info := resolve_expr(tc, binary.left);
				right_info := resolve_expr(tc, binary.right);

				if binary.op.type == .Comma {
					binary.resolved_type = right_info;
					return right_info;
				}

				resolved_type := common_type(left_info, right_info);
				if resolved_type == poison_type() {
					report_error_at(tc, expr.source_path, expr.line, expr.col, "Unable to operate on types");
					return resolved_type;
			}

			if binary.op.type == {
				case .Less; #through;
				case .Greater; #through;
				case .LessEqual; #through;
				case .GreaterEqual; #through;
				case .EqualEqual; #through;
				case .AmpersandAmpersand; #through;
				case .BangEqual;
					comparison_result := New(Resolved_Type);
					comparison_result.kind = .Integral;
					comparison_result.size_in_bytes = 4;
					comparison_result.alignment = 4;
					resolved_type = comparison_result;
			}
			binary.resolved_type = resolved_type;
			return resolved_type;
		case Node_Number;
			info := resolve_number(expr.(*Node_Number));
			expr.(*Node_Number).resolved_type = info;
			return info;
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
						return member_access.resolved_type;
					}
				}
			}
		case Node_Array_Access;
		array_access := expr.(*Node_Array_Access);
			array_access.left.resolved_type = resolve_expr(tc, array_access.left);
			array_access.index.resolved_type = resolve_expr(tc, array_access.index);
			array_access.resolved_type = array_access.left.resolved_type.inner;
			if array_access.index.resolved_type.kind != .Integral {
				report_error_at(tc, expr.source_path, expr.line, expr.col, "Array subscript index must be integer");
				return poison_type();
			}
			return array_access.left.resolved_type.inner;
		case Node_Identifier;
			id := expr.(*Node_Identifier).id.view;
			found, decl := find_decl_in_scope(tc, id);
			if !found {
				found_enum, _ := table_find(*tc._enums, id);
				if found_enum {
					expr.resolved_type = enum_constant_type();
					return expr.resolved_type;
				}
			}
			assert(found);
			expr.resolved_type = decl.resolved_type;
			if !sizeof && expr.resolved_type.kind == .Array {
				expr.resolved_type = New(Resolved_Type);
				expr.resolved_type.kind = .Pointer;
				expr.resolved_type.alignment = 8;
				expr.resolved_type.size_in_bytes = 8;
				expr.resolved_type.inner = decl.resolved_type.inner;
				expr.resolved_type.unsigned = true;
			}
			return expr.resolved_type;
		case Node_Unary;
			info := resolve_expr(tc, expr.(*Node_Unary).expr);
			if expr.(*Node_Unary).op.type == {
				case .Ampersand;
					if info.memoryless {
						report_error_at(tc, expr.source_path, expr.line, expr.col, "Unable to take address of type");
						return poison_type();
					}
					if info.kind == .Array {
						decay := New(Resolved_Type);
						decay.kind = .Pointer;
						decay.size_in_bytes = 8;
						decay.alignment = 8;
						decay.inner = decay.inner;
						decay.unsigned = true;
						info = decay;
					} else {
						inner := info;
						info = New(Resolved_Type);
						info.kind = .Pointer;
						info.size_in_bytes = 8;
						info.alignment = 8;
						info.inner = inner;
						info.unsigned = true;
					}
				case .Asterisk;
					if info.memoryless {
						report_error_at(tc, expr.source_path, expr.line, expr.col, "Unable to deference non-addressable type");
						return poison_type();
					}
					info = info.inner;
				case .Bang;  #through;
				case .Minus; #through;
				case .Plus;  #through;
				case .Tilde; #through;
				case .Caret;
					if info.composite && info.composite.type == Node_Struct {
						report_error_at(tc, expr.source_path, expr.line, expr.col, "Right hand side type cannot be a struct");
					}
			}
			expr.resolved_type = info;
			return info;
		case Node_Cast;
			_cast := expr.(*Node_Cast);
			source := resolve_expr(tc, _cast.expr);
			declarator := ifx _cast.base.declarators.count > 0 then _cast.base.declarators[0] else null;
			target := resolve_decl(tc, *_cast.base, declarator);
			_cast.resolved_type = target;
			_cast.expr.resolved_type = source;
			return target;
		case Node_String;
			info := New(Resolved_Type);
			info.size_in_bytes = 8;
			info.alignment = 8;
			info.kind = .Pointer;
			expr.resolved_type = info;
			return info;
		case Node_Char;
			info := New(Resolved_Type);
			info.size_in_bytes = 4;
			info.alignment = 4;
			info.kind = .Integral;
			expr.resolved_type = info;
			return info;
		case Node_Call;
			call := expr.(*Node_Call);
			name := call.id.(*Node_Identifier).id.view;
			found, decl := table_find(*tc.ordinary, name);
			if !found {
				report_error_at(tc, call.id.source_path, call.id.line, call.id.col, "Could not find variable '%'", name);
				return poison_type();
			}
			function := function_declarator(decl.(*Node_Decl).declarators[0]);
			
			for call.args {
				arg_type := resolve_expr(tc, it);
				it.resolved_type = arg_type;
				
				if it_index < function.params.count - 1 {
					param := function.params[it_index];
					param_type := resolve_function_call_param_type(tc, param);
					if !coerceable(param_type, arg_type) {
						report_error_at(tc, it.source_path, it.line, it.col, "Argument '%' does not match parameter", 1 + it_index);
					}
				}
			}
			
			ret_type := resolve_decl(tc, decl.(*Node_Decl), decl.(*Node_Decl).declarators[0]);
			call.resolved_type = ret_type;
			return ret_type;
	}

	return null;
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
			if ret.expr {
				ret.expr.resolved_type = resolve_expr(tc, ret.expr);
				if !coerceable(ret.expr.resolved_type, tc.current_function_return_type) {
					report_error_at(tc, ret.source_path, ret.line, ret.col, "Expression doesn't match return type");
				}
			}
			case Node_Decl_Statement;
				decl := stmt.(*Node_Decl_Statement).decl;
				for decl.declarators {
					lhs := resolve_decl(tc, decl, it);
					it.resolved_type = lhs;
					resolve_initializer(tc, lhs, it.init);
					push_decl(tc, it);
				}
			case Node_Static_Assert;
				static_assert := stmt.(*Node_Static_Assert);
				static_assert.expr.resolved_type = resolve_expr(tc, static_assert.expr);
				constant := eval_constant_expr(*tc._enums, static_assert.expr);
				if constant.kind == {
					case .F64;
						if !constant.as_f64 {
							report_error_at(tc, static_assert.source_path, static_assert.line, static_assert.col, "Static assert failed: %", static_assert.message.view);
						}
					case .S64;
						if !constant.as_s64 {
							report_error_at(tc, static_assert.source_path, static_assert.line, static_assert.col, "Static assert failed: %", static_assert.message.view);
						}
					case .U64;
						if !constant.as_u64 {
							report_error_at(tc, static_assert.source_path, static_assert.line, static_assert.col, "Static assert failed: %", static_assert.message.view);
						}
				}
				// TODO: evaluate the integer constant expression and report
				// an error using static_assert.message when it is false.
			case Node_For;
				_for := stmt.(*Node_For);
			typecheck_statement(tc, _for.init);
			resolve_expr(tc, _for.cond);
			resolve_expr(tc, _for.expr);
			typecheck_statement(tc, _for.body);
		case Node_Switch;
			switch := stmt.(*Node_Switch);
			resolve_expr(tc, switch.expr);
			typecheck_statement(tc, switch.body);
		case Node_Case;
			_case := stmt.(*Node_Case);
			resolve_expr(tc, _case.expr);
			typecheck_statement(tc, _case.statement);
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
	//report_error(tc, "Couldnt find member '%' from srtuct '%'", name, _struct.name.view);
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
	report_error(tc, "Couldnt find member from index '%'", index);
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
								constant_index := eval_constant_expr(*tc._enums, array.index);
								if constant_index.kind == .S64 {
									index = constant_index.as_s64.(s64);
								} else if constant_index.kind == .U64 {
									index = constant_index.as_u64.(s64);
								} else {
									report_error_at(tc, it.source_path, it.line, it.col, "Designator index must be integer");
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
					}
				}
				designation.byte_offset = offset;
				designation.target_resolved_type = type;
				designation.resolved_type = resolve_initializer(tc, type, designation.expr);
				index += 1;
			}
		case Node_Scalar_Initializer;
			scalar := init.(*Node_Scalar_Initializer).expr;
			expr_type := resolve_expr(tc, scalar);
			if expr_type == poison_type() { return poison_type(); }
			if !coerceable(target, expr_type) {
				report_error_at(tc, init.source_path, init.line, init.col, "does not match type");
			}
	}
	return target;
}

typecheck_decl :: (tc: *Type_Checker, decl: *Node_Decl) {
	if !decl return;
	if decl.declarators.count == 0 {
		resolve_base(tc, decl.base);
		return;
	}
	for declarator: decl.declarators {
		decl_type := resolve_decl(tc, decl, declarator);
		declarator.resolved_type = decl_type;
		push_decl(tc, declarator);
		if is_function_declaration(declarator) {
			function := function_declarator(declarator);
			prev_return_type := tc.current_function_return_type;
			tc.current_function_return_type = declarator.resolved_type;
			push_scope(tc);
			if identifier_from_declarator(declarator) == "memset" {
				a := 5;
			}
			for function.params {
				if it.declarators.count {
					it.declarators[0].resolved_type = resolve_decl(tc, it, it.declarators[0]);
					// Unnamed parameters are type information only; named
					// parameters become locals in the function body.
					if identifier_from_declarator(it.declarators[0]) != "" {
						push_decl(tc, it.declarators[0]);
					}
				}
			}
			typecheck_statement(tc, decl.body);
			pop_scope(tc);
			tc.current_function_return_type = prev_return_type;
		}
		resolve_initializer(tc, decl_type, declarator.init);
	}
}

typecheck :: (tc: *Type_Checker, tu: *Node_Translation_Unit) -> bool {
	seed_builtin_enum_constants(tc);
	push_scope(tc);
	for item: tu.items {
		if item.type == {
			case Node_Decl;
				typecheck_decl(tc, item.(*Node_Decl));
			case Node_Static_Assert;
				static_assert := item.(*Node_Static_Assert);
				static_assert.expr.resolved_type = resolve_expr(tc, static_assert.expr);
				// TODO: evaluate the integer constant expression and report
				// an error using static_assert.message when it is false.
		}
	}
	pop_scope(tc);

	for tc.errors {
		print(it);
		print("\n");
	}

	return tc.errors.count == 0;
}
