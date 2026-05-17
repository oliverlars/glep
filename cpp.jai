Object :: struct {
	tokens: [..]Token;
}

Function :: struct {
	variadic: bool;
	params: [..]Token;
	tokens: [..]Token;
}
Cursor :: struct {
	at: int;
}

PRAGMA_ONCED :: #type,distinct bool;

Preprocessor :: struct {
	at: int;
	path_stack: [..]string;
	line: int;
	cond_stack: [..]Cond_State;
	objects: Table(string, Object);
	functions: Table(string, Function);
	expand_count: int;
	includes: Table(string, PRAGMA_ONCED);
	include_paths: [..]string;
	framework_paths: [..]string;
}

Cond_State :: struct {
	branch_taken: bool;
}
	
push_cond :: (cpp: *Preprocessor, state: bool) #expand {
	array_add(*cpp.cond_stack, .{state});
}
pop_cond :: (cpp: *Preprocessor) {
	assert(cpp.cond_stack.count > 0);
	cpp.cond_stack.count -= 1;
}

current :: (cpp: *Preprocessor, src_tokens: [..]Token) -> Token { 
	token := src_tokens[cpp.at];
	return token;
}
next :: (cpp: *Preprocessor, src_tokens: [..]Token) -> Token { return src_tokens[cpp.at + 1]; }
peek :: (cpp: *Preprocessor, src_tokens: [..]Token, amount := 0) -> Token { return src_tokens[min(src_tokens.count - 1, cpp.at + amount)]; }
skip :: (cpp: *Preprocessor, src_tokens: [..]Token) -> Token { 
	result := src_tokens[cpp.at];
	cpp.at += 1;
	return result;
}

paste :: (cpp: *Preprocessor, src_tokens: [..]Token, dst_tokens: *[..]Token) {
	token := skip(cpp, src_tokens);
	array_add(dst_tokens, token);
}

insert :: (cpp: *Preprocessor, token: Token, dst_tokens: *[..]Token) {
	array_add(dst_tokens, token);
}

add_builtin_object :: (cpp: *Preprocessor, builtin: string, body: string) {
	object: Object;
	tokeniser: Tokeniser;
	tokeniser.source = body;
	tokeniser.source_path = tprint("<builtin object %>", builtin);
	tokenise(*tokeniser);
	for tokeniser.tokens {
		array_add(*object.tokens, it);
	}
	table_add(*cpp.objects, builtin, object);
}

// HACK(Oliver): this is kinda dumb
add_function_builtin :: (cpp: *Preprocessor, macro: string) {
	tokeniser: Tokeniser;
	tokeniser.source = macro;
	tokeniser.source_path = tprint("<builtin macro %>", macro);
	tokenise(*tokeniser);
	cpp.at = 0;
	preprocess(cpp, tokeniser.tokens);
}

trim_command_output :: (s: string) -> string {
	start := 0;
	while start < s.count && (s[start] == #char " " || s[start] == #char "\t" || s[start] == #char "\n" || s[start] == #char "\r") {
		start += 1;
	}

	end := s.count;
	while end > start && (s[end - 1] == #char " " || s[end - 1] == #char "\t" || s[end - 1] == #char "\n" || s[end - 1] == #char "\r") {
		end -= 1;
	}

	result: string;
	result.data = s.data + start;
	result.count = end - start;
	return result;
}

dirname :: (path: string) -> string {
	end := path.count;
	while end > 0 && path[end - 1] != #char "/" {
		end -= 1;
	}
	if end > 0 then end -= 1;

	result: string;
	result.data = path.data;
	result.count = end;
	return result;
}

command_output :: (command: string) -> string {
	result, stdout, stderr := run_command("sh", "-c", command, capture_and_return_output = true);
	if result.exit_code != 0 {
		if stderr.count > 0 print("%", stderr);
		return "";
	}
	return trim_command_output(stdout);
}

add_include_path :: (paths: *[..]string, path: string) {
	if path.count == 0 return;
	for paths.* {
		if it == path return;
	}
	array_add(paths, copy_string(path));
}

configure_system_include_paths :: (cpp: *Preprocessor) {
	sdk_path := command_output("xcrun --sdk macosx --show-sdk-path");
	clang_path := command_output("xcrun --find clang");
	resource_dir := "";
	if clang_path.count > 0 {
		resource_dir = command_output(tprint("'%' -print-resource-dir", clang_path));
	}
	if resource_dir.count == 0 {
		resource_dir = command_output("clang -print-resource-dir");
	}
	toolchain_usr := dirname(dirname(clang_path));

	add_include_path(*cpp.include_paths, "/usr/local/include");
	if sdk_path.count > 0 {
		add_include_path(*cpp.include_paths, tprint("%/usr/local/include", sdk_path));
	}
	if resource_dir.count > 0 {
		add_include_path(*cpp.include_paths, tprint("%/include", resource_dir));
	}
	if sdk_path.count > 0 {
		add_include_path(*cpp.include_paths, tprint("%/usr/include", sdk_path));
	}
	if toolchain_usr.count > 0 {
		add_include_path(*cpp.include_paths, tprint("%/include", toolchain_usr));
	}
	if sdk_path.count > 0 {
		add_include_path(*cpp.framework_paths, tprint("%/System/Library/Frameworks", sdk_path));
		add_include_path(*cpp.framework_paths, tprint("%/System/Library/SubFrameworks", sdk_path));
		add_include_path(*cpp.framework_paths, tprint("%/Library/Frameworks", sdk_path));
	}
}

resolve_framework_include :: (cpp: *Preprocessor, include_path: string) -> string {
	slash := -1;
	for i: 0..include_path.count-1 {
		if include_path[i] == #char "/" {
			slash = i;
			break;
		}
	}
	if slash < 0 return "";

	framework: string;
	framework.data = include_path.data;
	framework.count = slash;

	header: string;
	header.data = include_path.data + slash + 1;
	header.count = include_path.count - slash - 1;

	for cpp.framework_paths {
		full_path := tprint("%/%.framework/Headers/%", it, framework, header);
		if file_exists(full_path) return full_path;
	}

	return "";
}

resolve_system_include :: (cpp: *Preprocessor, include_path: string) -> string {
	for cpp.include_paths {
		full_path := tprint("%/%", it, include_path);
		if file_exists(full_path) return full_path;
	}

	return resolve_framework_include(cpp, include_path);
}

in_hideset :: (hideset: [..]string, name: string) -> bool {
	for hideset {
		if name == it {
			return true;
		}
	}
	return false;
}

hideset_union :: (a: [..]string, b: [..]string) -> [..]string {
	result: [..]string;
	for a {
		array_add(*result, it);
	}
	for b {
		array_add(*result, it);
	}
	return result;
}

hideset_union :: (a: [..]string, name: string) -> [..]string {
	result: [..]string;
	for a {
		array_add(*result, it);
	}
	array_add(*result, name);
	return result;
}

hideset_intersect :: (a: [..]string, b: [..]string) -> [..]string {
	result: [..]string;
	for a {
		if in_hideset(b, it) {
			array_add(*result, it);
		}
	}
	return result;
}

glue_tokens :: (left: Token, right: Token) -> Token {
	glued: Token;
	glued.type = .Identifier;
	glued.view = join(left.view, right.view);
	glued.hideset = hideset_intersect(left.hideset, right.hideset);
	glued.source_path = left.source_path;
	glued.line = left.line;
	glued.col = left.col;
	return glued;
}

subst :: (cpp: *Preprocessor, body: [..]Token, params: [..]Token, args: [..][..]Token, va_args: [..]Token) -> [..]Token {
	result: [..]Token;

	find_arg :: (params: [..]Token, args: [..][..]Token, token: Token) -> bool, int {
		found := false;
		index := 0;
		for param, param_index: params {
			if param.view == token.view {
				index = param_index;
				found = true;
				break;
			}
		}
		return found, index;
	}
	at := 0;
	while at < body.count {
		it := body[at];

		if it.view == "__LINE__" {
			line: Token;
			line.view = tprint("%", cpp.line);
			line.type = .Number;
			line.number_type = .Decimal;
			line.source_path = peek(cpp.path_stack);
			line.line = cpp.line;
			array_add(*result, line);
			at += 1;
			continue;
		} else if it.view == "__FILE__" {
			file: Token;
			file.view = peek(cpp.path_stack);
			file.type = .String;
			file.source_path = peek(cpp.path_stack);
			file.line = cpp.line;
			array_add(*result, file);
			at += 1;
			continue;
		}

		if it.type == .Hash {
			found, index := find_arg(params, args, body[at + 1]);
			stringed: Token;
			stringed.type = .String;
			stringed.source_path = it.source_path;
			stringed.line = it.line;
			stringed.col = it.col;
			view: string;
			if found {
				for args[index] {
					view = join(view, it.view);
				}
			} else {
				assert(body[at + 1].view == "__VA_ARGS__");
				for va_args {
					view = join(view, it.view);
				}
			}
			stringed.view = view;
			array_add(*result, stringed);
			at += 2;
			continue;
		} else if at + 2 < body.count && body[at].type == .Comma &&
				  body[at + 1].type == .HashHash &&
				  body[at + 2].view == "__VA_ARGS__" {
			if va_args.count == 0 {
				at += 3;
				continue;
			} else {
				found_va, index_va := find_arg(params, args, body[at]);
				array_add(*result, body[at]);
				for va_arg: va_args {
					array_add(*result, va_arg);
				}
				at += 3;
				continue;
			}
		} else if at + 1 < body.count && body[at + 1].type == .HashHash {
			left_tokens: [..]Token;
			found_left, index_left := find_arg(params, args, body[at]);
			if found_left {
				left_tokens = args[index_left];
			} else {
				array_add(*left_tokens, body[at]);
			}

			right_tokens: [..]Token;
			found_right, index_right := find_arg(params, args, body[at + 2]);
			if found_right {
				right_tokens = args[index_right];
			} else if body[at + 2].view == "__VA_ARGS__" {
				right_tokens = va_args;
			} else {
				array_add(*right_tokens, body[at + 2]);
			}

			if left_tokens.count >= 2 { 
				for i: 0..left_tokens.count - 2 {
					array_add(*result, left_tokens[i]);
				}
			}
			
			glued := glue_tokens(left_tokens[left_tokens.count - 1], right_tokens[0]);
			array_add(*result, glued);
			
			if right_tokens.count >= 2 {
				for i: 1..right_tokens.count - 1 {
					array_add(*result, right_tokens[i]);
				}
			}

			at += 3;
			continue;
		}

		matched_param, param_index := find_arg(params, args, it);
		if matched_param {
			expanded_arg := expand(cpp, args[param_index]);
			for arg: expanded_arg {
				array_add(*result, arg);
			}
			at += 1;
			continue;
		}

		if it.view == "__VA_ARGS__" {
			expanded_va := expand(cpp, va_args);
			for va: expanded_va {
				array_add(*result, va);
			}
			at += 1;
			continue;
		}

		array_add(*result, it);
		at += 1;
	}
	return result;
}

expand :: (cpp: *Preprocessor, tokens: [..]Token) -> [..]Token {
	result: [..]Token;
	at := 0;
	while at < tokens.count {
		token := tokens[at];
		
		if token.type == .Identifier {
			function := table_find_pointer(*cpp.functions, token.view);
			object := table_find_pointer(*cpp.objects, token.view);

			if function && !in_hideset(token.hideset, token.view) && 
			at + 1 < tokens.count && tokens[at + 1].type == .LeftParenthesis {
				at += 1; // Identifier
				at += 1; // Left parenthesis
				
				args: [..][..]Token;
				while tokens[at].type != .RightParenthesis {
					arg_tokens: [..]Token;
					paren_depth := 0;
					while true {
						if tokens[at].type == .LeftParenthesis {
							array_add(*arg_tokens, tokens[at]);
							at += 1;
							paren_depth += 1;
						} else if tokens[at].type == .RightParenthesis {
							if paren_depth == 0 break;
							paren_depth -= 1;
							array_add(*arg_tokens, tokens[at]);
							at += 1;
						} else if tokens[at].type == .Comma && paren_depth == 0 {
							break;
						} else {
							array_add(*arg_tokens, tokens[at]);
							at += 1;
						}
					}
					array_add(*args, arg_tokens);
					if tokens[at].type == .Comma {
						at += 1;
					}
				}

				va_args: [..]Token;
				if function.variadic {
					for function.params.count..args.count-1 {
						if va_args.count > 0 {
							comma: Token;
							comma.view = ",";
							comma.type = .Comma;
							array_add(*va_args, comma);
						}
						for args[it] {
							array_add(*va_args, it);
						}
					}
				}

				rparen_hs := tokens[at].hideset;
				at += 1; // Right parenthesis

				hideset := hideset_intersect(rparen_hs, token.hideset);
				hideset = hideset_union(hideset, token.view);


				body := subst(cpp, function.tokens, function.params, args, va_args);
				//print("BODY: ");
				for * body {
					it.hideset = hideset_union(it.hideset, hideset);
					//print("% ", it.view);
				}
				//print("\n");
				
				expanded := expand(cpp, body);
				//print("EXPANDED: ");
				for expanded {
					array_add(*result, it);
					//print("%", it.view);
				}
				//print("\n");
			} else if object && !in_hideset(token.hideset, token.view) {
				at += 1;
				hideset := hideset_union(token.hideset, token.view);
				
				body: [..]Token;
				for object.tokens {
					copy := it;
					copy.hideset = hideset_union(it.hideset, hideset);
					array_add(*body, copy);
				}
				
				expanded := expand(cpp, body);
				for expanded {
					array_add(*result, it);
				}
			} else if token.view == "__LINE__" {
				line: Token;
				line.view = tprint("%", cpp.line);
				line.type = .Number;
				line.number_type = .Decimal;
				line.source_path = token.source_path;
				line.line = token.line;
				line.col = token.col;
				array_add(*result, line);
				at += 1;
			} else if token.view == "__FILE__" {
				file: Token;
				file.view = peek(cpp.path_stack);
				file.type = .String;
				file.source_path = token.source_path;
				file.line = token.line;
				file.col = token.col;
				array_add(*result, file);
				at += 1;
			} else {
				array_add(*result, token);
				at += 1;
			}
		} else {
			array_add(*result, token);
			at += 1;
		}
	}
	return result;
}

eval_unary :: (cpp: *Preprocessor, tokens: [..]Token, at: *int) -> int {
	op := tokens[at.*];
	unary: int;
	if op.type == {
		case .Identifier;
			if op.view == "defined" {
				at.* += 1;
				if tokens[at.*].type == .LeftParenthesis {
					at.* += 1;
					name := tokens[at.*];
					at.* += 1;
					unary = table_contains(*cpp.functions, name.view).(int);
					unary |= table_contains(*cpp.objects, name.view).(int);
					at.* += 1;
				} else {
					name := tokens[at.*];
					at.* += 1;
					unary = table_contains(*cpp.functions, name.view).(int);
					unary |= table_contains(*cpp.objects, name.view).(int);
				}
			} else {
				unary = 0;
				at.* += 1;
			}
		case .LeftParenthesis;
			at.* += 1; // '('
			unary = eval(cpp, tokens, at);
			at.* += 1; // ')'
		case .Minus;
			at.* += 1;
			unary = -eval_unary(cpp, tokens, at);
		case .Plus;
			at.* += 1;
			unary = +eval_unary(cpp, tokens, at);
		case .Bang;
			at.* += 1;
			unary = xx (!eval_unary(cpp, tokens, at));
		case .Tilde;
			at.* += 1;
			unary = ~eval_unary(cpp, tokens, at);
		case .Char;
			for tokens[at.*].view {
				unary += it;
			}
			at.* += 1;
		case .Number;
			number := op;
			if number.number_type == {
				case .Invalid;
					assert(false);
				case .Octal;
					unary = string_to_int(number.view, 8, u64).(int);
				case .Decimal;
					unary = string_to_int(number.view, 10, u64).(int);
				case .Hexadecimal;
					unary = string_to_int(number.view, 16, u64).(int);
				case .Float;
					unary = string_to_float(number.view).(int);
				case .Binary;
					unary = string_to_int(number.view, 2).(int);
			}
			at.* += 1;
		case; 
			print("Unexpected unary operator: %\n", op.type);
			assert(false);
	}

	return unary;
}

eval :: (cpp: *Preprocessor, tokens: [..]Token, at: *int, min_prec := 0) -> int {
	lhs := 0;
	lhs = eval_unary(cpp, tokens, at);
	while at.* < tokens.count {
		op := tokens[at.*];
		prec := precedence_of(op);
		if prec < min_prec break;

		if !is_binary_op(op) break;
		at.* += 1;
		next_min := prec + is_left_associative(op).(int);
		if op.type == {
			case .Asterisk;
				lhs = lhs * eval(cpp, tokens, at, next_min);
			case .ForwardSlash;
				lhs = lhs / eval(cpp, tokens, at, next_min);
			case .Plus;
				lhs = lhs + eval(cpp, tokens, at, next_min);
			case .Minus;
				lhs = lhs - eval(cpp, tokens, at, next_min);
			case .LessLess;
				lhs = lhs << eval(cpp, tokens, at, next_min);
			case .GreaterGreater;
				lhs = lhs >> eval(cpp, tokens, at, next_min);
			case .Less;
				lhs = xx (lhs < eval(cpp, tokens, at, next_min));
			case .Greater;
				lhs = xx (lhs > eval(cpp, tokens, at, next_min));
			case .LessEqual;
				lhs = xx (lhs <= eval(cpp, tokens, at, next_min));
			case .GreaterEqual;
				lhs = xx (lhs >= eval(cpp, tokens, at, next_min));
			case .EqualEqual;
				lhs = xx (lhs == eval(cpp, tokens, at, next_min));
			case .BangEqual;
				lhs = xx (lhs != eval(cpp, tokens, at, next_min));
			case .Ampersand;
				lhs = lhs & eval(cpp, tokens, at, next_min);
			case .Pipe;
				lhs = lhs | eval(cpp, tokens, at, next_min);
			case .Caret;
				lhs = lhs ^ eval(cpp, tokens, at, next_min);
			case .AmpersandAmpersand;
				rhs := eval(cpp, tokens, at, next_min).(bool);
				lhs = ifx (lhs.(bool) && rhs) then 1 else 0;
			case .PipePipe;
				rhs := eval(cpp, tokens, at, next_min).(bool);
				lhs = ifx (lhs.(bool) || rhs) then 1 else 0;
			case .Question;
				on_true := eval(cpp, tokens, at);
				at.* += 1; // ':'
				on_false := eval(cpp, tokens, at, next_min);
				if lhs != 0 {
					lhs = on_true;
				} else {
					lhs = on_false;
				}
		}
	}

	return lhs;
}

add_all_builtins :: (cpp: *Preprocessor) {
	add_builtin_object(cpp, "TARGET_CPU_ARM64", "1");
	add_builtin_object(cpp, "__STDC__", "1");
	add_builtin_object(cpp, "__STDC_VERSION__", "201112L");
	add_builtin_object(cpp, "__APPLE__", "1");
	add_builtin_object(cpp, "__MACH__", "1");
	add_builtin_object(cpp, "__aarch64__", "1");
	add_builtin_object(cpp, "__arm64__", "1");
	add_builtin_object(cpp, "__arm64", "1");
	add_builtin_object(cpp, "__LP64__", "1");
	add_builtin_object(cpp, "_LP64", "1");
	add_builtin_object(cpp, "__SIZEOF_DOUBLE__", "8");
	add_builtin_object(cpp, "__SIZEOF_POINTER__", "8");
	add_builtin_object(cpp, "__SIZEOF_INT__", "4");
	add_builtin_object(cpp, "__SIZEOF_LONG__", "8");
	add_builtin_object(cpp, "__SIZEOF_LONG_DOUBLE__", "8");
	add_builtin_object(cpp, "__SIZEOF_LONG_LONG__", "8");
	add_builtin_object(cpp, "__SIZEOF_PTRDIFF_T__", "8");
	add_builtin_object(cpp, "__SIZEOF_SHORT__", "2");
	add_builtin_object(cpp, "__SIZEOF_SIZE_T__", "8");

	// HACK(Oliver): These are the wrong sizes...
	add_builtin_object(cpp, "__INTMAX_TYPE__", "long long");
	add_builtin_object(cpp, "__UINTMAX_TYPE__", "unsigned long long");
	add_builtin_object(cpp, "__INT8_TYPE__", "signed char");
	add_builtin_object(cpp, "__INT16_TYPE__", "short");
	add_builtin_object(cpp, "__INT32_TYPE__", "int");
	add_builtin_object(cpp, "__INT64_TYPE__", "long long");
	add_builtin_object(cpp, "__UINT8_TYPE__", "unsigned char");
	add_builtin_object(cpp, "__UINT16_TYPE__", "unsigned short");
	add_builtin_object(cpp, "__UINT32_TYPE__", "unsigned int");
	add_builtin_object(cpp, "__UINT64_TYPE__", "unsigned long long");
	add_builtin_object(cpp, "__WCHAR_TYPE__", "int");
	add_builtin_object(cpp, "__SIZE_TYPE__", "unsigned long");
	add_builtin_object(cpp, "__PTRDIFF_TYPE__", "long");
	add_builtin_object(cpp, "__INTPTR_TYPE__", "long");
	add_builtin_object(cpp, "__UINTPTR_TYPE__", "unsigned long");
	add_builtin_object(cpp, "va_list", "__builtin_va_list");
	add_builtin_object(cpp, "va_copy", "__builtin_va_copy");
	add_builtin_object(cpp, "va_start", "__builtin_va_start");
	add_builtin_object(cpp, "__darwin_va_list", "__builtin_va_list");

	add_builtin_object(cpp, "__FLT_MAX__", "3.402823466e+38");
	add_builtin_object(cpp, "__DBL_MAX__", "1.7976931348623158e+308");

	add_function_builtin(cpp, "#define __asm(x)\n");
	add_function_builtin(cpp, "#define __attribute__(x)\n");
	add_function_builtin(cpp, "#define __max(x, y) (x < y ? y : x)\n");
	add_function_builtin(cpp, "#define va_arg(ap, type) (*(type *)(ap += __max(8, _Alignof(type))) - __max(8, _Alignof(type)))\n");
	add_function_builtin(cpp, "#define va_end(x)\n");
	configure_system_include_paths(cpp);
	// HACK(Oliver): Remove this dumbass shit
	cpp.at = 0;
}

preprocess :: (cpp: *Preprocessor, src_tokens: [..]Token) -> [..]Token {

	dst_tokens: [..]Token;

	skip_line :: (cpp: *Preprocessor, src_tokens: [..]Token) {
		while cpp.at < src_tokens.count && current(cpp, src_tokens).type != .Newline {
			skip(cpp, src_tokens);
		}
	}

	copy_line :: (cpp: *Preprocessor, src_tokens: [..]Token) -> [..]Token {
		result: [..]Token;
		while current(cpp, src_tokens).type != .Newline {
			array_add(*result, skip(cpp, src_tokens));
		}
		skip(cpp, src_tokens);
		return result;
	}

	end :: (cpp: *Preprocessor, src_tokens: [..]Token) -> bool {
		return cpp.at == src_tokens.count;
	}

	skip_until_el :: (cpp: *Preprocessor, src_tokens: [..]Token) {
		depth := 0;
		while !end(cpp, src_tokens) {
			if current(cpp, src_tokens).type == .Hash {
				directive := next(cpp, src_tokens).view;
				if directive == "if" || directive == "ifdef" || directive == "ifndef" {
					depth += 1;
				} else if directive == "endif" {
					if depth == 0 {
						//print("\nAFTER ENDIF DEPTH 0: %\n", next(cpp).view);
						return;
					}
					depth -= 1;
				} else if (directive == "else" || directive == "elif") && depth == 0 {
					return;
				}
			}
			skip(cpp, src_tokens);
		}
	}

	while !end(cpp, src_tokens) {
		cpp.line = current(cpp, src_tokens).line;
		if current(cpp, src_tokens).type == {
			case .Hash;
				skip(cpp, src_tokens);
				directive := skip(cpp, src_tokens);
				if directive.view == {
					case "warning";
						print("#warning: ");
						line := copy_line(cpp, src_tokens);
						for line {
							print("% ", it.view);
						}
						print("\n");
					case "error";
						print("#error: ");
						line := copy_line(cpp, src_tokens);
						for line {
							print("% ", it.view);
						}
						print("\n");
					case "pragma";
						if current(cpp, src_tokens).view == "once" {
							print("Found pragma once\n");
							table_set(*cpp.includes, peek(cpp.path_stack), true);
						}
						skip_line(cpp, src_tokens);
					case "define";
						name := skip(cpp, src_tokens);
						is_function_definition := false;
						if current(cpp, src_tokens).type == .LeftParenthesis {
							// They need to be next to eachother
							if name.view.data + name.view.count == current(cpp, src_tokens).view.data {
								is_function_definition = true;
								skip(cpp, src_tokens);
								function: Function;
								while current(cpp, src_tokens).type != .RightParenthesis {
									if current(cpp, src_tokens).type == .Ellipsis {
										function.variadic = true;
										skip(cpp, src_tokens);
									} else {
										array_add(*function.params, skip(cpp, src_tokens));
									}
									if current(cpp, src_tokens).type == .Comma {
										skip(cpp, src_tokens);
									}
								}
								skip(cpp, src_tokens);
								while current(cpp, src_tokens).type != .Newline {
									token := skip(cpp, src_tokens);
									array_add(*function.tokens, token);
								}

								table_add(*cpp.functions, name.view, function);
								skip_line(cpp, src_tokens);
							}
						}

						if !is_function_definition {
							object: Object;
							while current(cpp, src_tokens).type != .Newline {
								token := skip(cpp, src_tokens);
								array_add(*object.tokens, token);
							}
							table_add(*cpp.objects, name.view, object);
						}
					case "include";
						if current(cpp, src_tokens).type == .String {
							include_path := skip(cpp, src_tokens).view;
							file: string;
							found := false;
							current_path := parse_path(peek(cpp.path_stack));
							current_path.words.count -= 1;
							resolved_path := parse_path(tprint("%/%", path_to_string(current_path), include_path));
							path := path_to_string(resolved_path);
							//print("RESOLVED: %\n", path);
							//print("Loading include %\n", peek(cpp.path_stack));
							found_include, pragma_onced := table_find(*cpp.includes, path);
							if !table_find(*cpp.includes, path) {
								full_path := path;
								if !file_exists(full_path) {
									full_path = resolve_system_include(cpp, include_path);
								}
								if full_path.count == 0 {
									print("Could not resolve include \"%\" from %\n", include_path, peek(cpp.path_stack));
								}
								if !table_contains(*cpp.includes, full_path) {
									table_add(*cpp.includes, full_path, false);
								}
								file, found = read_entire_file(full_path);
								assert(found);
								array_add(*cpp.path_stack, full_path);
								//print("Loading include %\n", peek(cpp.path_stack));
								include_tokeniser := tokenise(file, full_path);
								at := cpp.at;
								cpp.at = 0;
								include_tokens := preprocess(cpp, include_tokeniser.tokens);
								for include_tokens {
									array_add(*dst_tokens, it);
								}
								cpp.at = at;
								cpp.path_stack.count -= 1;
							}
						} else if current(cpp, src_tokens).type == .Less {
							skip(cpp, src_tokens);
							path := "";
							while current(cpp, src_tokens).type != .Greater {
								path = join(path, skip(cpp, src_tokens).view);
							}
							skip(cpp, src_tokens);
							full_path: string;
							full_path = resolve_system_include(cpp, path);
							if full_path.count == 0 {
								print("Could not resolve system include <%> from %\n", path, peek(cpp.path_stack));
							}
							if !table_find(*cpp.includes, full_path) {
								if !table_contains(*cpp.includes, full_path) {
									table_add(*cpp.includes, full_path, false);
								}
								file: string;
								found := false;
								file, found = read_entire_file(full_path);
								array_add(*cpp.path_stack, full_path);
								assert(found);
								//print("Loading include %\n", peek(cpp.path_stack));
								include_tokeniser := tokenise(file, full_path);
								at := cpp.at;
								cpp.at = 0;
								include_tokens := preprocess(cpp, include_tokeniser.tokens);
								for include_tokens {
									array_add(*dst_tokens, it);
								}
								cpp.at = at;
								cpp.path_stack.count -= 1;
							}
						}
						skip_line(cpp, src_tokens);
					case "undef";
						table_remove(*cpp.objects, skip(cpp, src_tokens).view);
					case "elif";
						line := copy_line(cpp, src_tokens);
						// if peek(cpp.cond_stack).branch_taken {
						// 	print("NOT TAKING ");
						// }
						// print("#elif ");
						// for line {
						// 	print("% ", it.view);
						// }
						// print("\n");
						if peek(cpp.cond_stack).branch_taken {
							skip_until_el(cpp, src_tokens);
						} else {
							start := 0;
							expr := eval(cpp, line, *start);
							//print("EXPR: %", expr);
							if expr != 0 {
								peek_pointer(cpp.cond_stack).branch_taken = true;
							} else {
								skip_until_el(cpp, src_tokens);
							}
						}
					case "else";
						i := 0;
						skip_line(cpp, src_tokens);
						if peek(cpp.cond_stack).branch_taken {
							skip_until_el(cpp, src_tokens);
						}
					case "endif";
						pop_cond(cpp);
						skip_line(cpp, src_tokens);
					case "ifdef"; #through;
					case "ifndef"; #through;
					case "if";
						expr: int;
						line := copy_line(cpp, src_tokens);
						if directive.view == "ifdef" {
							name := line[0];
							expr = table_contains(*cpp.objects, name.view).(int);
							expr |= table_contains(*cpp.functions, name.view).(int);
						} else if directive.view == "ifndef" {
							name := line[0];
							expr = (!table_contains(*cpp.objects, name.view)).(int);
							expr &= (!table_contains(*cpp.functions, name.view)).(int);
						} else {
							to_expand := line;
							// print("#if ");
							// for to_expand {
							// 	print("% ", it.view);
							// }
							// print("\n");
							no_defineds: [..]Token;
							at := 0;
							//print("TO_EXPAND: %\n", to_expand);
								while at < to_expand.count {
									// Hack maybe?
									if to_expand[at].view == "defined" {
										defined_token := to_expand[at];
										at += 1; // 'defined'
										if to_expand[at].type == .LeftParenthesis {
											at += 1;
										}
										value := table_contains(*cpp.objects, to_expand[at].view).(int);
										value |= table_contains(*cpp.functions, to_expand[at].view).(int);
										//print("ID TO CHECK: %\n", to_expand[at]);
										at += 1;
										if at < to_expand.count && to_expand[at].type == .RightParenthesis {
											at += 1;
										}
										value_token: Token;
										value_token.view = tprint("%", value);
										value_token.type = .Number;
										value_token.number_type = .Decimal;
										value_token.source_path = defined_token.source_path;
										value_token.line = defined_token.line;
										value_token.col = defined_token.col;
										array_add(*no_defineds, value_token);
									} else {
										array_add(*no_defineds, to_expand[at]);
										at += 1;
								}
							}
							expanded := expand(cpp, no_defineds);
							start := 0;
							expr = eval(cpp, expanded, *start);
							//print("EVAL: %\n", expr);
						}
						push_cond(cpp, expr != 0);
						if expr == 0 {
							skip_until_el(cpp, src_tokens);
						}
				}
			case .Identifier;
				name := current(cpp, src_tokens);
				object := table_find_pointer(*cpp.objects, name.view);
				function := table_find_pointer(*cpp.functions, name.view);
				is_function := (function && next(cpp, src_tokens).type == .LeftParenthesis); 
				if object || is_function {
					if is_function {
						to_expand: [..]Token;
						array_add(*to_expand, skip(cpp, src_tokens));
						array_add(*to_expand, skip(cpp, src_tokens));
						paren_depth := 0;
						//print("\n========FUNC EXPAND START % ======\n", cpp.expand_count);
						cpp.expand_count += 1;
						while paren_depth > 0 || current(cpp, src_tokens).type != .RightParenthesis {
							// if current(cpp, src_tokens).type != .Newline {
							// 	print("% ", current(cpp, src_tokens).view);
							// } else {
							// 	print("\n");
							// }
							if current(cpp, src_tokens).type == .LeftParenthesis {
								array_add(*to_expand, skip(cpp, src_tokens));
								paren_depth += 1;
							} else if current(cpp, src_tokens).type == .RightParenthesis {
								paren_depth -= 1;
								array_add(*to_expand, skip(cpp, src_tokens));
							} else if current(cpp, src_tokens).type == .Newline {
								// Dunno why i need to do this
								skip(cpp, src_tokens);
							} else {
								array_add(*to_expand, skip(cpp, src_tokens));
							}
						}
						//print("\n========FUNC EXPAND END======\n");
						assert(current(cpp, src_tokens).type == .RightParenthesis);
						array_add(*to_expand, skip(cpp, src_tokens));
						// print("TO EXPAND: ");
						// for to_expand {
						// 	print("% ", it.view);
						// }
						// print("\n");
						expanded := expand(cpp, to_expand);
						for expanded {
							insert(cpp, it, *dst_tokens);
						}
					} else {
						skip(cpp, src_tokens);
						expanded := expand(cpp, object.tokens);
						for expanded {
							insert(cpp, it, *dst_tokens);
						}
					}
				} else if name.view == "__LINE__" {
					skip(cpp, src_tokens);
					token: Token;
					token.view = tprint("%", name.line);
					token.type = .Number;
					token.number_type = .Decimal;
					token.source_path = name.source_path;
					token.line = name.line;
					token.col = name.col;
					insert(cpp, token, *dst_tokens);
					paste(cpp, src_tokens, *dst_tokens);
				} else if name.view == "__FILE__" {
					skip(cpp, src_tokens);
					token: Token;
					token.view = peek(cpp.path_stack);
					token.type = .String;
					token.source_path = name.source_path;
					token.line = name.line;
					token.col = name.col;
					insert(cpp, token, *dst_tokens);
					paste(cpp, src_tokens, *dst_tokens);
				} else {
					paste(cpp, src_tokens, *dst_tokens);
				}
			case;
				paste(cpp, src_tokens, *dst_tokens);
		}
	}

	return dst_tokens;
}
