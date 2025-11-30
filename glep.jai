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
				case #char "="; t.at += 1; token.type = .Equals;
				case #char ";"; t.at += 1; token.type = .Semicolon;
				case #char ","; t.at += 1; token.type = .Comma;
				case #char "("; t.at += 1; token.type = .LeftParenthesis;
				case #char ")"; t.at += 1; token.type = .RightParenthesis;
				case #char "{"; t.at += 1; token.type = .LeftBrace;
				case #char "}"; t.at += 1; token.type = .RightBrace;
				case #char "["; t.at += 1; token.type = .LeftBracket;
				case #char "]"; t.at += 1; token.type = .RightBracket;
				case #char "*"; t.at += 1; token.type = .Asterisk;
				case #char "."; {
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

parse_declaration_specifiers :: (p: *Parser) {
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
		advance(p);
	}
}

parse_pointer :: (p: *Parser) {
	count := (0).(int);
	while true {
		if !is_type_qualifier(look_ahead(p, 0)) && look_ahead(p, 0).type != .Asterisk then break;
		count += (look_ahead(p, 0).type == .Asterisk).(int);
		advance(p);
	}
	print("declarator has % pointers\n", count);
}

parse_direct_declarator :: (p: *Parser) {
	if look_ahead(p, 0).type == .LeftParenthesis {
		print("parsing function pointer\n");
	} else if look_ahead(p, 0).type == .Identifier {
		advance(p);
		if look_ahead(p, 0).type == .LeftParenthesis {
			print("parsing function decl\n");
			advance(p);
			while true {
				parse_decl(p);
				if look_ahead(p, 0).type == .RightParenthesis then break;
				assert(look_ahead(p, 0).type == .Comma);
				advance(p);
			}
		} else if look_ahead(p, 0).type == .LeftBracket {
			print("parsing array declarator\n");
			advance(p);
			whiel true {
				parse_d
			}
		}
	}
}

parse_declarator :: (p: *Parser) {
	parse_pointer(p);
	parse_direct_declarator(p);
}

parse_decl :: (p: *Parser) {
	parse_declaration_specifiers(p);
	// Once we've parsed the declaration specifiers we now need to determine what we are parsing
	// next. A '(' implies we are parsing a function pointer, an identifier followed by '(' would be a function
	// and just an identifier would mean a normal declaration.

	while true {
		parse_declarator(p);
		if look_ahead(p, 0).type == .Semicolon then break;
		assert(look_ahead(p, 0).type == .Comma);
		advance(p);
	}

}
main :: ()
{
	input := #string STRING
	int x;
	int y = 5;
	const int cz = 10;
	int const cx = 3;
	static int sx;
	extern int ex;
	volatile int vx;
	int *p;
	int **pp;
	int * const cp = 0;
	const int *q;
	int * volatile vp;

	void f(void);
	int g(int a, double b);
	double h(int, int);
	static inline int max(int a, int b);
	extern void log_message(const char *msg);

	int fdef(int x) { }
	static void helper(void) {}

	int printf(const char *fmt, ...);
	void logf(int level, const char *fmt, ...);
	double average(int count, ...);

	int *ret_int_ptr(void);
	double *ret_vec(int n);
	int (*ret_array(void))[10];
	int (*ret_func(void))(int);

	int   add(int a, int b);
	void  notify(int code);
	int  (*pf_add)(int, int);
	void (*pf_notify)(int);

	void takes_fp1(int (*cb)(int));
	void takes_fp2(int cb(int));

	static int (*pf_static)(int, int);
	int (* const pf_const)(int);
	int (* volatile pf_volatile)(void);

	void (*handlers[3])(int);
	int  (*ops[4])(int, int);
	int  (*(*table)[5])(void);

	void apply_unary(int *arr, int n, int (*f)(int));
	void for_each(void **items, int count, void (*fn)(void *));
	void register_handlers(int n, void (*handlers[])(int));
	void run_all(int count, int (*ops[])(int, int));

	int (*choose_op(char op))(int, int);
	void (*signal(int sig, void (*handler)(int)))(int);

	typedef int (*binary_op)(int, int);
	typedef void (*void_cb)(void);
	typedef double (*unary_double)(double);
	binary_op   get_op(char op);
	void        set_callback(void_cb cb);
	void        register_many(int n, void_cb callbacks[]);
	unary_double choose_transform(int kind);

	int *f1(int);
	int (*f2)(int);
	int (*f3[5])(double);

	int *a1[5];
	int (*a2)[5];
	int (*(*a3)[5])(void);
	
	STRING

	basic_decl :: "extern int *a, * const *b;";

	tokeniser: Tokeniser;
	tokeniser.source = basic_decl;
	tokenise(*tokeniser);

	for tokeniser.tokens {
		print("TOKEN: %\n", it);
	}

	parser: Parser;
	parser.t = *tokeniser;
	
	parse_decl(*parser);

	print("abc");
}