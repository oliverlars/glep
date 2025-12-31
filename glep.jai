#import "Basic";
#import "File";
#import "File_Utilities";

#import "Hash_Table";
#import "Hash";

#import "String";

#load "cpp.jai";

Token_Type :: enum {
	Invalid;
	Hash;
	Newline;
	Asterisk;
	Comma;
	Semicolon;
	Colon;
	Number;
	String;
	Char;
	Identifier;
	Equals;
	LeftParenthesis;
	RightParenthesis;
	LeftBrace;
	RightBrace;
	LeftBracket;
	RightBracket;
	Ellipsis;
	Period;
	Plus;
	Minus;
	ForwardSlash;
	Bang;
	PlusPlus;
	MinusMinus;
	Tilde;
	Caret;
	Percent;
	Less;
	LessEqual;
	Greater;
	GreaterEqual;
	EqualEqual;
	BangEqual;
	AmpersandAmpersand;
	PipePipe;
	Ampersand;
	Pipe;
	LessLess;
	GreaterGreater;
	PlusEqual;
	MinusEqual;
	AsteriskEqual;
	ForwardSlashEqual;
	PercentEqual;
	AmpersandEqual;
	PipeEqual;
	CaretEqual;
	LessLessEqual;
	GreaterGreaterEqual;
	Arrow;
	Question;
}

Token :: struct {
	view: string;
	// Lord have mercy
	type: Token_Type;
	hideset: [..]string;
}

Tokeniser :: struct {
	at: int;
	source: string;
	tokens: [..]Token;
}

Parser :: struct {
	tokens: [..]Token;
	at: int;

	variables: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);
}

Node :: struct {
	type: Type;
}

Node_Type_Info :: struct {
	qualifiers: [..]string;
	specifiers: [..]string;
	storage_class: string;
	_struct: *Node_Struct;
	_enum: *Node_Enum;
}



Node_Struct :: struct {
	name: Token;
	is_union: bool;
	members: [..]*Node_Decl;
}

Node_Enum_Member :: struct {
	name: Token;
	expr: *Node_Expr;
}

Node_Enum :: struct {
	name: Token;
	members: [..]*Node_Enum_Member;
}

Node_Declarator :: struct {
	#as using node: Node;
	qualifiers: [..]string;
	declarator_type: Type;
	init: *Node_Initializer;
	inner: *Node_Declarator;
}

Node_Function_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = #this;
	params: [..]*Node_Decl;
}

Node_Array_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = #this;
	count: int;
}

Node_Pointer_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = #this;
}

Node_Identifier_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = #this;
	name: string;
}

Node_Decl :: struct {
	#as using node: Node;
	type = Node_Decl;
	declarators: [..]*Node_Declarator;
	base_info: Node_Type_Info;
	body: *Node_Statement;
}

Node_Expr :: struct {
	#as using _: Node;
	type = #this;
	expr_type: Type;
}

Node_Binary :: struct {
	#as using node: Node_Expr;
	op: Token;
	left: *Node_Expr;
	right: *Node_Expr;
	expr_type = #this;
}

Node_Unary :: struct {
	#as using node: Node_Expr;
	op: Token;
	postfix: bool;
	expr: *Node_Expr;
	expr_type = #this;
}

Node_Cast :: struct {
	#as using node: Node_Expr;
	declarator: *Node_Declarator;
	base_info: Node_Type_Info;
	expr: *Node_Expr;
	expr_type = #this;
}

Node_Compound :: struct {
	#as using node: Node_Expr;
	declarator: *Node_Declarator;
	base_info: Node_Type_Info;
	init: *Node_Initializer;
	expr_type = #this;
}

Node_Ternary :: struct {
	#as using node: Node_Expr;
	cond: *Node_Expr;
	on_true: *Node_Expr;
	on_false: *Node_Expr;
	expr_type = #this;
}

Node_Call :: struct {
	#as using node: Node_Expr;
	expr_type = #this;
	id: *Node_Expr;
	params: [..]*Node_Expr;
}

Node_Assign :: struct {
	#as using node: Node_Expr;
	expr_type = #this;
	left: *Node_Expr;
	op: Token;
	right: *Node_Expr;
}

Node_Member_Access :: struct {
	#as using node: Node_Expr;
	op: Token;
	left: *Node_Expr;
	right: Token;
	expr_type = #this;
}

Node_Array_Access :: struct {
	#as using node: Node_Expr;
	left: *Node_Expr;
	offset: *Node_Expr;
	expr_type = #this;
}

Node_Identifier :: struct {
	#as using node: Node_Expr;
	id: Token;
	expr_type = #this;
}

Node_Number :: struct {
	#as using node: Node_Expr;
	expr_type = #this;
	token: Token;
	value: int;
}

Node_String :: struct {
	#as using node: Node_Expr;
	expr_type = #this;
	token: Token;
}

Node_Initializer :: struct {
	#as using node: Node;
	type = #this;
	initializer_type: Type;
}

Node_Scalar_Initializer :: struct {
	#as using _: Node_Initializer;
	initializer_type = #this;
	expr: *Node_Expr;
}

Node_Designated_Initializer :: struct {
	#as using _: Node_Initializer;
	initializer_type = #this;
	designations: [..]*Node_Designation;
}

Node_Designation :: struct {
	#as using node: Node;
	type = #this;
	designators: [..]*Node_Designator;
	expr: *Node_Initializer;
}

Node_Designator :: struct {
	#as using node: Node;
	type = #this;
	designator_type: Type;
}

Node_Field_Designator :: struct {
	#as using _: Node_Designator;
	designator_type = #this;
	name: Token;
}

Node_Index_Designator :: struct {
	#as using _: Node_Designator;
	designator_type = #this;
	offset: *Node_Expr;
}

Node_Statement :: struct {
	#as using _: Node;
	type = #this;
	statement_type: Type;
}

Node_Goto :: struct {
	#as using node: Node_Statement;
	to: Token;
	statement_type = #this;
}

Node_Continue :: struct {
	#as using node: Node_Statement;
	statement_type = #this;
}

Node_Break :: struct {
	#as using node: Node_Statement;
	statement_type = #this;
}

Node_Block :: struct {
	#as using node: Node_Statement;
	statements: [..]*Node_Statement;
	statement_type = #this;
}

Node_Label :: struct {
	#as using node: Node_Statement;
	statement: *Node_Statement;
	is_case: bool;
	token: Token;
	statement_type = #this;
}

Node_Return :: struct {
	#as using node: Node_Statement;
	expr: *Node_Expr;
	statement_type = #this;
}

Node_If :: struct {
	#as using node: Node_Statement;
	cond: *Node_Expr;
	on_true: *Node_Statement;
	on_false: *Node_Statement;
	statement_type = #this;
}

Node_For :: struct {
	#as using node: Node_Statement;
	init : *Node_Decl;
	cond: *Node_Expr;
	expr: *Node_Expr;
	body: *Node_Statement;
	statement_type = #this;
}

Node_While :: struct {
	#as using node: Node_Statement;
	cond: *Node_Expr;
	body: *Node_Statement;
	statement_type = #this;
}

Node_Do :: struct {
	#as using node: Node_Statement;
	cond: *Node_Expr;
	body: *Node_Statement;
	statement_type = #this;
}

Node_Switch :: struct {
	#as using node: Node_Statement;
	expr: *Node_Expr;
	body: *Node_Statement;
	statement_type = #this;
}

Node_Decl_Statement :: struct {
	#as using node: Node_Statement;
	decl: *Node_Decl;
	statement_type = #this;
}

Node_Expr_Statement :: struct {
	#as using node: Node_Statement;
	expr: *Node_Expr;
	statement_type = #this;
}

Node_Translation_Unit :: struct {
	#as using node: Node;
	declarations: [..]*Node_Decl;
	type = #this;
}


tokenise :: (file: string) -> Tokeniser {
	result: Tokeniser;
	result.source = file;
	tokenise(*result);
	return result;
}

tokenise :: (t: *Tokeniser) {
	is_ws    :: (c: int) -> bool { return c == #char " " || c == #char "\t"; }
	is_newline :: (c: int) -> bool { return c == #char "\n" || c == #char "\r"; }
	is_ident :: (c: int) -> bool { return c == #char "_" || ((c >= #char "a") && (c <= #char "z")) || ((c >= #char "A") && (c <= #char "Z")); }
	is_num   :: (c: int) -> bool { return c >= #char "0" && c <= #char "9"; }
	gobble_ws :: (t: *Tokeniser) { while t.at < t.source.count && is_ws(t.source[t.at]) { t.at += 1; } }
	while t.at < t.source.count {
		token: Token;
		token.view.data = t.source.data + t.at;
		token.view.count = 1;
		if is_ws(t.source[t.at]) {
			gobble_ws(t);
			continue;
		} else {
			if t.source[t.at] == {
			case "=";
				t.at += 1; token.type = .Equals;
				if t.source[t.at] == #char "=" {
					t.at += 1;
					token.view.count += 1;
					token.type = .EqualEqual;
				}
			case ";"; t.at += 1; token.type = .Semicolon;
			case ":"; t.at += 1; token.type = .Colon;
			case ","; t.at += 1; token.type = .Comma;
			case "("; t.at += 1; token.type = .LeftParenthesis;
			case ")"; t.at += 1; token.type = .RightParenthesis;
			case "{"; t.at += 1; token.type = .LeftBrace;
			case "}"; t.at += 1; token.type = .RightBrace;
			case "["; t.at += 1; token.type = .LeftBracket;
			case "]"; t.at += 1; token.type = .RightBracket;
			case "?"; t.at += 1; token.type = .Question;
			case "#"; t.at += 1; token.type = .Hash;
			case "\n"; #through;
			case "\r"; t.at += 1; token.type = .Newline;
			case "*";
				t.at += 1; token.type = .Asterisk;
				if t.source[t.at] == "=" {
					token.type = .AsteriskEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "&";
				t.at += 1; token.type = .Ampersand;
				if t.source[t.at] == #char "&" {
					t.at += 1;
					token.view.count += 1;
					token.type = .AmpersandAmpersand;
				}
			case "~"; t.at += 1; token.type = .Tilde;
			case "^";
				t.at += 1; token.type = .Caret;
				if t.source[t.at] == #char "=" {
					t.at += 1;
					token.view.count += 1;
					token.type = .CaretEqual;
				}
			case "%";
				t.at += 1; token.type = .Percent;
				if t.source[t.at] == #char "=" {
					t.at += 1;
					token.view.count += 1;
					token.type = .PercentEqual;
				}
			case "!";
				t.at += 1; token.type = .Bang;
				if t.source[t.at] == #char "=" {
					t.at += 1;
					token.view.count += 1;
					token.type = .BangEqual;
				}
			case "+";
				t.at += 1; token.type = .Plus;
				if t.source[t.at] == "+" {
					token.type = .PlusPlus;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == "=" {
					token.type = .PlusEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "-"; 
				t.at += 1; token.type = .Minus;
				if t.source[t.at] == "-" {
					token.type = .MinusMinus;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == "=" {
					token.type = .MinusEqual;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == ">" {
					token.type = .Arrow;
					t.at += 1;
					token.view.count += 1;
				}
			case "/";
				t.at += 1; token.type = .ForwardSlash;
				if t.source[t.at] == "=" {
					token.type = .ForwardSlashEqual;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == "/" {
					while t.at < t.source.count && !is_newline(t.source[t.at]) {
						t.at += 1;
					}
					continue;
				} else if t.source[t.at] == "*" {
					t.at += 1;
					while t.at + 1 < t.source.count {
						if t.source[t.at] == "*" && t.source[t.at + 1] == "/" {
							t.at += 2;
							break;
						}
						t.at += 1;
					}
					continue;
				}
			case "\\";
				t.at += 1;
				if t.source[t.at] == "\n" {
					t.at += 1;
				}
				continue;
			case ".";
				t.at += 1;
				token.type = .Period;
				if t.at + 2 < t.source.count {
					if t.source.data[t.at] == #char "." &&
						t.source.data[t.at + 1] == #char "." {
						token.type = .Ellipsis;
						t.at += 2;
						token.view.count += 2;
					}
				}
				if is_num(t.source.data[t.at]) {
					token.type = .Number;
					while is_num(t.source[t.at]) {
						t.at += 1;
					}
					token.view.count = t.source.data + t.at - token.view.data;
				}
			case "|";
				t.at += 1; token.type = .Pipe;
				if t.source.data[t.at] == #char "|" {
					token.type = .PipePipe;
					t.at += 1;
					token.view.count += 1;
				} else if t.source.data[t.at] == #char "=" {
					token.type = .PipeEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "<";
				t.at += 1; token.type = .Less;
				if t.source.data[t.at] == #char "=" {
					token.type = .LessEqual;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == #char "<" {
					t.at += 1;
					token.type = .LessLess;
					if t.source[t.at] == #char "=" {
						t.at += 1;
						token.view.count += 1;
						token.type = .LessLessEqual;
					}
				}
			case ">";
				t.at += 1; token.type = .Greater;
				if t.source.data[t.at] == #char "=" {
					token.type = .GreaterEqual;
					t.at += 1;
					token.view.count += 1;
				} else if t.source[t.at] == #char ">" {
					t.at += 1;
					token.type = .GreaterGreater;
					if t.source[t.at] == #char "=" {
						t.at += 1;
						token.view.count += 1;
						token.type = .GreaterGreaterEqual;
					}
				}
			case;
				if is_ident(t.source[t.at]) {
					token.type = .Identifier;
					while is_ident(t.source[t.at]) || t.source[t.at] == #char "_"  ||
							is_num(t.source[t.at]) {
						t.at += 1;
					}
					token.view.count = t.source.data + t.at - token.view.data;
				} else if is_num(t.source[t.at]) {
					token.type = .Number;
					// Do this better...
					if t.source[t.at] == "0" && t.source[t.at + 1] == "x" {
						t.at += 2;
						while is_num(t.source[t.at]) || is_ident(t.source[t.at]) {
							t.at += 1;
						}
					} else {
						while is_num(t.source[t.at]) {
							t.at += 1;
						}
						if t.source[t.at] == "." {
							t.at += 1;
							while is_num(t.source[t.at]) {
								t.at += 1;
							}
						}
						if t.source[t.at] == "e" || t.source[t.at] == "E" ||
						   t.source[t.at] == "l" ||
						   t.source[t.at] == "L" ||
						   t.source[t.at] == "U" ||
						   t.source[t.at] == "u" {
							t.at += 1;
							while is_num(t.source[t.at]) {
								t.at += 1;
							}
						}
					}
					token.view.count = t.source.data + t.at - token.view.data;
				} else if t.source[t.at] == "\"" {
					token.type = .String;
					t.at += 1;
					while t.source[t.at] != "\"" {
						t.at += 1;
					}
					t.at += 1;
					token.view.count = t.source.data + t.at - token.view.data - 2;
					token.view.data += 1;
				} else if t.source[t.at] == "'" {
					token.type = .Char;
					t.at += 1;
					while t.source[t.at] != "'" {
						if t.source[t.at] == #char "\\" {
							t.at += 1;
							if t.source[t.at + 1] == #char "'" {
								t.at += 1;
							}
						} else {
							t.at += 1;
						}
					}
					t.at += 1;
					token.view.count = t.source.data + t.at - token.view.data - 2;
					token.view.data += 1;
				}
			}
		}

		array_add(*t.tokens, token);
	}
}

skip :: (p: *Parser) {
	while p.tokens[p.at].type == .Newline {
		p.at += 1;
	}
	p.at += 1;
	while p.at < p.tokens.count && p.tokens[p.at].type == .Newline {
		p.at += 1;
	}
}

expect :: (p: *Parser, type: Token_Type) {
	if current(p).type != type {
		print("Expected: %\n", type);
		for max(0, p.at-20)..p.at+19 {
			print("% ", p.tokens[it].view);
		}
		assert(false);
	} else {
		skip(p);
	}
}

current :: (p: *Parser) -> Token {
	at := p.at;
	assert(p.tokens[at].type != .Newline);
	return p.tokens[at];
}

next :: (p: *Parser) -> Token {
	at := p.at + 1;
	assert(p.tokens[at].type != .Newline);
	return p.tokens[at];
}


is_typedef :: (info: Node_Type_Info) -> bool {
	return info.storage_class == "typedef";
}

is_type_qualifier :: (token: Token) -> bool {
	if token.view == {
	case "const";    #through;
	case "volatile"; #through;
	case "restrict";
		return true;
	case;
		return false;
	}
}

is_storage_specifier :: (token: Token) -> bool {
	if token.view == {
	case "static";   #through;
	case "auto";     #through;
	case "extern";   #through;
	case "register"; #through;
	case "typedef";
		return true;
	case;
		return false;
	}
}

is_type_specifier :: (token: Token) -> bool {
	if token.view == { 
	case "void";     #through;
	case "char";     #through;
	case "short";    #through;
	case "int";      #through;
	case "long";     #through;
	case "float";    #through;
	case "double";   #through;
	case "signed";   #through;
	case "unsigned"; #through;
	case "_Float16"; #through;
	case "_Bool"; #through;
	case "bool";
		return true;
	case;
		return false;
	}
}

is_function_specifier :: (token: Token) -> bool {
	return token.view == "inline";
}


parse_declaration_specifiers :: (p: *Parser, info: *Node_Type_Info) {
	while is_declaration_start(p) {
		if is_storage_specifier(current(p)) {
			info.storage_class = current(p).view;
			skip(p);
		} else if current(p).view == "struct" {
			skip(p);
			_struct := New(Node_Struct);
			if current(p).type == .Identifier {
				_struct.name = current(p);
				table_add(*p.structs, _struct.name.view, _struct);
				skip(p);
			}
			if current(p).type == .LeftBrace {
				skip(p);
				while current(p).type != .RightBrace {
					decl := parse_decl(p);
					expect(p, .Semicolon);
					array_add(*_struct.members, decl);
				}
				expect(p, .RightBrace);
			}
			info._struct = _struct;
		} else if current(p).view == "union" {
			skip(p);
			_union := New(Node_Struct);
			_union.is_union = true;
			if current(p).type == .Identifier {
				_union.name = current(p);
				table_add(*p.structs, _union.name.view, _union);
				skip(p);
			}
			if current(p).type == .LeftBrace {
				skip(p);
				while current(p).type != .RightBrace {
					decl := parse_decl(p);
					expect(p, .Semicolon);
					array_add(*_union.members, decl);
				}
				expect(p, .RightBrace);
			}
			info._struct = _union;
		} else if current(p).view == "enum" {
			skip(p);
			_enum := New(Node_Enum);
			if current(p).type == .Identifier {
				_enum.name = current(p);
				table_add(*p.enums, _enum.name.view, _enum);
				skip(p);
			}
			if current(p).type == .LeftBrace {
				skip(p);
				while current(p).type != .RightBrace {
					
					member := New(Node_Enum_Member);
					member.name = current(p);
					expect(p, .Identifier);
					if current(p).type == .Equals {
						skip(p);
						member.expr = parse_expr(p, precedence_of(.Comma) + 1);
					}
					array_add(*_enum.members, member);
					if current(p).type != .RightBrace {
						expect(p, .Comma);
					}
				}
				expect(p, .RightBrace);
			}
			info._enum = _enum;
		} else {
			array_add(*info.qualifiers, current(p).view);
			skip(p);
		}
	}
}

is_declaration_start :: (p: *Parser) -> bool {
	return is_storage_specifier(current(p)) ||
		   is_type_qualifier(current(p)) ||
		   is_type_specifier(current(p)) ||
		   is_type_name(p, current(p)) ||
		   is_function_specifier(current(p)) ||
		   current(p).view == "struct" ||
		   current(p).view == "enum" ||
		   current(p).view == "union";
}

is_type_name :: (parser: *Parser, token: Token) -> bool {
	is_in_tags := table_contains(*parser.enums, token.view);
	is_in_tags |= table_contains(*parser.structs, token.view);
	return is_type_qualifier(token) ||
		   is_type_specifier(token) || is_in_tags ||
		   table_contains(*parser.typedefs, token.view);
}

is_assign_op :: (token: Token) -> bool {
	if token.type == {
		case .PipeEqual; #through;
		case .CaretEqual; #through;
		case .AmpersandEqual; #through;
		case .GreaterGreaterEqual; #through;
		case .LessLessEqual; #through;
		case .PercentEqual; #through;
		case .ForwardSlashEqual; #through;
		case .AsteriskEqual; #through;
		case .MinusEqual; #through;
		case .PlusEqual; #through;
		case .Equals;
			return true;
	}
	return false;
}

precedence_of :: (token: Token) -> int {
	if token.type == {
		case .Percent;      return 13;
		case .ForwardSlash; return 13;
		case .Asterisk;     return 13;
		
		case .Minus;          return 12;
		case .Plus;           return 12;

		case .GreaterGreater; return 11;
		case .LessLess;       return 11;

		case .GreaterEqual; return 10;
		case .Greater;      return 10;
		case .LessEqual;    return 10;
		case .Less;         return 10;

		case .BangEqual;  return 9;
		case .EqualEqual; return 9;

		case .Ampersand; return 8;

		case .Caret; return 7;

		case .Pipe; return 6;

		case .AmpersandAmpersand; return 5;

		case .PipePipe; return 4;

		case .Question; return 3;

		case .PipeEqual;           return 2;
		case .CaretEqual;          return 2;
		case .AmpersandEqual;      return 2;
		case .GreaterGreaterEqual; return 2;
		case .LessLessEqual;       return 2;
		case .PercentEqual;        return 2;
		case .ForwardSlashEqual;   return 2;
		case .AsteriskEqual;       return 2;
		case .MinusEqual;          return 2;
		case .PlusEqual;           return 2;
		case .Equals;              return 2;

		case .Comma; return 1;

		case; return 0;
	}
}

precedence_of :: (type: Token_Type) -> int {
	if type == {
		case .Percent;      return 12;
		case .ForwardSlash; return 12;
		case .Asterisk;     return 12;
		
		case .Minus;          return 11;
		case .Plus;           return 11;
		case .GreaterGreater; return 11;
		case .LessLess;       return 11;

		case .GreaterEqual; return 10;
		case .Greater;      return 10;
		case .LessEqual;    return 10;
		case .Less;         return 10;

		case .BangEqual;  return 9;
		case .EqualEqual; return 9;

		case .Ampersand; return 8;

		case .Caret; return 7;

		case .Pipe; return 6;

		case .AmpersandAmpersand; return 5;

		case .PipePipe; return 4;

		case .Question; return 3;

		case .PipeEqual;           return 2;
		case .CaretEqual;          return 2;
		case .AmpersandEqual;      return 2;
		case .GreaterGreaterEqual; return 2;
		case .LessLessEqual;       return 2;
		case .PercentEqual;        return 2;
		case .ForwardSlashEqual;   return 2;
		case .AsteriskEqual;       return 2;
		case .MinusEqual;          return 2;
		case .PlusEqual;           return 2;
		case .Equals;              return 2;

		case .Comma; return 1;
		
		case; return 0;
	}
}

is_left_associative :: (token: Token) -> bool {
	if token.type == {
		case .Asterisk; #through;
		case .ForwardSlash; #through;
		case .Percent; #through;
		case .Plus; #through;
		case .Minus; #through;
		case .LessLess; #through;
		case .GreaterGreater; #through;
		case .Less; #through;
		case .Greater; #through;
		case .LessEqual; #through;
		case .GreaterEqual; #through;
		case .Ampersand; #through;
		case .Caret; #through;
		case .Pipe; #through;
		case .AmpersandAmpersand; #through;
		case .PipePipe;
			return true;
	}
	return false;
}

is_prefix_op :: (token: Token) -> bool {
	if token.type == {
		case .Plus; #through;
		case .Minus; #through;
		case .Asterisk; #through;
		case .Bang; #through;
		case .PlusPlus; #through;
		case .MinusMinus; #through;
		case .Tilde; #through;
		case .Caret;   #through;
		case .Percent; #through;
		case .Ampersand;
			return true;
	}

	if token.view == "sizeof" {
		return true;
	}
	
	return false;
}

is_binary_op :: (token: Token) -> bool {
	if token.type == {
		case .Plus; #through;
		case .Minus; #through;
		case .Asterisk; #through;
		case .ForwardSlash; #through;
		case .Bang; #through;
		case .Tilde; #through;
		case .Caret;   #through;
		case .Percent; #through;
		case .Ampersand; #through;
		case .Less; #through;
		case .LessEqual; #through;
		case .Greater; #through;
		case .GreaterEqual; #through;
		case .Pipe; #through;
		case .PipePipe; #through;
		case .AmpersandAmpersand; #through;
		case .BangEqual; #through;
		case .LessLess; #through;
		case .GreaterGreater; #through;
		case .Question; #through;
		case .PipeEqual; #through;
		case .CaretEqual; #through;
		case .AmpersandEqual; #through;
		case .GreaterGreaterEqual; #through;
		case .LessLessEqual; #through;
		case .PercentEqual; #through;
		case .ForwardSlashEqual; #through;
		case .AsteriskEqual; #through;
		case .MinusEqual; #through;
		case .PlusEqual; #through;
		case .EqualEqual; #through;
		case .Equals; #through;
		case .Comma;
			return true;
	}
	
	return false;
}


parse_unary :: (p: *Parser) -> *Node_Expr {
	result: *Node_Expr;
	if is_prefix_op(current(p)) {
		op := current(p);
		skip(p);
		rhs := parse_unary(p);
		unary := New(Node_Unary);
		unary.op = op;
		unary.expr = rhs;
		result = unary;
	} else if current(p).type == .LeftParenthesis && is_type_name(p, next(p)) {
		expect(p, .LeftParenthesis);
		base_info: Node_Type_Info;
		parse_declaration_specifiers(p, *base_info);
		declarator := parse_declarator(p);
		expect(p, .RightParenthesis);
		if current(p).type == .LeftBrace {
			compound := New(Node_Compound);
			compound.base_info = base_info;
			compound.declarator = declarator;
			compound.init = parse_initializer(p);
			result = compound;
		} else {
			_cast := New(Node_Cast);
			_cast.base_info = base_info;
			_cast.declarator = declarator;
			_cast.expr = parse_unary(p);
			result = _cast;
		}
	} else {
		lhs := parse_primary_expr(p);
		result = parse_postfix_expr(p, lhs);
	}
	return result;
}

parse_expr :: (p: *Parser, min_prec := 0) -> *Node_Expr {
	
	lhs := parse_unary(p);

	if !lhs return null;

	while true {
		op := current(p);
		prec := precedence_of(op);
		if prec < min_prec break;

		if !is_binary_op(op) then break;
		next_min := prec + is_left_associative(op).(int);
		if op.type == .Question {
			skip(p);
			ternary := New(Node_Ternary);
			ternary.cond = lhs;
			ternary.on_true = parse_expr(p);

			expect(p, .Colon);

			ternary.on_false = parse_expr(p, next_min);
			lhs = ternary;
		} else if is_assign_op(op) {
			skip(p);
			rhs := parse_expr(p, next_min);
			assign := New(Node_Assign);
			assign.op = op;
			assign.left = lhs;
			assign.right = rhs;
			lhs = assign;
		} else {
			skip(p);
			rhs := parse_expr(p, next_min);

			
			binary := New(Node_Binary);
			binary.op = op;
			binary.left = lhs;
			binary.right = rhs;
			lhs = binary;
		}
	}

	return lhs;
}

parse_postfix_expr :: (p: *Parser, lhs: *Node_Expr) -> *Node_Expr {
	result := lhs;
	while current(p).type == .Period || current(p).type == .LeftParenthesis ||
	      current(p).type == .LeftBracket || current(p).type == .Arrow ||
		  current(p).type == .PlusPlus || current(p).type == .MinusMinus {
		if current(p).type == .PlusPlus || current(p).type == .MinusMinus {
			unary := New(Node_Unary);
			unary.op = current(p);
			skip(p);
			unary.expr = lhs;
			unary.postfix = true;
			result = unary;
		} else if current(p).type == .Period {
			access := New(Node_Member_Access);
			access.op = current(p);
			skip(p);
			access.left = result;
			access.right = current(p);
			result = access;
			expect(p, .Identifier);
		} else if current(p).type == .LeftBracket {
			skip(p);
			access := New(Node_Array_Access);
			access.offset = parse_expr(p);
			access.left = result;
			result = access;
			expect(p, .RightBracket);
		} else if current(p).type == .LeftParenthesis {
			skip(p);
			call := New(Node_Call);
			call.id = result;
			while current(p).type != .RightParenthesis {
				array_add(*call.params, parse_expr(p, precedence_of(.Comma) + 1));
				if current(p).type != .RightParenthesis {
					expect(p, .Comma);
				}
			}
			expect(p, .RightParenthesis);
			result = call;
		} else if current(p).type == .Arrow {
			access := New(Node_Member_Access);
			access.left = result;
			access.op = current(p);
			skip(p);
			access.right = current(p);
			skip(p);
			result = access;
		}
	}
	return result;
}

// Temporarily return integer
parse_primary_expr :: (p: *Parser) -> *Node_Expr {
	// This needs to be done properly, currently it only does a single number...
	result: *Node_Expr;
	if current(p).type == .Number {
		result = New(Node_Number);
		result.(*Node_Number).token = current(p);
		value: int;
		for current(p).view {
			value = value * 10 + it - #char "0";
		}
		skip(p);
		result.(*Node_Number).value = value;
	} else if current(p).type == .Char {
		result = New(Node_Number);
		result.(*Node_Number).token = current(p);
		value: int;
		for current(p).view {
			value = value * 10 + it;
		}
		skip(p);
		result.(*Node_Number).value = value;
	} else if current(p).type == .String {
		result = New(Node_String);
		result.(*Node_String).token = current(p);
		skip(p);
	} else if current(p).type == .LeftParenthesis {
		expect(p, .LeftParenthesis);
		result = parse_expr(p);
		expect(p, .RightParenthesis);
	} else if current(p).type == .Identifier {
		result = New(Node_Identifier);
		result.(*Node_Identifier).id = current(p);
		skip(p);
	}
	return result;
}

eval_expr :: (node: *Node_Expr) -> int {
	if !node return 0;
	if node.expr_type == {
	case Node_Binary;
		left := eval_expr(node.(*Node_Binary).left);
		right := eval_expr(node.(*Node_Binary).right);
		if node.(*Node_Binary).op.type == {
		case .Plus; return left + right;
		case .Minus; return left - right;
		case .Asterisk; return left * right;
		case .ForwardSlash; return left / right;
		case; assert(false);
		}
	case Node_Unary;
		right := eval_expr(node.(*Node_Unary).expr);
		if node.(*Node_Unary).op .type== {
		case .Plus; return +right;
		case .Minus; return -right;
		}
	case Node_Number;
		return node.(*Node_Number).value;
	case;
		return 0;
	}
	return 0;
}

print_designation :: (node: *Node_Designation) {
	if !node return;
	for node.designators {
		if it.designator_type == {
			case Node_Field_Designator;
				print(".");
				print(it.(*Node_Field_Designator).name.view);
			case Node_Index_Designator;
				print("[");
				print_expr(it.(*Node_Index_Designator).offset);
				print("]");
		}
	}

	if node.designators.count > 0 {
		print(" = ");
	}
	print_init(node.expr);
}

print_init :: (node: *Node_Initializer) {
	if !node return;
	if node.initializer_type == {
		case Node_Designated_Initializer;
			print("{");
			for node.(*Node_Designated_Initializer).designations {
				print_designation(it);

				if it_index < node.(*Node_Designated_Initializer).designations.count - 1 then print(", ");
			}
			print("}");
		case Node_Scalar_Initializer;
			print_expr(node.(*Node_Scalar_Initializer).expr);
	}
}

print_expr :: (node: *Node_Expr, parent_precedence := 0) {
	if !node return;
	if node.expr_type == {
	case Node_Assign;
		precedence := precedence_of(node.(*Node_Assign).op);
		if precedence <= parent_precedence {
			print("(");
		}
		left := print_expr(node.(*Node_Assign).left, precedence);
		print(" % ", node.(*Node_Assign).op.view);
		right := print_expr(node.(*Node_Assign).right, precedence);
		if precedence <= parent_precedence {
			print(")");
		}
	case Node_Cast;
		print("(");
		print_type(node.(*Node_Cast).base_info);
		print_declarator(node.(*Node_Cast).declarator);
		print(")");
		print_expr(node.(*Node_Cast).expr);
	case Node_Compound;
		print("(");
		print_type(node.(*Node_Compound).base_info);
		print_declarator(node.(*Node_Compound).declarator);
		print(")");
		print_init(node.(*Node_Compound).init);
	case Node_Binary;
		precedence := precedence_of(node.(*Node_Binary).op);
		if precedence <= parent_precedence {
			print("(");
		}
		left := print_expr(node.(*Node_Binary).left, precedence);
		print(" % ", node.(*Node_Binary).op.view);
		right := print_expr(node.(*Node_Binary).right, precedence);
		if precedence <= parent_precedence {
			print(")");
		}
	case Node_Unary;
		if !node.(*Node_Unary).postfix {
			print("%", node.(*Node_Unary).op.view);
		}
		precedence := precedence_of(node.(*Node_Unary).op);
		if precedence <= parent_precedence {
			print("(");
		}
		print_expr(node.(*Node_Unary).expr);
		if node.(*Node_Unary).postfix {
			print("%", node.(*Node_Unary).op.view);
		}
		if precedence <= parent_precedence {
			print(")");
		}
	case Node_Ternary;
		print_expr(node.(*Node_Ternary).cond, precedence_of(.Question));
		print(" ? ");
		print_expr(node.(*Node_Ternary).on_true);
		print(" : ");
		print_expr(node.(*Node_Ternary).on_false, precedence_of(.Question));
	case Node_Number;
		//print("%", node.(*Node_Number).value);
		print(node.(*Node_Number).token.view);
	case Node_String;
		print("\"%\"", node.(*Node_String).token.view);
	case Node_Identifier;
		print("%", node.(*Node_Identifier).id.view);
	case Node_Call;
		print_expr(node.(*Node_Call).id);
		print("(");
		for node.(*Node_Call).params {
			print_expr(it);
			if it_index < node.(*Node_Call).params.count - 1 then print(", ");
		}
		print(")");
	case Node_Array_Access;
		print_expr(node.(*Node_Array_Access).left);
		print("[");
		print_expr(node.(*Node_Array_Access).offset);
		print("]");
	case Node_Member_Access;
		print_expr(node.(*Node_Member_Access).left);
		print("%", node.(*Node_Member_Access).op.view);
		print("%", node.(*Node_Member_Access).right.view);
	}
}

parse_param_decl :: (p: *Parser) -> *Node_Decl {
	decl := New(Node_Decl);
	parse_declaration_specifiers(p, *decl.base_info);
	array_add(*decl.declarators, parse_declarator(p));
	return decl;
}

parse_direct_declarator :: (p: *Parser) -> *Node_Declarator {
	declarator: *Node_Declarator;
	if current(p).type == .LeftParenthesis {
		skip(p);
		declarator = parse_declarator(p);
		expect(p, .RightParenthesis);
	} else if current(p).type == .Identifier {
		declarator = New(Node_Identifier_Declarator);
		declarator.(*Node_Identifier_Declarator).name = current(p).view;
		skip(p);
	}

	while current(p).type == .LeftParenthesis || current(p).type == .LeftBracket {
		if current(p).type == .LeftParenthesis {
			expect(p, .LeftParenthesis);
			func := New(Node_Function_Declarator);
			while current(p).type != .RightParenthesis {
				if current(p).type == .Ellipsis {
					skip(p);
				} else {
					array_add(*func.(*Node_Function_Declarator).params, parse_param_decl(p));
				}
				if current(p).type == .Comma then skip(p);
			}
			expect(p, .RightParenthesis);
			func.inner = declarator;
			declarator = func;
		} else if current(p).type == .LeftBracket {
			array := New(Node_Array_Declarator);
			expect(p, .LeftBracket);
			if current(p).view == "static" then skip(p);
			if is_type_qualifier(current(p)) {
				skip(p);
			}
			if current(p).type == .Asterisk then skip(p);
			
			expr := parse_expr(p, 0);
			array.count = eval_expr(expr);
			array.inner = declarator;
			declarator = array;
			expect(p, .RightBracket);
		}
	}
	return declarator;
}

parse_declarator :: (p: *Parser) -> *Node_Declarator {
	first: *Node_Pointer_Declarator;
	last: *Node_Pointer_Declarator;
	while current(p).type == .Asterisk {
		skip(p);
		next := New(Node_Pointer_Declarator);
		while is_type_qualifier(current(p)) {
			array_add(*next.qualifiers, current(p).view);
			skip(p);
		}
		if !first {
			first = next;
		} else {
			last.inner = next;
		}
		last = next;
	}

	base := parse_direct_declarator(p);
	if first {
		last.inner = base;
		return first;
	}

	return base;
}

identifier_from_declarator :: (declarator: *Node_Declarator) -> string {
	find_identifier :: (declarator: *Node_Declarator) -> string {
		if declarator.declarator_type == Node_Identifier_Declarator {
			return declarator.(*Node_Identifier_Declarator).name;
		} else {
			found := find_identifier(declarator.inner);
			if found return found;
		}
		return "";
	}
	return find_identifier(declarator);
}

parse_initializer :: (p: *Parser) -> *Node_Initializer {
	initializer: *Node_Initializer;
	if current(p).type == .LeftBrace {
		skip(p);
		designated := New(Node_Designated_Initializer);
		while current(p).type != .RightBrace {
			designation := New(Node_Designation);
			equals := false;
			while current(p).type == .LeftBracket ||
				  current(p).type == .Period {
				if current(p).type == .LeftBracket {
					expect(p, .LeftBracket);
					index := New(Node_Index_Designator);
					index.offset = parse_expr(p);
					expect(p, .RightBracket);
					array_add(*designation.designators, index);
				} else if current(p).type == .Period {
					expect(p, .Period);
					field := New(Node_Field_Designator);
					field.name = current(p);
					expect(p, .Identifier);
					array_add(*designation.designators, field);
				}
				equals = true;
			}
			if equals {
				expect(p, .Equals);
			}

			designation.expr = parse_initializer(p);
			if current(p).type == .Comma {
				skip(p);
			}
			array_add(*designated.designations, designation);
		}
		initializer = designated;
		expect(p, .RightBrace);
	} else {
		scalar := New(Node_Scalar_Initializer);
		scalar.expr = parse_expr(p, precedence_of(.Comma) + 1);
		initializer = scalar;
	}
	assert(initializer != null);
	return initializer;
}

parse_statement :: (p: *Parser) -> *Node_Statement {
	statement: *Node_Statement;
	if current(p).type == .LeftBrace {
		expect(p, .LeftBrace);
		block := New(Node_Block);
		while current(p).type != .RightBrace {
			if is_declaration_start(p) {
				decl_stmt := New(Node_Decl_Statement);
				decl_stmt.decl = parse_decl(p);
				expect(p, .Semicolon);
				array_add(*block.statements, decl_stmt);
			} else {
				array_add(*block.statements, parse_statement(p));
			}
		}
		expect(p, .RightBrace);
		statement = block;
	} else {
		if current(p).type == .Identifier {
			if next(p).type == .Colon || current(p).view == "case" || current(p).view == "default" {
				label := New(Node_Label);
				if current(p).view == "case" {
					skip(p);
					label.is_case = true;
				}
				label.token = current(p);
				skip(p);
				expect(p, .Colon);
				label.statement = parse_statement(p);
				statement = label;
			} else if current(p).view == "continue" {
				statement = New(Node_Continue);
			} else if current(p).view == "break" {
				statement = New(Node_Break);
			}  else if current(p).view == "goto" {
				goto := New(Node_Goto);
				skip(p);
				goto.to = current(p);
				expect(p, .Identifier);
			} else if current(p).view == "return" {
				skip(p);
				ret := New(Node_Return);
				ret.expr = parse_expr(p);
				statement = ret;
				expect(p, .Semicolon);
			} else if current(p).view == "for" {
				skip(p);
				_for := New(Node_For);
				expect(p, .LeftParenthesis);
				_for.init = parse_decl(p);
				expect(p, .Semicolon);
				_for.cond = parse_expr(p);
				expect(p, .Semicolon);
				_for.expr = parse_expr(p);
				expect(p, .RightParenthesis);
				_for.body = parse_statement(p);
				statement = _for;
			} else if current(p).view == "while" {
				skip(p);
				_while := New(Node_While);
				expect(p, .LeftParenthesis);
				_while.cond = parse_expr(p);
				expect(p, .RightParenthesis);
				_while.body = parse_statement(p);
				statement = _while;
			} else if current(p).view == "do" {
				skip(p);
				_do := New(Node_Do);
				_do.body = parse_statement(p);
				expect(p, .LeftParenthesis);
				_do.cond = parse_expr(p);
				expect(p, .RightParenthesis);
				statement = _do;
			} else if current(p).view == "switch" {
				skip(p);
				_switch := New(Node_Switch);
				expect(p, .LeftParenthesis);
				_switch.expr = parse_expr(p);
				expect(p, .RightParenthesis);
				_switch.body = parse_statement(p);
				statement = _switch;
			} else if current(p).view == "if" {
				skip(p);
				_if := New(Node_If);
				expect(p, .LeftParenthesis);
				_if.cond = parse_expr(p);
				expect(p, .RightParenthesis);
				_if.on_true = parse_statement(p);
				if current(p).view == "else" {
					skip(p);
					_if.on_false = parse_statement(p);
				}
				statement = _if;
			} else {
				expr_stmt := New(Node_Expr_Statement);
				expr_stmt.expr = parse_expr(p);
				statement = expr_stmt;
				expect(p, .Semicolon);
			}
		} else if current(p).type == .Semicolon {
			expect(p, .Semicolon);
		} else {
			expr_stmt := New(Node_Expr_Statement);
			expr_stmt.expr = parse_expr(p);
			statement = expr_stmt;
			expect(p, .Semicolon);
		}
	}
	return statement;
}

parse_translation_unit :: (p: *Parser) -> *Node_Translation_Unit {
	result := New(Node_Translation_Unit);
	while p.at < p.tokens.count {
		decl := parse_decl(p);
		if !decl.body {
			expect(p, .Semicolon);
		}
		array_add(*result.declarations, decl);
	}
	return result;
}

parse_decl :: (p: *Parser) -> *Node_Decl {
	type: Node_Type_Info;
	parse_declaration_specifiers(p, *type);

	decl := New(Node_Decl);
	decl.base_info = type;
	while current(p).type != .Semicolon &&
		  current(p).type != .LeftBrace {
		declarator := parse_declarator(p);
		array_add(*decl.declarators, declarator);
		if current(p).type == .Equals {
			skip(p);
			declarator.init = parse_initializer(p);
		}
		if current(p).type != .Semicolon &&
		   current(p).type != .LeftBrace {
			expect(p, .Comma);
		}
	}

	if is_typedef(decl.base_info) {
		for decl.declarators {
			// This should probably always be true?
			id := identifier_from_declarator(it); 
			if id != "" {
				print("Adding typedef\n");
				table_add(*p.typedefs, id, decl);
			}
		}
	}

	if current(p).type == .LeftBrace {
		decl.body = parse_statement(p);
	}
	
	return decl;
}

indent :: (depth: int) {
	for 0..depth*4 print(" ");
}


print_type :: (info: Node_Type_Info) {	
	print("%", info.storage_class);
	if info.storage_class {
		print(" ");
	}
	
	if info._struct {
		if info._struct.is_union {
			print("enum ");
		}else {
			print("struct ");
		}
		print(info._struct.name.view);
		print(" {\n");
		for info._struct.members {
			print("    ");
			print_decl(it);
			print(";\n");
		}
		print("} ");
	}

	if info._enum {
		print("enum ");
		print(info._enum.name.view);
		print(" {\n");
		for info._enum.members {
			print("    ");
			print(it.name.view);
			print(" ");
			if it.expr {
				print("= ");
				print_expr(it.expr);
			}

			print(",\n");
		}
		print("} ");
	}

	for info.qualifiers {
		print("% ", it);
	}
	for info.specifiers {
		print("% ", it);
	}
}

print_declarator :: (declarator: *Node_Declarator, parent_was_function_or_array := false) {
	if !declarator then return;
	if declarator.declarator_type == {
	case Node_Pointer_Declarator;
		if parent_was_function_or_array {
			print("(");
		}
		print("*");
		for declarator.qualifiers {
			print("% ", it);
		}
		print_declarator(declarator.inner, false);
		if parent_was_function_or_array {
			print(")");
		}
	case Node_Function_Declarator;
		print_declarator(declarator.inner, true);
		func := declarator.(*Node_Function_Declarator);
		print("(");
		for func.params {
			if !it break;
			print_type(it.base_info);
			print_declarator(it.declarators[0], false);
			if it_index < func.params.count - 1 then print(", ");
		}
		print(")");
	case Node_Identifier_Declarator;
		print_declarator(declarator.inner, false);
		print("%", declarator.(*Node_Identifier_Declarator).name);
	case Node_Array_Declarator;
		print_declarator(declarator.inner, true);
		print("[%]", declarator.(*Node_Array_Declarator).count);
	}
	if declarator.init {
		print(" = ");
		print_init(declarator.init);
	}
}


print_decl :: (decl: *Node_Decl) {
	print_type(decl.base_info);
	for decl.declarators {
		print_declarator(it);
		if it_index < decl.declarators.count - 1 then print(", ");
	}

	if decl.body {
		print_statement(decl.body);
	}
}

print_statement :: (stmt: *Node_Statement, depth := 0) {

	if stmt.statement_type == {
		case Node_Break;
			print("break");
		case Node_Continue;
			print("continue");
		case Node_Goto;
			print("goto ");
			print(stmt.(*Node_Goto).to.view);
		case Node_Return;
			print("return ");
			print_expr(stmt.(*Node_Return).expr);
			print(";\n");
		case Node_Block;
			print("{\n");
			for stmt.(*Node_Block).statements {
				indent(depth + 1);
				print_statement(it, depth + 1);
			}
			indent(depth);
			print("}");
		case Node_If;
			print("if ");
			print("(");
			print_expr(stmt.(*Node_If).cond);
			print(") ");
			print_statement(stmt.(*Node_If).on_true, depth);
			if stmt.(*Node_If).on_false {
				print(" else ");
				print_statement(stmt.(*Node_If).on_false, depth);
			}
			print("\n");
		case Node_While;
			print("while ");
			print("(");
			print_expr(stmt.(*Node_While).cond);
			print(")");
			print_statement(stmt.(*Node_While).body, depth);
			print("\n");
		case Node_Do;
			print("do ");
			print_statement(stmt.(*Node_Do).body, depth);
			print("(");
			print_expr(stmt.(*Node_Do).cond);
			print(")");
		case Node_Switch;
			print("switch ");
			print("(");
			print_expr(stmt.(*Node_Switch).expr);
			print(")");
			print_statement(stmt.(*Node_Do).body, depth);
			print("\n");
		case Node_Label;
			if stmt.(*Node_Label).is_case {
				print("case ");
			}
			print(stmt.(*Node_Label).token.view);
			print(": ");
			print_statement(stmt.(*Node_Label).statement, depth);
			print("\n");
		case Node_For;
			print("for ");
			print("(");
			print_decl(stmt.(*Node_For).init);
			print("; ");
			print_expr(stmt.(*Node_For).cond);
			print("; ");
			print_expr(stmt.(*Node_For).expr);
			print(") ");
			print_statement(stmt.(*Node_For).body, depth);
			print("\n");
		case Node_Decl_Statement;
			print_decl(stmt.(*Node_Decl_Statement).decl);
			print(";\n");
		case Node_Expr_Statement;
			print_expr(stmt.(*Node_Expr_Statement).expr);
			print(";\n");
	}
}

main :: () {
	t0 := current_time_monotonic();


	minimal := read_entire_file("tests/cpp/minimal.c");
	minimal = #string STRING
	#if -(-5) != 5 || +5 != 5 || !0 != 1 || !!1 != 1
	#error "TEST 20 FAILED: Unary operators"
	#endif
	STRING
	tokeniser: Tokeniser;
	tokeniser.source = minimal;
	tokenise(*tokeniser);

	tokens := preprocess(*tokeniser);

	output: string;
	for tokens {
		output = join(output, tprint("% ", it.view));
	}
	write_entire_file("processed.c", output);

	tokens_no_newlines: [..]Token;
	for tokens {
		if it.type != .Newline {
			array_add(*tokens_no_newlines, it);
		}
	}

	parser: Parser;
	parser.tokens = tokens_no_newlines;

	tu := parse_translation_unit(*parser);

	t1 := current_time_monotonic();

	dt := t1 - t0;
	ms := 1000*to_float64_seconds(dt);

	for tu.declarations {
		print_decl(it);
		if !it.body {
			print(";");
		}
		print("\n");
	}

	print("it took HOW long? %ms\n", ms);
}