#import "Basic";
#import "File";

Token_Type :: enum {
	Invalid;
	Asterisk;
	Comma;
	Semicolon;
	Number;
	Identifier;
	Equals;
	LeftParenthesis;
	RightParenthesis;
	LeftBrace;
	RightBrace;
	LeftBracket;
	RightBracket;
	Ellipses;
	Period;
}

Token :: struct {
	view: string;
	type: Token_Type;
}

Tokeniser :: struct {
	at: int;
	source: string;
	tokens: [..]Token;
}

Parser :: struct {
	t: *Tokeniser;
	at: int;
}

Node :: struct {
	type: Type;
}

Node_Type_Info :: struct {
	qualifiers: [..]string;
	specifiers: [..]string;
	storage_class: string;
}

Node_Declarator :: struct {
	#as using node: Node;
	qualifiers: [..]string;
	declarator_type: Type;
	init: *Node;
}

Node_Function_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = Node_Function_Declarator;
	params: [..]*Node_Decl;
}

Node_Array_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = Node_Array_Declarator;
	count: int;
}

Node_Pointer_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = Node_Pointer_Declarator;
}

Node_Identifier_Declarator :: struct {
	#as using declarator: Node_Declarator;
	declarator_type = Node_Identifier_Declarator;
	name: string;
}

Node_Decl :: struct {
	#as using node: Node;
	type = Node_Decl;
	declarators: [..]*Node_Declarator;
	base_info: Node_Type_Info;
}

Node_Function_Decl :: struct {
	#as using node: Node;
	type = Node_Function_Decl;
	name: string;
	params: [..]*Node_Decl;
	ret_type: Node_Type_Info;
}

tokenise :: (t: *Tokeniser) {
	is_ws    :: (c: int) -> bool { return c == #char " " || c == #char "\n" || c == #char "\r" || c == #char "\t"; }
	is_ident :: (c: int) -> bool { return ((c >= #char "a") && (c <= #char "z")) || ((c >= #char "A") && (c <= #char "Z")); }
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
				case "="; t.at += 1; token.type = .Equals;
				case ";"; t.at += 1; token.type = .Semicolon;
				case ","; t.at += 1; token.type = .Comma;
				case "("; t.at += 1; token.type = .LeftParenthesis;
				case ")"; t.at += 1; token.type = .RightParenthesis;
				case "{"; t.at += 1; token.type = .LeftBrace;
				case "}"; t.at += 1; token.type = .RightBrace;
				case "["; t.at += 1; token.type = .LeftBracket;
				case "]"; t.at += 1; token.type = .RightBracket;
				case "*"; t.at += 1; token.type = .Asterisk;
				case "."; {
					t.at += 1;
					token.type == .Period;
					if t.at + 2 < t.source.count {
						if t.source.data[t.at + 1] == #char "." &&
						   t.source.data[t.at + 2] == #char "." {
							token.type == .Ellipses;
							t.at += 2;
						}
					}
				}
				case; {
					if is_ident(t.source[t.at]) {
						token.type = .Identifier;
						while is_ident(t.source[t.at]) || t.source[t.at] == #char "_" {
							t.at += 1;
						}
						token.view.count = t.source.data + t.at - token.view.data;
					} else if is_num(t.source[t.at]) {
						token.type = .Number;
						while is_num(t.source[t.at]) {
							t.at += 1;
						}
						token.view.count = t.source.data + t.at - token.view.data;
					}
				}
			}
		}

		array_add(*t.tokens, token);
	}
}

advance :: (p: *Parser, amount := 1) {
	p.at += amount;
}

look_ahead :: (p: *Parser, count: int) -> Token {
	return p.t.tokens[p.at + count];
}

is_type_qualifier :: (token: Token) -> bool {
	return token.view == "const" || token.view == "volatile" || token.view == "restrict";
}

parse_declaration_specifiers :: (p: *Parser, info: *Node_Type_Info) {
	is_storage_specifier :: (token: Token) -> bool {
		return token.view == "static" || token.view == "auto" || token.view == "extern" || token.view == "register";
	}
	is_type_specifier :: (token: Token) -> bool {
		return token.view == "void" || token.view == "char" || token.view == "short" || token.view == "int" || 
			   token.view == "long" || token.view == "float" || token.view == "double" || token.view == "signed" ||
			   token.view == "unsigned" || token.view == "bool";
	}
	is_function_specifier :: (token: Token) -> bool {
		return token.view == "inline";
	}

	while  is_storage_specifier(look_ahead(p, 0)) ||
		   is_type_qualifier(look_ahead(p, 0)) ||
		   is_type_specifier(look_ahead(p, 0)) ||
		   is_function_specifier(look_ahead(p, 0)) ||
		   look_ahead(p, 0).view == "typedef" {
		if is_type_qualifier(look_ahead(p, 0)) {
			array_add(*info.qualifiers, look_ahead(p, 0).view);
		} else if is_storage_specifier(look_ahead(p, 0)) {
			info.storage_class = look_ahead(p, 0).view;
		} else {
			array_add(*info.qualifiers, look_ahead(p, 0).view);
		}
		advance(p);
	}
}

// Temporarily return integer
parse_assignment_expr :: (p: *Parser) -> int {
	// This needs to be done properly, currently it only does a single number...
	result: int;
	if look_ahead(p, 0).type == .Number {
		for look_ahead(p, 0).view {
			result = result * 10 + it - #char "0";
		}
		advance(p);
	}
	return result;
}

parse_param_decl :: (p: *Parser) -> *Node_Decl {
	decl := New(Node_Decl);
	parse_declaration_specifiers(p, *decl.base_info);
	parse_declarator(p, decl);
	return decl;
}

parse_direct_declarator :: (p: *Parser, decl: *Node_Decl) {
	is_function_pointer: bool;
	if look_ahead(p, 0).type == .LeftParenthesis {
		advance(p); // LeftParenthesis
		parse_declarator(p, decl);
		advance(p); // RightParenthesis
		is_function_pointer = true;
	} else if look_ahead(p, 0).type == .Identifier {
		declarator := New(Node_Identifier_Declarator);
		declarator.name = look_ahead(p, 0).view;
		array_add(*decl.declarators, declarator);
		advance(p);
	}

	while true {
		if look_ahead(p, 0).type == .LeftParenthesis {
			advance(p);
			declarator := New(Node_Function_Declarator);
			while look_ahead(p, 0).type != .RightParenthesis {
				if look_ahead(p, 0).type == .Ellipses {
					advance(p);
				} else {
					array_add(*declarator.params, parse_param_decl(p));
				}
				if look_ahead(p, 0).type == .Comma then advance(p);
			}
			advance(p);
			array_add(*decl.declarators, declarator);
		} else if look_ahead(p, 0).type == .LeftBracket {
			declarator := New(Node_Array_Declarator);
			advance(p); // LeftBracket
			if look_ahead(p, 0).view == "static" then advance(p);
			if is_type_qualifier(look_ahead(p, 0)) {
				advance(p);
			}
			if look_ahead(p, 0).type == .Asterisk then advance(p);
			
			declarator.count = parse_assignment_expr(p);
			array_add(*decl.declarators, declarator);
			advance(p); // RightBracket
		} else {
			break;
		}
	}
}

parse_declarator :: (p: *Parser, decl: *Node_Decl) {
	while is_type_qualifier(look_ahead(p, 0)) || look_ahead(p, 0).type == .Asterisk {
		pointer := New(Node_Pointer_Declarator);
		while is_type_qualifier(look_ahead(p, 0)) {
			array_add(*pointer.qualifiers, look_ahead(p, 0).view);
			advance(p);
		}
		array_add(*decl.declarators, pointer);
		advance(p); // '*'
	}
	parse_direct_declarator(p, decl);
}

parse_decl :: (p: *Parser) -> *Node_Decl {


	type: Node_Type_Info;
	parse_declaration_specifiers(p, *type);
	// Once we've parsed the declaration specifiers we now need to determine what we are parsing
	// next. A '(' implies we are parsing a function pointer, an identifier followed by '(' would be a function
	// and just an identifier would mean a normal declaration.

	decl := New(Node_Decl);
	decl.base_info = type;
	parse_declarator(p, decl);
	if look_ahead(p, 0).type == .Semicolon {
		advance(p);
	} else {
		assert(look_ahead(p, 0).type == .Comma);
		advance(p);
	}

	print_decl :: (decl: *Node_Decl) {
		print("% ", decl.base_info);
		for decl.declarators {
			if it.declarator_type == {
			case Node_Pointer_Declarator;
				print("*");
			case Node_Function_Declarator;
				func := it.(*Node_Function_Declarator);
				print("(");
				for func.params {
					print_decl(it);
					print(", ");
				}
				print(")");
			case Node_Identifier_Declarator;
				print("% ", it.(*Node_Identifier_Declarator).name);
			case Node_Array_Declarator;
				print("[%]", it.(*Node_Array_Declarator).count);
			}
		}
	}

	print_decl(decl); print("\n");
	
	return decl;
}

main :: () {
	input := #string STRING
	int x, z;
	int y;
	const int cz;
	int const cx;
	static int sx;
	extern int ex;
	volatile int vx;
	int *p;
	int **pp;
	int * const cp;
	const int *q;
	int * volatile vp;

	void f(void);
	int g(int a, double b);
	double h(int, int);
	static inline int max(int a, int b);
	extern void log_message(const char *msg);
	int (*ret_array(void))[10];
	int qsort(void *a, void *b, int (*cmp)(void*, void*));
	STRING
	// int fdef(int x);
	// static void helper(void);

	// int printf(const char *fmt, ...);
	// void logf(int level, const char *fmt, ...);
	// double average(int count, ...);

	// int *ret_int_ptr(void);
	// double *ret_vec(int n);
	// int (*ret_array(void))[10];
	// int (*ret_func(void))(int);
	// int   add(int a, int b);
	// void  notify(int code);
	// int  (*pf_add)(int, int);
	// void (*pf_notify)(int);

	// void takes_fp1(int (*cb)(int));
	// void takes_fp2(int cb(int));

	// static int (*pf_static)(int, int);
	// int (* const pf_const)(int);
	// int (* volatile pf_volatile)(void);

	// void (*handlers[3])(int);
	// int  (*ops[4])(int, int);
	// int  (*(*table)[5])(void);

	// void apply_unary(int *arr, int n, int (*f)(int));
	// void for_each(void **items, int count, void (*fn)(void *));
	// void register_handlers(int n, void (*handlers[])(int));
	// void run_all(int count, int (*ops[])(int, int));

	// int (*choose_op(char op))(int, int);
	// void (*signal(int sig, void (*handler)(int)))(int);

	// typedef int (*binary_op)(int, int);
	// typedef void (*void_cb)(void);
	// typedef double (*unary_double)(double);
	// binary_op   get_op(char op);
	// void        set_callback(void_cb cb);
	// void        register_many(int n, void_cb callbacks[]);
	// unary_double choose_transform(int kind);

	// int *f1(int);
	// int (*f2)(int);
	// int (*f3[5])(double);

	// int *a1[5];
	// int (*a2)[5];
	// int (*(*a3)[5])(void);
	
	// STRING

	basic_decl :: "extern int (*c)(int a, int b), *a, * const *b[static 10];";

	tokeniser: Tokeniser;
	tokeniser.source = input;
	tokenise(*tokeniser);

	parser: Parser;
	parser.t = *tokeniser;
	

	while parser.at < parser.t.tokens.count {
		parse_decl(*parser);
	}


	print("abc");
}