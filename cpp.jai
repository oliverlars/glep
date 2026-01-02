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
Preprocessor :: struct {
	at: int;
	path_stack: [..]string;
	cond_stack: [..]Cond_State;
	objects: Table(string, Object);
	functions: Table(string, Function);
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

add_builtin :: (cpp: *Preprocessor, builtin: string, view: string, type: Token_Type) {
	object: Object;
	token: Token;
	token.view = view;
	token.type = type;
	array_add(*object.tokens, token);
	table_add(*cpp.objects, builtin, object);
}

trim_suffix :: (number: string) -> string {
	result := number;
	for < number {
		if it == "l" || it == "L" || it == "u" || it == "U" {
			result.count -= 1;
		}
	}
	return result;
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
	for at: 0..body.count-1 {
		it := body[at];
		if it.type == .Hash {
			found, index := find_arg(params, args, body[at + 1]);
			stringed: Token;
			stringed.type = .String;
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
			at += 1;
			continue;
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
			} else {
				array_add(*right_tokens, body[at + 2]);
			}

			for i: 0..left_tokens.count - 2 {
				array_add(*result, left_tokens[i]);
			}
			
			glued := glue_tokens(left_tokens[left_tokens.count - 1], right_tokens[0]);
			array_add(*result, glued);
			
			for i: 1..right_tokens.count - 1 {
				array_add(*result, right_tokens[i]);
			}

			at += 3;
			continue;
		} else {
			matched_param, param_index := find_arg(params, args, it);
			if matched_param {
				expanded_arg := expand(cpp, args[param_index]);
				for arg: expanded_arg {
					array_add(*result, arg);
				}
			}
			if matched_param continue;
		}
		if it.view == "__VA_ARGS__" {
			expanded_va := expand(cpp, va_args);
			for expanded_va {
				array_add(*result, it);
			}
		} else {
			array_add(*result, it);
		}
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
					//print("%", it.view);
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
			unary = to_integer(trim_suffix(tokens[at.*].view));
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
	add_builtin(cpp, "TARGET_CPU_ARM64", "1", .Number);
	add_builtin(cpp, "__STDC__", "1", .Number);
	add_builtin(cpp, "__STDC_VERSION__", "201112L", .Number);
	add_builtin(cpp, "__APPLE__", "1", .Number);
	add_builtin(cpp, "__MACH__", "1", .Number);
	add_builtin(cpp, "__aarch64__", "1", .Number);
	add_builtin(cpp, "__arm64__", "1", .Number);
	add_builtin(cpp, "__arm64", "1", .Number);
	add_builtin(cpp, "__LP64__", "1", .Number);
	add_builtin(cpp, "_LP64", "1", .Number);
	add_builtin(cpp, "__SIZEOF_DOUBLE__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_POINTER__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_INT__", "4", .Number);
	add_builtin(cpp, "__SIZEOF_LONG__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_LONG_DOUBLE__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_LONG_LONG__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_PTRDIFF_T__", "8", .Number);
	add_builtin(cpp, "__SIZEOF_SHORT__", "2", .Number);
	add_builtin(cpp, "__SIZEOF_SIZE_T__", "8", .Number);
	add_builtin(cpp, "__C99_MACRO_WITH_VA_ARGS", "1", .Number);
}

preprocess :: (cpp: *Preprocessor, src_tokens: [..]Token) -> [..]Token {

	dst_tokens: [..]Token;

	skip_line :: (cpp: *Preprocessor, src_tokens: [..]Token) {
		while current(cpp, src_tokens).type != .Newline {
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
						includes := string.[
							"/usr/local/include",
							"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/17/include",
							"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include",
							"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
							"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks",
							"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/SubFrameworks",
						];
						if current(cpp, src_tokens).type == .String {
							include_path := skip(cpp, src_tokens).view;
							file: string;
							found := false;
							current_path := parse_path(peek(cpp.path_stack));
							current_path.words.count -= 1;
							resolved_path := parse_path(tprint("%/%", path_to_string(current_path), include_path));
							path := path_to_string(resolved_path);
							print("RESOLVED: %\n", path);
							print("Loading include %\n", peek(cpp.path_stack));
							file, found = read_entire_file(path);
							if found {
								array_add(*cpp.path_stack, path);
								include_tokeniser := tokenise(file);
								at := cpp.at;
								cpp.at = 0;
								include_tokens := preprocess(cpp, include_tokeniser.tokens);
								for include_tokens {
									array_add(*dst_tokens, it);
								}
								cpp.at = at;
								cpp.path_stack.count -= 1;
							} else {
								for includes {
									full_path := tprint("%/%", it, include_path);
									if file_exists(full_path) {
										file, found = read_entire_file(full_path);
										array_add(*cpp.path_stack, full_path);
										break;
									}
								}
								assert(found);
								print("Loading include %\n", peek(cpp.path_stack));
								include_tokeniser := tokenise(file);
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
							file: string;
							found := false;
							for includes {
								full_path := tprint("%/%", it, path);
								if file_exists(full_path) {
									file, found = read_entire_file(full_path);
									array_add(*cpp.path_stack, full_path);
									break;
								}
							}
							assert(found);
							print("Loading include %\n", peek(cpp.path_stack));
							include_tokeniser := tokenise(file);
							at := cpp.at;
							cpp.at = 0;
							include_tokens := preprocess(cpp, include_tokeniser.tokens);
							for include_tokens {
								array_add(*dst_tokens, it);
							}
							cpp.at = at;
							cpp.path_stack.count -= 1;
						}
						skip_line(cpp, src_tokens);
					case "undef";
						table_remove(*cpp.objects, skip(cpp, src_tokens).view);
					case "elif";
						line := copy_line(cpp, src_tokens);
						if peek(cpp.cond_stack).branch_taken {
							print("NOT TAKING ");
						}
						print("#elif ");
						for line {
							print("% ", it.view);
						}
						print("\n");
						if peek(cpp.cond_stack).branch_taken {
							skip_until_el(cpp, src_tokens);
						} else {
							start := 0;
							expr := eval(cpp, line, *start);
							print("EXPR: %", expr);
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
							print("#if ");
							for to_expand {
								print("% ", it.view);
								if it.view == "__has_include" {
									a := 5;
								}
							}
							print("\n");
							no_defineds: [..]Token;
							at := 0;
							//print("TO_EXPAND: %\n", to_expand);
							while at < to_expand.count {
								// Hack maybe?
								if to_expand[at].view == "defined" {
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
									array_add(*no_defineds, value_token);
								} else {
									array_add(*no_defineds, to_expand[at]);
									at += 1;
								}
							}
							expanded := expand(cpp, no_defineds);
							start := 0;
							expr = eval(cpp, expanded, *start);
							print("EVAL: %\n", expr);
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
				if object || function {
					
					expanded := expand(cpp, copy_line(cpp, src_tokens));
					for expanded {
						insert(cpp, it, *dst_tokens);
					}
				} else {
					paste(cpp, src_tokens, *dst_tokens);
				}
			case;
				paste(cpp, src_tokens, *dst_tokens);
		}
	}

	return dst_tokens;
}


