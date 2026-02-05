#import "Basic";
#import "File";
#import "File_Utilities";
#import "Process";

#import "Hash_Table";
#import "Hash";

#import "String";

#load "cpp.jai";
#load "typecheck.jai";
#load "compile.jai";

Token_Type :: enum {
	Invalid;
	Hash;
	HashHash;
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

Number_Type :: enum {
	Invalid;
	Hexadecimal;
	Decimal;
	Binary;
	Octal;
	Float;
}

Token :: struct {
	view: string;
	type: Token_Type;
	// Dumb?
	number_type: Number_Type;
	// Lord have mercy
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

	ordinary: Table(string, *Node);
	structs: Table(string, *Node_Struct);
	enums: Table(string, *Node_Enum);
	typedefs: Table(string, *Node_Decl);

	// Each string gets a unique index
	strings: Table(string, int);
	str_count: int;
}

Node :: struct {
	type: Type;
}

Node_Decl_Info :: struct {
	qualifiers: [..]string;
	specifiers: [..]string;
	storage_class: string;
	_struct: *Node_Struct;
	_enum: *Node_Enum;
	reference: bool;
	atomic: *Node_Decl_Info;
	declarators: [..]*Node_Declarator;
	typedef: *Node_Decl;
}

Node_Composite :: struct {
	type: Type;
}

Node_Struct :: struct {
	#as using _: Node_Composite;
	type = #this;
	name: Token;
	is_union: bool;
	members: [..]*Node_Decl;
}

Node_Enum_Member :: struct {
	name: Token;
	expr: *Node_Expr;
}

Node_Enum :: struct {
	#as using _:Node_Composite;
	type = #this;
	name: Token;
	members: [..]*Node_Enum_Member;
}

Node_Declarator :: struct {
	#as using node: Node;
	qualifiers: [..]string;
	declarator_type: Type;
	init: *Node_Initializer;
	bitfield: *Node_Expr;
	inner: *Node_Declarator;
	resolved_type: *Resolved_Type;
}

Node_Function_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = #this;
	params: [..]*Node_Decl;
	variadic: bool;
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
	using base: Node_Decl_Info;
	body: *Node_Statement;
}

Node_Expr :: struct {
	#as using _: Node;
	type = #this;
	expr_type: Type;
	resolved_type: *Resolved_Type;
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
	base: Node_Decl_Info;
	expr: *Node_Expr;
	expr_type = #this;
}

Node_Sizeof_Type :: struct {
	#as using node: Node_Expr;
	base: Node_Decl_Info;
	expr_type = #this;
}

Node_Sizeof_Expr :: struct {
	#as using node: Node_Expr;
	expr: *Node_Expr;
	expr_type = #this;
}

Node_Compound :: struct {
	#as using node: Node_Expr;
	declarator: *Node_Declarator;
	base_info: Node_Decl_Info;
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
	args: [..]*Node_Expr;
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
	index: *Node_Expr;
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
	kind: enum { FLOAT; INTEGER; };
	as_u64: u64;
	as_f64: float64;
	token_with_suffix: Token;
}

Node_String :: struct {
	#as using node: Node_Expr;
	expr_type = #this;
	token: Token;
}

Node_Char :: struct {
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
	resolved_type: *Resolved_Type;
	designators: [..]*Node_Designator;
	expr: *Node_Initializer;
	// HACK(Oliver): This just feels weird
	member_index: int;
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
	index: *Node_Expr;
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
	expr: *Node_Expr;
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

is_suffix :: (char: int) -> bool {
	return char == #char "e" ||
	char == #char "E" ||
	char == #char "l" ||
	char == #char "L" ||
	char == #char "U" ||
	char == #char "u" ||
	char == #char "w" ||
	char == #char "b" ||
	char == #char "W" ||
	char == #char "f" ||
	char == #char "F" ||
	char == #char "d" ||
	char == #char "D" ||
	char == #char "B";
}

tokenise :: (t: *Tokeniser) {
	is_ws    :: (t: *Tokeniser) -> bool   { if t.at >= t.source.count return false; return t.source[t.at] == #char " " || t.source[t.at] == #char "\t"; }
	is_newline :: (t: *Tokeniser) -> bool { if t.at >= t.source.count return false; return t.source[t.at] == #char "\n" || t.source[t.at] == #char "\r"; }
	is_ident :: (t: *Tokeniser) -> bool   { if t.at >= t.source.count return false; return t.source[t.at] == #char "_" || ((t.source[t.at] >= #char "a") && (t.source[t.at] <= #char "z")) || ((t.source[t.at] >= #char "A") && (t.source[t.at] <= #char "Z")); }
	is_num   :: (t: *Tokeniser) -> bool   { if t.at >= t.source.count return false; return t.source[t.at] >= #char "0" && t.source[t.at] <= #char "9"; }
	gobble_ws :: (t: *Tokeniser) { while t.at < t.source.count && is_ws(t) { t.at += 1; } }
	is_char :: (t: *Tokeniser, char: int)  -> bool { if t.at >= t.source.count return false; return t.source[t.at] == char; }
	is_prefix :: (t: *Tokeniser, prefix: string) -> bool {
		if t.at + prefix.count >= t.source.count return false;
		to_compare: string;
		to_compare.data = t.source.data + t.at;
		to_compare.count = prefix.count;
		return to_compare == prefix;
	}
	token_from_number_literal :: (t: *Tokeniser) -> Token {
		token: Token;
		token.view.count = 1;
		if is_prefix(t, "0x") || is_prefix(t, "0X") {
			token.number_type = .Hexadecimal;	
			t.at += 2;
		} else if is_prefix(t, "0b") || is_prefix(t, "0B") {
			token.number_type = .Binary;
			t.at += 2;
		} else if is_char(t, #char ".") {
			token.number_type = .Float;
		} else if is_char(t, #char "0") {
			if is_prefix(t, "0.") ||
			   is_prefix(t, "0e") ||
			   is_prefix(t, "0E") {
				token.number_type = .Float;
			} else {
				token.number_type = .Octal;
			}
		} else if is_num(t) {
			token.number_type = .Decimal;
		}
		start := t.at;
		token.view.data = t.source.data + start;
		is_bin_digit :: (t: *Tokeniser) -> bool {
			return is_char(t, #char "1") || is_char(t, #char "0");
		}
		is_hex_digit :: (t: *Tokeniser) -> bool {
			return is_num(t) || (t.source[t.at] >= #char "a" && t.source[t.at] <= #char "f") ||
			(t.source[t.at] >= #char "A" && t.source[t.at] <= #char "F");
		}
		is_oct_digit :: (t: *Tokeniser) -> bool {
			return  t.source[t.at] >= #char "0" && t.source[t.at] <= #char "7";
		}
		if token.number_type == {
			case .Invalid;
				assert(false);
			case .Binary;
				while t.at < t.source.count {
					if is_bin_digit(t) {
						t.at += 1;
						if is_char(t, #char "'") {
							t.at += 1;
						}
					} else {
						break;
					}
				}
			case .Hexadecimal;
				while t.at < t.source.count {
					if is_hex_digit(t) {
						t.at += 1;
						if is_char(t, #char "'") {
							t.at += 1;
						}
					} else {
						break;
					}
				}
			case .Octal;
				while t.at < t.source.count {
					if is_oct_digit(t) {
						t.at += 1;
						if is_char(t, #char "'") {
							t.at += 1;
						}
					} else {
						break;
					}
				}
			case .Decimal; #through;
			case .Float;
				// HACK(Oliver): The apostrophe handling is kinda jank
				while t.at < t.source.count {
					if is_num(t) {
						t.at += 1;
						if is_char(t, #char "'") {
							t.at += 1;
						}
					} else if is_char(t, #char ".") {
						token.number_type = .Float;
						t.at += 1;
					} else if is_char(t, #char "e") ||
							  is_char(t, #char "E") {
						token.number_type = .Float;
						t.at += 1;
					} else {
						break;
					}
				}
			case;
				assert(false);
		}
		// HACK(Oliver): Need to better error check the suffixes
		while t.at < t.source.count && is_suffix(t.source[t.at]) {
			t.at += 1;
		}
		token.type = .Number;
		assert(token.number_type != .Invalid);
		token.view.count = t.at - start;
		return token;
	}
	while t.at < t.source.count {
		token: Token;
		token.view.data = t.source.data + t.at;
		token.view.count = 1;
		if is_ws(t) {
			gobble_ws(t);
			continue;
		} else if is_num(t) {
			token = token_from_number_literal(t);
		} else {
			if t.source[t.at] == {
			case "=";
				t.at += 1; token.type = .Equals;
				if is_char(t, #char "=") {
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
			case "#";
				token.type = .Hash;
				t.at += 1;
				if is_char(t , #char "#") {
					token.type = .HashHash;
					t.at += 1;
					token.view.count += 1;
				}
			case "\n"; #through;
			case "\r"; t.at += 1; token.type = .Newline;
			case "*";
				t.at += 1; token.type = .Asterisk;
				if is_char(t, #char "=") {
					token.type = .AsteriskEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "&";
				t.at += 1; token.type = .Ampersand;
				if is_char(t, #char "&") {
					t.at += 1;
					token.view.count += 1;
					token.type = .AmpersandAmpersand;
				} else if is_char(t, #char "=") {
					t.at += 1;
					token.view.count += 1;
					token.type = .AmpersandEqual;
				}
			case "~"; t.at += 1; token.type = .Tilde;
			case "^";
				t.at += 1; token.type = .Caret;
				if is_char(t, #char "=") {
					t.at += 1;
					token.view.count += 1;
					token.type = .CaretEqual;
				}
			case "%";
				t.at += 1; token.type = .Percent;
				if is_char(t, #char "=") {
					t.at += 1;
					token.view.count += 1;
					token.type = .PercentEqual;
				}
			case "!";
				t.at += 1; token.type = .Bang;
				if is_char(t, #char "=") {
					t.at += 1;
					token.view.count += 1;
					token.type = .BangEqual;
				}
			case "+";
				t.at += 1; token.type = .Plus;
				if is_char(t, #char "+") {
					token.type = .PlusPlus;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char "=") {
					token.type = .PlusEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "-"; 
				t.at += 1; token.type = .Minus;
				if is_char(t, #char "-") {
					token.type = .MinusMinus;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char "=") {
					token.type = .MinusEqual;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char ">") {
					token.type = .Arrow;
					t.at += 1;
					token.view.count += 1;
				}
			case "/";
				t.at += 1; token.type = .ForwardSlash;
				if is_char(t, #char "="){
					token.type = .ForwardSlashEqual;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char "/") {
					while t.at < t.source.count && !is_newline(t) {
						t.at += 1;
					}
					continue;
				} else if is_char(t, #char "*") {
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
				if is_newline(t) {
					t.at += 1;
				}
				continue;
			case ".";
				if is_prefix(t, "...") {
					token.type = .Ellipsis;
					t.at += 3;
					token.view.count = 3;
				} else if t.at + 1 < t.source.count && is_digit(t.source[t.at + 1]) {
					token = token_from_number_literal(t);
				} else {
					token.type = .Period;
					t.at += 1;
				}
			case "|";
				t.at += 1; token.type = .Pipe;
				if is_char(t, #char "|") {
					token.type = .PipePipe;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char "=") {
					token.type = .PipeEqual;
					t.at += 1;
					token.view.count += 1;
				}
			case "<";
				t.at += 1; token.type = .Less;
				if is_char(t, #char "=") {
					token.type = .LessEqual;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char "<") {
					t.at += 1;
					token.type = .LessLess;
					token.view.count += 1;
					if is_char(t, #char "=") {
						t.at += 1;
						token.view.count += 1;
						token.type = .LessLessEqual;
					}
				}
			case ">";
				t.at += 1; token.type = .Greater;
				if is_char(t, #char "=") {
					token.type = .GreaterEqual;
					t.at += 1;
					token.view.count += 1;
				} else if is_char(t, #char ">") {
					t.at += 1;
					token.type = .GreaterGreater;
					if is_char(t, #char "=") {
						t.at += 1;
						token.view.count += 1;
						token.type = .GreaterGreaterEqual;
					}
				}
			case;
				if is_ident(t) {
					token.type = .Identifier;
					while is_ident(t) || is_char(t, #char "_")  ||
							is_num(t) {
						t.at += 1;
					}
					token.view.count = t.source.data + t.at - token.view.data;
				} else if is_char(t, #char "\"") {
					token.type = .String;
					t.at += 1;
					while !is_char(t, #char "\"") {
						// HACK(Oliver): Temporary fix, properly handle escape
						// sequences
						if t.at + 1 < t.source.count && t.source[t.at] == "\\" &&
						   t.source[t.at + 1] == "\"" {
							t.at += 1;
						}
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
				} else {
					token.type = .Invalid;
					while !is_ws(t) {
						t.at += 1;
					}
					token.view.count = t.source.data + t.at - token.view.data - 2;
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
		for max(0, p.at - 20)..p.at + 20 {
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


is_typedef :: (info: Node_Decl_Info) -> bool {
	return info.storage_class == "typedef";
}

is_type_qualifier :: (token: Token) -> bool {
	if token.view == {
	case "const";    #through;
	case "volatile"; #through;
	case "_Atomic"; #through;
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
	case "__uint128_t"; #through;
	case "_Atomic"; #through;
	case "_Bool"; #through;
	case "__builtin_va_list"; #through;
	case "bool";
		return true;
	case;
		return false;
	}
}

is_function_specifier :: (token: Token) -> bool {
	return token.view == "inline";
}


parse_declaration_specifiers :: (p: *Parser, info: *Node_Decl_Info) {
	while is_declaration_start(p) {
		if is_storage_specifier(current(p)) {
			info.storage_class = current(p).view;
			skip(p);
		} else if current(p).view == "struct" || current(p).view == "union" {
			struct_or_union := current(p).view;
			skip(p);
			_struct: *Node_Struct;
			
			if current(p).type == .Identifier {
				name := current(p);
				skip(p);
				defined, defined_struct := table_find(*p.structs, name.view);
				if current(p).type == .LeftBrace {
					if defined {
						_struct = defined_struct;
					} else {
						_struct = New(Node_Struct);
						_struct.name = name;
						table_add(*p.structs, name.view, _struct);
					}
					skip(p); // '{'
					while current(p).type != .RightBrace {
						decl := parse_decl(p);
						expect(p, .Semicolon);
						array_add(*_struct.members, decl);
					}
					expect(p, .RightBrace);
					info.reference = false;
				} else {
					if defined {
						_struct = defined_struct;
					} else {
						_struct = New(Node_Struct);
						_struct.name = name;
						table_add(*p.structs, name.view, _struct);
					}
					info.reference = true;
				}
			} else if current(p).type == .LeftBrace {
				skip(p);
				_struct = New(Node_Struct);
				while current(p).type != .RightBrace {
					decl := parse_decl(p);
					expect(p, .Semicolon);
					array_add(*_struct.members, decl);
				}
				expect(p, .RightBrace);
				info.reference = false;
			}
			if struct_or_union == "union" {
				_struct.is_union = true;
			}
			info._struct = _struct;
		} else if current(p).view == "enum" {
			skip(p);
			_enum: *Node_Enum;

			if current(p).type  == .Identifier {
				name := current(p);
				skip(p);

				defined, defined_enum := table_find(*p.enums, name.view);
				if current(p).type == .LeftBrace {
					if defined {
						_enum = defined_enum;
					} else {
						_enum = New(Node_Enum);
						_enum.name = name;
						table_add(*p.enums, name.view, _enum);
					}
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
					info.reference = false;
				} else {
					if defined {
						_enum = defined_enum;
					} else {
						_enum = New(Node_Enum);
						_enum.name = name;
						table_add(*p.enums, name.view, _enum);
					}
					info.reference = true;
				}
			} else if current(p).type == .LeftBrace {
				skip(p);
				_enum = New(Node_Enum);
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
				info.reference = false;
			}
			info._enum = _enum;
		} else if is_declaration_start(p, current(p)) {
			if current(p).view == "_Atomic" {
				skip(p);
				expect(p, .LeftParenthesis);
				atomic_info := New(Node_Decl_Info);
				parse_declaration_specifiers(p, atomic_info);
				array_add(*atomic_info.declarators, parse_declarator(p));
				expect(p, .RightParenthesis);
				info.atomic = atomic_info;
			} else {
				_, info._struct = table_find(*p.structs, current(p).view);
				_, info._enum   = table_find(*p.enums, current(p).view);
				_, typedef_decl := table_find(*p.typedefs, current(p).view);
				info.typedef = typedef_decl;
				if info._enum || info._struct {
					info.reference = true;
				} else {
					array_add(*info.specifiers, current(p).view);
				}
				skip(p);
			}
		} else {
			// Is this even possible to enter here? Idk
			array_add(*info.qualifiers, current(p).view);
			_, info._struct = table_find(*p.structs, current(p).view);
			_, info._enum   = table_find(*p.enums, current(p).view);
			found, typedef_decl := table_find(*p.typedefs, current(p).view);
			info.typedef = typedef_decl;
			skip(p);
		}
	}
}

is_declaration_start :: (p: *Parser) -> bool {
	return is_storage_specifier(current(p)) ||
		   is_type_qualifier(current(p)) ||
		   is_type_specifier(current(p)) ||
		   is_function_specifier(current(p)) ||
		   current(p).view == "struct" ||
		   current(p).view == "enum" ||
		   current(p).view == "union" ||
		   table_contains(*p.typedefs, current(p).view);
}

is_declaration_start :: (p: *Parser, token: Token) -> bool {
	return is_storage_specifier(token) ||
		   is_type_qualifier(token) ||
		   is_type_specifier(token) ||
		   is_function_specifier(token) ||
		   token.view == "struct" ||
		   token.view == "enum" ||
		   token.view == "union" ||
		   table_contains(*p.typedefs, token.view);
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
	if current(p).view == "sizeof" {
		skip(p);
		if current(p).type == .LeftParenthesis {
			if is_declaration_start(p, next(p)) {
				skip(p);
				base_info: Node_Decl_Info;
				parse_declaration_specifiers(p, *base_info);
				declarator := parse_declarator(p);
				sizeof := New(Node_Sizeof_Type);
				array_add(*base_info.declarators, declarator);
				sizeof.base = base_info;
				expect(p, .RightParenthesis);
				result = sizeof;
			} else {
				sizeof := New(Node_Sizeof_Expr);
				sizeof.expr = parse_expr(p);
				result = sizeof;
			}
		} else {
			sizeof := New(Node_Sizeof_Expr);
			sizeof.expr = parse_expr(p);
			result = sizeof;
		}
	} else if is_prefix_op(current(p)) {
		op := current(p);
		skip(p);
		rhs := parse_unary(p);
		unary := New(Node_Unary);
		unary.op = op;
		unary.expr = rhs;
		result = unary;
	} else if current(p).type == .LeftParenthesis && is_declaration_start(p, next(p)) {
		expect(p, .LeftParenthesis);
		base_info: Node_Decl_Info;
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
			_cast.base = base_info;
			array_add(*_cast.base.declarators, declarator);
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
			access.index = parse_expr(p);
			access.left = result;
			result = access;
			expect(p, .RightBracket);
		} else if current(p).type == .LeftParenthesis {
			name := current(p);
			skip(p);
			call := New(Node_Call);
			call.id = result;
			while current(p).type != .RightParenthesis {
				array_add(*call.args, parse_expr(p, precedence_of(.Comma) + 1));
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
		token := current(p);
		result.(*Node_Number).token_with_suffix = token;
		// HACK(Oliver): This could include apostrophes, remove them
		// This will ignore any trailing letters, which is what we want but
		// might seem confusing
		result.(*Node_Number).kind = .INTEGER;
		if token.number_type == {
			case .Invalid;
				assert(false);
			case .Binary;
				result.(*Node_Number).as_u64 = string_to_int(token.view, 2, u64);
			case .Octal;
				result.(*Node_Number).as_u64 = string_to_int(token.view, 8, u64);
			case .Decimal;
				result.(*Node_Number).as_u64 = string_to_int(token.view, 10, u64);
			case .Hexadecimal;
				result.(*Node_Number).as_u64 = string_to_int(token.view, 16, u64);
			case .Float;
				result.(*Node_Number).kind = .FLOAT;
				result.(*Node_Number).as_f64 = string_to_float(token.view);
		}
		skip(p);
	} else if current(p).type == .Char {
		result = New(Node_Char);
		value: int;
		for current(p).view {
			value = value * 10 + it;
		}
		result.(*Node_Char).token = current(p);
		skip(p);
	} else if current(p).type == .String {
		result = New(Node_String);
		concat := current(p).view;
		skip(p);
		while current(p).type == .String {
			concat = join(concat, current(p).view);
			skip(p);
		}
		token: Token;
		token.view = concat;
		token.type = .String;
		result.(*Node_String).token = token;
		if !table_contains(*p.strings, token.view) {
			table_add(*p.strings, token.view, p.str_count);
			p.str_count += 1;
		}
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
		if node.(*Node_Number).kind == .FLOAT {
			return node.(*Node_Number).as_f64.(int);
		} else {	
			return node.(*Node_Number).as_u64.(int);
		}
	case;
		return 0;
	}
	return 0;
}

print_designation :: (builder: *String_Builder, node: *Node_Designation) {
	if !node return;
	for node.designators {
		if it.designator_type == {
			case Node_Field_Designator;
				append(builder, ".");
				append(builder, it.(*Node_Field_Designator).name.view);
			case Node_Index_Designator;
				append(builder, "[");
				print_expr(builder, it.(*Node_Index_Designator).index);
				append(builder, "]");
		}
	}

	if node.designators.count > 0 {
		append(builder, " = ");
	}
	print_init(builder, node.expr);
}

print_init :: (builder: *String_Builder, node: *Node_Initializer) {
	if !node return;
	if node.initializer_type == {
		case Node_Designated_Initializer;
			append(builder, "{");
			for node.(*Node_Designated_Initializer).designations {
				print_designation(builder, it);

				if it_index < node.(*Node_Designated_Initializer).designations.count - 1 then append(builder, ", ");
			}
			append(builder, "}");
		case Node_Scalar_Initializer;
			print_expr(builder, node.(*Node_Scalar_Initializer).expr);
	}
}

print_expr :: (builder: *String_Builder, node: *Node_Expr, parent_precedence := 0) {
	if !node return;
	if node.expr_type == {
	case Node_Assign;
		precedence := precedence_of(node.(*Node_Assign).op);
		if precedence <= parent_precedence {
			append(builder, "(");
		}
		left := print_expr(builder, node.(*Node_Assign).left, precedence);
		append(builder, sprint(" % ", node.(*Node_Assign).op.view));
		right := print_expr(builder, node.(*Node_Assign).right, precedence);
		if precedence <= parent_precedence {
			append(builder, ")");
		}
	case Node_Cast;
		append(builder, "(");
		print_type(builder, node.(*Node_Cast).base);
		append(builder, ")");
		append(builder, "(");
		print_expr(builder, node.(*Node_Cast).expr);
		append(builder, ")");
	case Node_Sizeof_Type;
		append(builder, "sizeof");
		append(builder, "(");
		print_type(builder, node.(*Node_Sizeof_Type).base);
		append(builder, ")");
	case Node_Sizeof_Expr;
		append(builder, "sizeof ");
		print_expr(builder, node.(*Node_Sizeof_Expr).expr);
	case Node_Compound;
		append(builder, "(");
		print_type(builder, node.(*Node_Compound).base_info);
		append(builder, ")");
		print_init(builder, node.(*Node_Compound).init);
	case Node_Binary;
		precedence := precedence_of(node.(*Node_Binary).op);
		if precedence <= parent_precedence {
			append(builder, "(");
		}
		left := print_expr(builder, node.(*Node_Binary).left, precedence);
		append(builder, sprint(" % ", node.(*Node_Binary).op.view));
		right := print_expr(builder, node.(*Node_Binary).right, precedence);
		if precedence <= parent_precedence {
			append(builder, ")");
		}
	case Node_Unary;
		if !node.(*Node_Unary).postfix {
			append(builder, sprint("%", node.(*Node_Unary).op.view));
		}
		precedence := precedence_of(node.(*Node_Unary).op);
		if precedence <= parent_precedence {
			append(builder, "(");
		}
		print_expr(builder, node.(*Node_Unary).expr);
		if node.(*Node_Unary).postfix {
			append(builder, sprint("%", node.(*Node_Unary).op.view));
		}
		if precedence <= parent_precedence {
			append(builder, ")");
		}
	case Node_Ternary;
		print_expr(builder, node.(*Node_Ternary).cond, precedence_of(.Question));
		append(builder, " ? ");
		print_expr(builder, node.(*Node_Ternary).on_true);
		append(builder, " : ");
		print_expr(builder, node.(*Node_Ternary).on_false, precedence_of(.Question));
	case Node_Number;
		if node.(*Node_Number).kind == .FLOAT {
			f := node.(*Node_Number).as_f64;
			// NOTE(Oliver): Not using remove zeroes results in some weirdness
			append(builder, tprint("%", FormatFloat.{value=f, zero_removal=.NO}));
		} else {
			append(builder, tprint("%", node.(*Node_Number).as_u64));
		}
	case Node_String;
		append(builder, sprint("\"%\"", node.(*Node_String).token.view));
	case Node_Char;
		append(builder, sprint("'%'", node.(*Node_Char).token.view));
	case Node_Identifier;
		append(builder, sprint("%", node.(*Node_Identifier).id.view));
	case Node_Call;
		print_expr(builder, node.(*Node_Call).id);
		append(builder, "(");
		for node.(*Node_Call).args {
			print_expr(builder, it);
			if it_index < node.(*Node_Call).args.count - 1 then append(builder, ", ");
		}
		append(builder, ")");
	case Node_Array_Access;
		print_expr(builder, node.(*Node_Array_Access).left);
		append(builder, "[");
		print_expr(builder, node.(*Node_Array_Access).index);
		append(builder, "]");
	case Node_Member_Access;
		print_expr(builder, node.(*Node_Member_Access).left);
		append(builder, sprint("%", node.(*Node_Member_Access).op.view));
		append(builder, sprint("%", node.(*Node_Member_Access).right.view));
	}
}

parse_param_decl :: (p: *Parser) -> *Node_Decl {
	decl := New(Node_Decl);
	parse_declaration_specifiers(p, *decl.base);
	declarator := parse_declarator(p);
	if declarator {
		array_add(*decl.declarators, declarator);
	}
	return decl;
}

parse_direct_declarator :: (p: *Parser) -> *Node_Declarator {
	declarator: *Node_Declarator;
	if current(p).type == .LeftParenthesis {
		if !is_declaration_start(p, next(p)) {
			skip(p);
			declarator = parse_declarator(p);
			expect(p, .RightParenthesis);
		}
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
					func.variadic = true;
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
			expr := parse_expr(p);
			constant := eval_constant_expr(expr);
			count := 0;
			// TODO(Oliver): If delcaring array has no count
			// then we can derive it from the number of initialzers
			// in certain cases
			if constant.kind == .S64 {
				count = constant.as_s64.(s64);
			} else if constant.kind == .U64 {
				count = constant.as_u64.(s64);
			} else {
				count = constant.as_f64.(s64);
			}
			array.count = count;
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
		if !declarator return "";
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
					index.index = parse_expr(p);
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
					label.expr = parse_expr(p);
				} else if current(p).view == "default" {
					skip(p);
					label.is_case = true;
				}
				expect(p, .Colon);
				label.statement = parse_statement(p);
				statement = label;
			} else if current(p).view == "continue" {
				statement = New(Node_Continue);
				skip(p);
				expect(p, .Semicolon);
			} else if current(p).view == "break" {
				statement = New(Node_Break);
				skip(p);
				expect(p, .Semicolon);
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
				if current(p).view != "while" {
					assert(false);
				} else {
					skip(p);
				}
				expect(p, .LeftParenthesis);
				_do.cond = parse_expr(p);
				expect(p, .RightParenthesis);
				expect(p, .Semicolon);
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
	type: Node_Decl_Info;
	parse_declaration_specifiers(p, *type);

	decl := New(Node_Decl);
	decl.base = type;
	while current(p).type != .Semicolon &&
		  current(p).type != .LeftBrace {
		declarator := parse_declarator(p);
		name := identifier_from_declarator(declarator);
		print("declarator: %\n", name);
		if name != "" {
			if name == "test" {
				a := 5;
			}
			table_add(*p.ordinary, name, decl);
		}
		if declarator {
			array_add(*decl.declarators, declarator);
			if current(p).type == .Equals {
				skip(p);
				declarator.init = parse_initializer(p);
			} else if current(p).type == .Colon {
				skip(p);
				declarator.bitfield = parse_expr(p, precedence_of(.Comma) + 1);
			}
		}

		if current(p).type != .Semicolon &&
		   current(p).type != .LeftBrace {
			expect(p, .Comma);
		}
	}

	if is_typedef(decl.base) {
		for decl.declarators {
			// This should probably always be true?
			id := identifier_from_declarator(it); 
			if id != "" {
 				//print("Adding typedef: %\n", id);
				table_add(*p.typedefs, id, decl);
			}
		}
	}

	if current(p).type == .LeftBrace {
		decl.body = parse_statement(p);
	}
	
	return decl;
}

indent :: (builder: *String_Builder, depth: int) {
	for 0..depth*4-1 append(builder, " ");
}


print_type :: (builder: *String_Builder, info: Node_Decl_Info) {
	for info.declarators {
		id := identifier_from_declarator(it);
		if id {
			if id == "__builtin_va_list" ||
				id == "__builtin_va_copy" ||
				id == "__darwin_va_list" return;
		}
	}
	append(builder, sprint("%", info.storage_class));
	if info.storage_class {
		append(builder, " ");
	}
	
	if info._struct {
		if info._struct.is_union {
			append(builder, "union ");
		} else {
			append(builder, "struct ");
		}
		append(builder, info._struct.name.view);
		if !info.reference {
			append(builder, " {\n");
			for info._struct.members {
				append(builder, "    ");
				print_decl(builder, it);
				append(builder, ";\n");
			}
			append(builder, "} ");
		} else {
			append(builder, " ");
		}
	} else if info._enum {
		append(builder, "enum ");
		append(builder, info._enum.name.view);
		if !info.reference {
			append(builder, " {\n");
			for info._enum.members {
				append(builder, "    ");
				append(builder, it.name.view);
				append(builder, " ");
				if it.expr {
					append(builder, "= ");
					print_expr(builder, it.expr);
				}

				append(builder, ",\n");
			}
			append(builder, "} ");
		} else {
			append(builder, " ");
		}
	}

	for info.qualifiers {
		append(builder, sprint("% ", it));
	}

	if info.atomic {
		append(builder, "_Atomic(");

		print_type(builder, info.atomic);

		append(builder, ") ");
	}

	for info.specifiers {
		append(builder, sprint("% ", it));
	}

	for info.declarators {
		print_declarator(builder, it);
		if it_index < info.declarators.count - 1 append(builder, ", ");
	}
}

print_declarator :: (builder: *String_Builder, declarator: *Node_Declarator, parent_was_function_or_array := false) {
	if !declarator then return;
	if declarator.declarator_type == {
	case Node_Pointer_Declarator;
		if parent_was_function_or_array {
			append(builder, "(");
		}
		append(builder, "*");
		for declarator.qualifiers {
			append(builder, sprint("% ", it));
		}
		print_declarator(builder, declarator.inner, false);
		if parent_was_function_or_array {
			append(builder, ")");
		}
	case Node_Function_Declarator;
		print_declarator(builder, declarator.inner, true);
		func := declarator.(*Node_Function_Declarator);
		append(builder, "(");
		for func.params {
			if !it break;
			print_type(builder, it.base);
			if it_index < func.params.count - 1 then append(builder, ", ");
		}
		if func.variadic {
			append(builder, ", ...");
		}
		append(builder, ")");
	case Node_Identifier_Declarator;
		print_declarator(builder, declarator.inner, false);
		append(builder, sprint("%", declarator.(*Node_Identifier_Declarator).name));
	case Node_Array_Declarator;
		print_declarator(builder, declarator.inner, true);
		if declarator.(*Node_Array_Declarator).count > 0 {
			append(builder, sprint("[%]", declarator.(*Node_Array_Declarator).count));
		} else {
			append(builder, "[]");
		}
	}
	if declarator.bitfield {
		append(builder, ": ");
		print_expr(builder, declarator.bitfield);
	}
	if declarator.init {
		append(builder, " = ");
		print_init(builder, declarator.init);
	}
}


print_decl :: (builder: *String_Builder, decl: *Node_Decl) {
	print_type(builder, decl.base);
	if decl.body {
		print_statement(builder, decl.body);
	}
}

print_statement :: (builder: *String_Builder, stmt: *Node_Statement, depth := 0) {
	if !stmt return;
	if stmt.statement_type == {
		case Node_Break;
			append(builder, "break;");
		case Node_Continue;
			append(builder, "continue;");
		case Node_Goto;
			append(builder, "goto ");
			append(builder, stmt.(*Node_Goto).to.view);
		case Node_Return;
			append(builder, "return ");
			print_expr(builder, stmt.(*Node_Return).expr);
			append(builder, ";\n");
		case Node_Block;
			append(builder, "{\n");
			for stmt.(*Node_Block).statements {
				indent(builder, depth + 1);
				print_statement(builder, it, depth + 1);
			}
			indent(builder, depth);
			append(builder, "}");
		case Node_If;
			append(builder, "if ");
			append(builder, "(");
			print_expr(builder, stmt.(*Node_If).cond);
			append(builder, ") ");
			print_statement(builder, stmt.(*Node_If).on_true, depth);
			if stmt.(*Node_If).on_false {
				append(builder, " else ");
				print_statement(builder, stmt.(*Node_If).on_false, depth);
			}
			append(builder, "\n");
		case Node_While;
			append(builder, "while ");
			append(builder, "(");
			print_expr(builder, stmt.(*Node_While).cond);
			append(builder, ")");
			print_statement(builder, stmt.(*Node_While).body, depth);
			append(builder, "\n");
		case Node_Do;
			append(builder, "do ");
			print_statement(builder, stmt.(*Node_Do).body, depth);
			append(builder, "while");
			append(builder, "(");
			print_expr(builder, stmt.(*Node_Do).cond);
			append(builder, ");");
		case Node_Switch;
			append(builder, "switch ");
			append(builder, "(");
			print_expr(builder, stmt.(*Node_Switch).expr);
			append(builder, ")");
			print_statement(builder, stmt.(*Node_Do).body, depth);
			append(builder, "\n");
		case Node_Label;
			if stmt.(*Node_Label).is_case && stmt.(*Node_Label).expr {
				append(builder, "case ");
			} else if !stmt.(*Node_Label).expr {
				append(builder, "default ");
			}
			print_expr(builder, stmt.(*Node_Label).expr);
			append(builder, ": ");
			print_statement(builder, stmt.(*Node_Label).statement, depth);
			append(builder, "\n");
		case Node_For;
			append(builder, "for ");
			append(builder, "(");
			print_decl(builder, stmt.(*Node_For).init);
			append(builder, "; ");
			print_expr(builder, stmt.(*Node_For).cond);
			append(builder, "; ");
			print_expr(builder, stmt.(*Node_For).expr);
			append(builder, ") ");
			print_statement(builder, stmt.(*Node_For).body, depth);
			append(builder, "\n");
		case Node_Decl_Statement;
			print_decl(builder, stmt.(*Node_Decl_Statement).decl);
			append(builder, ";\n");
		case Node_Expr_Statement;
			print_expr(builder, stmt.(*Node_Expr_Statement).expr);
			append(builder, ";\n");
	}
}

main :: () {
	t0 := current_time_monotonic();

	//minimal := read_entire_file("/Users/olivercruickshank/Carnage/friday.c");
	// minimal := read_entire_file("friday.c");
	minimal := read_entire_file("test.c");
	tokeniser: Tokeniser;
	tokeniser.source = minimal;
	tokenise(*tokeniser);

	cpp: Preprocessor;
	array_add(*cpp.path_stack, "/Users/olivercruickshank/Carnage/friday.c");
	add_all_builtins(*cpp);
	tokens := preprocess(*cpp, tokeniser.tokens);

	for tokens {
		if it.view == "___POSIX_C_DEPRECATED_STARTING_200112" {
			print("___POSIX_C_DEPRECATED_STARTING_200112: \n");
			object := table_find_pointer(*cpp.objects, it.view);
			if object {
				for object.tokens {
					print("% ", it);
				}
			}
		}
	}

	output: string;
	for tokens {
		output = join(output, sprint("% ", it.view));
	}
	write_entire_file("processed.c", output);

	tokens_no_newlines: [..]Token;
	total_newlines := 0;
	for tokens {
		if it.type != .Newline {
			array_add(*tokens_no_newlines, it);
		} else {
			total_newlines += 1;
		}
	}

	parser: Parser;
	parser.tokens = tokens_no_newlines;

	tu := parse_translation_unit(*parser);

	typechecker: Type_Checker;
	typechecker.ordinary = parser.ordinary;
	typecheck(*typechecker, tu);

	compiler: Compiler;
	compiler.strings = parser.strings;
	compiler.ordinary = parser.ordinary;
	compiler.structs = parser.structs;
	compiler.enums = parser.enums;
	compiler.typedefs = parser.typedefs;
	compile(*compiler, tu);

	t1 := current_time_monotonic();

	dt := t1 - t0;
	ms := 1000*to_float64_seconds(dt);

	builder: String_Builder;
	for tu.declarations {
		print_decl(*builder, it);
		if !it.body {
			append(*builder, ";");
		}
		append(*builder, "\n");
	}

	print("it took HOW long to compile % lines? %ms\n", total_newlines, ms);

	print("\nCompiling assembly...\n\n");
	run_command("clang", "out.s", "-oout");
	print("Compile same program with clang...\n");
	run_command("clang", "-S", "test.c", "-oclang_out.s");
	print("Running program...\n\n");
	run_command("./out");
}