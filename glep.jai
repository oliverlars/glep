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
	tokens: [..]Token;
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
	init: *Node_Expr;
	inner: *Node_Declarator;
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

Node_Expr :: struct {
	#as using _: Node;
	type = Node_Expr;
	expr_type: Type;
}

Node_Binary :: struct {
	#as using node: Node_Expr;
	op: Token;
	left: *Node_Expr;
	right: *Node_Expr;
	expr_type = Node_Binary;
}

Node_Unary :: struct {
	#as using node: Node_Expr;
	op: Token;
	right: *Node_Expr;
	expr_type = Node_Unary;
}

Node_Call :: struct {
	#as using node: Node_Expr;
	expr_type = Node_Call;
	id: *Node_Expr;
	params: [..]*Node_Expr;
}

Node_Access :: struct {
	#as using node: Node_Expr;
	op: Token;
	left: *Node_Expr;
	right: Token;
	expr_type = Node_Access;
}

Node_Identifier :: struct {
	#as using node: Node_Expr;
	id: Token;
	expr_type = Node_Identifier;
}

Node_Number :: struct {
	#as using node: Node_Expr;
	expr_type = Node_Number;
	value: int;
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
			case "=";
				t.at += 1; token.type = .Equals;
				if t.source[t.at] == #char "=" {
					t.at += 1;
					token.view.count += 1;
					token.type = .EqualEqual;
				}
			case ";"; t.at += 1; token.type = .Semicolon;
			case ","; t.at += 1; token.type = .Comma;
			case "("; t.at += 1; token.type = .LeftParenthesis;
			case ")"; t.at += 1; token.type = .RightParenthesis;
			case "{"; t.at += 1; token.type = .LeftBrace;
			case "}"; t.at += 1; token.type = .RightBrace;
			case "["; t.at += 1; token.type = .LeftBracket;
			case "]"; t.at += 1; token.type = .RightBracket;
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
				}
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
					while is_num(t.source[t.at]) {
						t.at += 1;
					}
					token.view.count = t.source.data + t.at - token.view.data;
				}
			}
		}

		array_add(*t.tokens, token);
	}
}

skip :: (p: *Parser, amount := 1) {
	p.at += amount;
}

expect :: (p: *Parser, type: Token_Type) {
	if p.tokens[p.at].type != type {
		print("Expected: %\n", type);
		assert(false);
	} else {
		p.at += 1;
	}
}

current :: (p: *Parser) -> Token {
	return p.tokens[p.at];
}

next :: (p: *Parser) -> Token {
	return p.tokens[p.at + 1];
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

parse_declaration_specifiers :: (p: *Parser, info: *Node_Type_Info) {
	
	is_storage_specifier :: (token: Token) -> bool {
		if token.view == {
		case "static";   #through;
		case "auto";     #through;
		case "extern";   #through;
		case "register";
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
		case "bool";
			return true;
		case;
			return false;
		}
	}

	is_function_specifier :: (token: Token) -> bool {
		return token.view == "inline";
	}

	while  is_storage_specifier(current(p)) ||
		   is_type_qualifier(current(p)) ||
		   is_type_specifier(current(p)) ||
		   is_function_specifier(current(p)) ||
		   current(p).view == "typedef" {
		if is_storage_specifier(current(p)) {
			info.storage_class = current(p).view;
		} else {
			array_add(*info.qualifiers, current(p).view);
		}
		skip(p);
	}
}

precedence_of :: (token: Token) -> int {
	if token.type == {
	case .ForwardSlash; return 15;
	case .Asterisk;     return 15;
	case .Percent;      return 15;
	case .Plus;         return 1;
	case .Minus;        return 1;
	
	case;               return 0;
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
	} else if token.type == .LeftParenthesis {
		// Type cast
	}
	
	return false;
}

is_binary_op :: (token: Token) -> bool {
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
		case .GreaterGreater;
			return true;
	}

	if token.view == "sizeof" {
		return true;
	} else if token.type == .LeftParenthesis {
		// Type cast
	}
	
	return false;
}

parse_expr :: (p: *Parser, min_prec := 0) -> *Node_Expr {
	lhs: *Node_Expr;
	if is_prefix_op(current(p)) {
		op := current(p);
		skip(p);

		rhs := parse_primary_expr(p);
		rhs = parse_postfix_expr(p, rhs);
		
		unary := New(Node_Unary);
		unary.op = op;
		unary.right = rhs;

		lhs = unary;
	} else {
		lhs = parse_primary_expr(p);
		lhs = parse_postfix_expr(p, lhs);
	}

	if !lhs return null;

	while true {
		token := current(p);
		prec := precedence_of(token);
		if prec < min_prec break;

		op := current(p);
		if !is_binary_op(op) then break;
		skip(p);

		next_min := prec + is_left_associative(token).(int);

		rhs := parse_expr(p, next_min);

		binary := New(Node_Binary);
		binary.op = op;
		binary.left = lhs;
		binary.right = rhs;
		lhs = binary;
	}

	return lhs;
}

parse_postfix_expr :: (p: *Parser, lhs: *Node_Expr) -> *Node_Expr {
	result := lhs;
	while current(p).type == .Period || current(p).type == .LeftParenthesis ||
	      current(p).type == .LeftBracket || current(p).type == .Arrow {
		if current(p).type == .Period {
			access := New(Node_Access);
			access.op = current(p);
			skip(p);
			access.left = result;
			access.right = current(p);
			result = access;
			expect(p, .Identifier);
		} else if current(p).type == .LeftBracket {

		} else if current(p).type == .LeftParenthesis {
			skip(p);
			call := New(Node_Call);
			call.id = result;
			while current(p).type != .RightParenthesis {
				array_add(*call.params, parse_expr(p));
				expect(p, .Comma);
			}
		} else if current(p).type == .Arrow {
			access := New(Node_Access);
			access.left = result;
			access.op = current(p);
			skip(p);
			access.right = current(p);
			skip(p);
			result = access;
		} else if current(p).type == .Period {

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
		value: int;
		for current(p).view {
			value = value * 10 + it - #char "0";
		}
		skip(p);
		result.(*Node_Number).value = value;
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
		right := eval_expr(node.(*Node_Unary).right);
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

print_expr :: (node: *Node_Expr) {
	if !node return;
	if node.expr_type == {
	case Node_Binary;
		left := print_expr(node.(*Node_Binary).left);
		print(" % ", node.(*Node_Binary).op.view);
		right := print_expr(node.(*Node_Binary).right);
	case Node_Unary;
		print("%", node.(*Node_Unary).op.view);
		right := print_expr(node.(*Node_Unary).right);
	case Node_Number;
		print("%", node.(*Node_Number).value);
	case Node_Identifier;
		print("%", node.(*Node_Identifier).id.view);
	case Node_Call;
		print_expr(node.(*Node_Access).left);
	case Node_Access;
		print_expr(node.(*Node_Access).left);
		print("%", node.(*Node_Access).op.view);
		print("%", node.(*Node_Access).right.view);
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

parse_decl :: (p: *Parser) -> *Node_Decl {
	type: Node_Type_Info;
	parse_declaration_specifiers(p, *type);

	decl := New(Node_Decl);
	decl.base_info = type;
	while current(p).type != .Semicolon {
		declarator := parse_declarator(p);
		array_add(*decl.declarators, declarator);
		if current(p).type == .Equals {
			skip(p);
			declarator.init = parse_expr(p);
		}
		if current(p).type != .Semicolon {
			expect(p, .Comma);
		}
	}
	expect(p, .Semicolon);

	print_type :: (info: Node_Type_Info) {
		
		print("% ", info.storage_class);
		
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
			print_expr(declarator.init);
		}
	}

	print_type(decl.base_info);
	for decl.declarators {
		print_declarator(it);
		if it_index < decl.declarators.count - 1 then print(", ");
	}
	print(";");
	
	print("\n");
	
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

	void f(void a);
	int g(int a, double b);
	double h(int, int);
	static inline int max(int a, int b);
	extern void log_message(const char *msg);
	int (*ret_array(void))[1 + (2 + 3)];
	int qsort(void *a, void *b, int (*cmp)(void*, void*));

	int fdef(int x);
	static void helper(void);

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
	int     get_op(char op);
	void    set_callback(void_cb cb);
	void    register_many(int n, void_cb callbacks[0]);
	int     choose_transform(int kind);

	int *f1(int);
	int (*f2)(int);
	int (*f3[5])(double);

	int test[(1 + 2) * 3 - -1];

	int *a1[5];
	int (*a2)[5];
	int (*(*a3)[5])(void);

	int (*const (*volatile (*f[5])(double))[5])(char);

	int a = 10 + 1 + -x.y + a->b;
	
	STRING

	tokeniser: Tokeniser;
	tokeniser.source = input;
	tokenise(*tokeniser);

	parser: Parser;
	parser.tokens = tokeniser.tokens;
	

	while parser.at < parser.tokens.count {
		parse_decl(*parser);
	}
}