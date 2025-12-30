/*
 * Macro Expansion Deep Tests
 * Focus on expansion order, rescanning, and edge cases
 */

#include <stdio.h>

/* ============================================================================
 * TEST 1: BASIC EXPANSION ORDER
 * ============================================================================ */

// 1.1 Simple chain
#define A1 100
#define B1 A1
#define C1 B1
int chain1 = C1;  // Expected: 100

// 1.2 Expansion before substitution (argument prescan)
#define DOUBLE(x) ((x) + (x))
#define FIVE 5
int prescan1 = DOUBLE(FIVE);  // FIVE expanded to 5 before substitution: (5) + (5)

// 1.3 But NOT if stringified
#define STRINGIFY(x) #x
const char* no_prescan1 = STRINGIFY(FIVE);  // "FIVE" not "5"

// 1.4 Indirection to get expansion before stringify
#define XSTRINGIFY(x) STRINGIFY(x)
const char* yes_prescan1 = XSTRINGIFY(FIVE);  // "5"


/* ============================================================================
 * TEST 2: SELF-REFERENCE (BLUE PAINT)
 * ============================================================================ */

// 2.1 Direct self-reference
#define SELF SELF
int self1 = SELF;  // Just SELF, no expansion

// 2.2 Indirect self-reference
#define IND_A IND_B
#define IND_B IND_A
int indirect1 = IND_A;  // IND_A -> IND_B -> IND_A (painted, stops)

// 2.3 Self-reference with more content
#define SELF_PLUS SELF_PLUS + 1
int self_plus = SELF_PLUS;  // SELF_PLUS + 1

// 2.4 Self in argument
#define CALL(x) x
#define SELF_CALL CALL(SELF_CALL)
int self_call = SELF_CALL;  // CALL(SELF_CALL) -> SELF_CALL (painted)


/* ============================================================================
 * TEST 3: TOKEN PASTING
 * ============================================================================ */

// 3.1 Basic paste
#define PASTE(a, b) a ## b
int PASTE(var, 1) = 1;  // var1

// 3.2 Paste creating macro name
#define XY 42
int paste_macro = PASTE(X, Y);  // XY -> 42

// 3.3 Paste doesn't prescan
#define PA X
#define PB Y
int paste_no_prescan = PASTE(PA, PB);  // PAPB (no expansion of PA, PB before paste)

// 3.4 Indirect paste for expansion
#define XPASTE(a, b) PASTE(a, b)
int paste_with_prescan = XPASTE(PA, PB);  // X, Y -> XY -> 42

// 3.5 Multiple paste
#define PASTE3(a, b, c) a ## b ## c
int PASTE3(a, b, c) = 1;  // abc

// 3.6 Paste number
#define NUM(a, b) a ## b
int big_num = NUM(12, 34);  // 1234

// 3.7 Paste creating operator (probably invalid)
// #define OP(a, b) a ## b
// int x = 1 OP(+, +) 2;  // Would create ++, but risky


/* ============================================================================
 * TEST 4: STRINGIFICATION
 * ============================================================================ */

// 4.1 Basic stringify
#define STR(x) #x
const char* str1 = STR(hello);  // "hello"

// 4.2 Stringify preserves tokens
const char* str2 = STR(a + b * c);  // "a + b * c"

// 4.3 Stringify normalizes whitespace
const char* str3 = STR(  a    b  );  // "a b"

// 4.4 Stringify escapes quotes
const char* str4 = STR(say "hi");  // "say \"hi\""

// 4.5 Stringify escapes backslash
const char* str5 = STR(a\b);  // "a\\b"

// 4.6 Stringify empty
#define STR_EMPTY(x) #x
const char* str6 = STR_EMPTY();  // ""

// 4.7 Stringify multiple args (paste first)
#define STR_PASTE(a, b) #a #b
const char* str7 = STR_PASTE(hello, world);  // "hello" "world" (adjacent strings)


/* ============================================================================
 * TEST 5: VARIADIC MACROS
 * ============================================================================ */

// 5.1 Basic variadic
#define VAR1(fmt, ...) printf(fmt, __VA_ARGS__)
void use_var1(void) { VAR1("%d %d", 1, 2); }

// 5.2 Variadic stringify
#define VAR_STR(...) #__VA_ARGS__
const char* var_str = VAR_STR(a, b, c);  // "a, b, c"

// 5.3 GNU comma elision
#define VAR_GNU(fmt, ...) printf(fmt, ##__VA_ARGS__)
void use_var_gnu(void) { 
    VAR_GNU("no args");
    VAR_GNU("%d", 1);
}

// 5.4 __VA_OPT__ (C23)
#ifdef __VA_OPT__
#define VAR_OPT(fmt, ...) printf(fmt __VA_OPT__(,) __VA_ARGS__)
#endif

// 5.5 Variadic with regular args
#define VAR_MIXED(a, b, ...) a + b + __VA_ARGS__

// 5.6 Counting arguments
#define NARGS_IMPL(_1, _2, _3, _4, _5, N, ...) N
#define NARGS(...) NARGS_IMPL(__VA_ARGS__, 5, 4, 3, 2, 1, 0)
int nargs = NARGS(a, b, c);  // 3


/* ============================================================================
 * TEST 6: FUNCTION-LIKE WITHOUT PARENS
 * ============================================================================ */

// 6.1 Not a call without parens
#define FUNC(x) ((x) * 2)
int not_call = FUNC;  // Just the identifier FUNC, not expanded

// 6.2 Pointer to function (common pattern)
typedef int (*func_ptr)(int);
// func_ptr fp = FUNC;  // FUNC stays as identifier


/* ============================================================================
 * TEST 7: ARGUMENT EDGE CASES
 * ============================================================================ */

// 7.1 Empty argument
#define WRAP(x) [x]
// WRAP() gives []

// 7.2 Argument with parentheses
#define PASS(x) x
int paren_arg = PASS((1, 2, 3));  // The comma expr (1,2,3) = 3

// 7.3 Argument with nested parens
int nested_paren = PASS(((1)));  // ((1))

// 7.4 Macro call as argument
int macro_arg = DOUBLE(FIVE);  // FIVE->5, then ((5)+(5))

// 7.5 Argument used multiple times
#define TIMES3(x) ((x) + (x) + (x))
int times3 = TIMES3(FIVE);  // Each x becomes 5

// 7.6 Unused argument
#define IGNORE(x, y) x
int ignored = IGNORE(1, 2);  // 1


/* ============================================================================
 * TEST 8: RESCAN AFTER SUBSTITUTION
 * ============================================================================ */

// 8.1 Paste creates macro, rescan expands it
#define RESCAN_A 100
#define RESCAN_B 200
#define MAKE_NAME(x) RESCAN_ ## x
int rescan1 = MAKE_NAME(A);  // RESCAN_A -> 100

// 8.2 Substitution creates macro call
#define LATER_CALL DOUBLE
#define GET_CALL() LATER_CALL
int rescan2 = GET_CALL()(5);  // LATER_CALL(5) -> DOUBLE(5) -> ((5)+(5))

// 8.3 Complex rescan
#define APPLY(f, x) f(x)
#define INC(x) ((x) + 1)
int rescan3 = APPLY(INC, 5);  // INC(5) -> ((5) + 1)


/* ============================================================================
 * TEST 9: EXPANSION IN MACRO BODIES
 * ============================================================================ */

// 9.1 Macro in body expands when parent is expanded
#define BASE 10
#define DERIVED (BASE + 5)
int derived = DERIVED;  // (10 + 5)

// 9.2 Nested macro call in body
#define OUTER_CALL(x) DOUBLE(x)
int outer = OUTER_CALL(3);  // DOUBLE(3) -> ((3)+(3))

// 9.3 Multiple levels
#define L1(x) L2(x)
#define L2(x) L3(x)
#define L3(x) ((x) * 2)
int levels = L1(5);  // ((5) * 2)


/* ============================================================================
 * TEST 10: TRICKY COMBOS
 * ============================================================================ */

// 10.1 Paste then stringify (via indirection)
#define PASTE_THEN_STR(a, b) XSTRINGIFY(PASTE(a, b))
const char* paste_str = PASTE_THEN_STR(hel, lo);  // "hello"

// 10.2 Stringify then paste (doesn't work directly)
// #define STR_THEN_PASTE(a, b) #a ## #b  // Probably an error

// 10.3 Variadic in nested call
#define OUTER_VAR(...) inner(__VA_ARGS__)
void use_outer_var(void) { OUTER_VAR(1, 2, 3); }

// 10.4 Self-reference in argument position
#define TROUBLE TROUBLE
#define USE_IT(x) x + 1
int trouble = USE_IT(TROUBLE);  // TROUBLE + 1 (TROUBLE painted)

// 10.5 Recursive-looking through multiple macros
#define R1 R2
#define R2 R3
#define R3 R1
int recursive_look = R1;  // R1 -> R2 -> R3 -> R1 (painted, stops)


/* ============================================================================
 * TEST 11: WHITESPACE AND TOKEN BOUNDARIES
 * ============================================================================ */

// 11.1 Whitespace in args
int ws1 = DOUBLE(   5   );  // 5

// 11.2 Newlines in args (with continuation or just multiline call)
int ws2 = DOUBLE(
    5
);

// 11.3 Adjacent string literals (not paste, compiler feature)
const char* adj = "hello" " " "world";

// 11.4 Token separation
#define TOKSEP a + b
int toksep = TOKSEP;  // a + b as separate tokens


/* ============================================================================
 * TEST 12: COMMON PATTERNS
 * ============================================================================ */

// 12.1 MIN/MAX
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

// 12.2 ARRAY_SIZE
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

// 12.3 CONCAT with expansion
#define CONCAT_(a, b) a ## b
#define CONCAT(a, b) CONCAT_(a, b)

// 12.4 Unique name generation
#define UNIQUE_NAME(base) CONCAT(base, __LINE__)

// 12.5 STATIC_ASSERT (pre-C11)
#define STATIC_ASSERT(cond) typedef char UNIQUE_NAME(static_assert_)[(cond) ? 1 : -1]

// 12.6 X-Macros
#define COLORS \
    X(RED,   0xFF0000) \
    X(GREEN, 0x00FF00) \
    X(BLUE,  0x0000FF)

#define X(name, val) name = val,
enum { COLORS };
#undef X

#define X(name, val) #name,
const char* color_names[] = { COLORS };
#undef X

// 12.7 Defer for extra expansion
#define EMPTY_()
#define DEFER(id) id EMPTY_()
// Useful for complex macro metaprogramming


/* ============================================================================
 * TEST 13: ERROR CASES (commented out)
 * ============================================================================ */

/*
// 13.1 Wrong arg count
DOUBLE(1, 2)  // Error
DOUBLE()      // Error (or empty arg?)

// 13.2 Unterminated call
DOUBLE(1

// 13.3 # not followed by arg
#define BAD1(x) # y

// 13.4 ## at edge
#define BAD2 ## x
#define BAD3 x ##

// 13.5 Paste creating invalid token
#define BAD4(a) a ## "hi"
*/


/* ============================================================================
 * VERIFICATION SECTION
 * ============================================================================ */

void verify_results(void) {
    // Chain expansion
    if (chain1 != 100) printf("FAIL: chain1\n");
    
    // Prescan
    if (prescan1 != 10) printf("FAIL: prescan1\n");
    
    // Stringify
    if (no_prescan1[0] != 'F') printf("FAIL: no_prescan1\n");
    if (yes_prescan1[0] != '5') printf("FAIL: yes_prescan1\n");
    
    // Paste creating macro
    if (paste_macro != 42) printf("FAIL: paste_macro\n");
    if (paste_with_prescan != 42) printf("FAIL: paste_with_prescan\n");
    
    // Rescan
    if (rescan1 != 100) printf("FAIL: rescan1\n");
    
    // Derived
    if (derived != 15) printf("FAIL: derived\n");
}

int main(void) {
    verify_results();
    printf("Macro expansion tests complete.\n");
    return 0;
}
