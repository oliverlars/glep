/*
 * Minimal Preprocessor Unit Tests
 * 
 * Each test is self-contained. If your preprocessor works correctly,
 * this should compile with no errors.
 */

/* ========== TEST 01: Simple object macro ========== */
#define T01_VAL 42
#if T01_VAL != 42
#error "TEST 01 FAILED: Simple object macro"
#endif

/* ========== TEST 02: Macro chain ========== */
#define T02_A 1
#define T02_B T02_A
#define T02_C T02_B
#if T02_C != 1
#error "TEST 02 FAILED: Macro chain"
#endif

/* ========== TEST 03: Self-reference stops ========== */
#define T03_SELF T03_SELF
/* If this compiles, self-reference handling works */
int t03_var = T03_SELF; /* Should just be T03_SELF */

/* ========== TEST 04: Function macro basic ========== */
#define T04_ADD(a, b) ((a) + (b))
#if T04_ADD(2, 3) != 5
#error "TEST 04 FAILED: Function macro basic"
#endif

/* ========== TEST 05: Nested function macros ========== */
#define T05_DOUBLE(x) ((x) * 2)
#define T05_QUAD(x) T05_DOUBLE(T05_DOUBLE(x))
#if T05_QUAD(3) != 12
#error "TEST 05 FAILED: Nested function macros"
#endif
/* ========== TEST 13: #if with arithmetic ========== */
#if 2 + 3 * 4 != 14
#error "TEST 13 FAILED: Arithmetic precedence"
#endif

/* ========== TEST 14: #if with parens ========== */
#if (2 + 3) * 4 != 20
#error "TEST 14 FAILED: Parentheses"
#endif

/* ========== TEST 15: #if with comparison ========== */
#if !(1 < 2 && 2 > 1 && 1 <= 1 && 2 >= 2 && 1 == 1 && 1 != 2)
#error "TEST 15 FAILED: Comparisons"
#endif

/* ========== TEST 16: #if with logical ops ========== */
#if !(1 && 1) || (0 && 1) || !(0 || 1) || !(!0)
#error "TEST 16 FAILED: Logical operators"
#endif

/* ========== TEST 17: #if with bitwise ops ========== */
#if (0xFF & 0x0F) != 0x0F || (0xF0 | 0x0F) != 0xFF || (0xFF ^ 0x0F) != 0xF0
#error "TEST 17 FAILED: Bitwise operators"
#endif

/* ========== TEST 18: #if with shifts ========== */
#if (1 << 4) != 16 || (16 >> 2) != 4
#error "TEST 18 FAILED: Shift operators"
#endif

/* ========== TEST 19: #if with ternary ========== */
#if (1 ? 100 : 200) != 100 || (0 ? 100 : 200) != 200
#error "TEST 19 FAILED: Ternary operator"
#endif

/* ========== TEST 20: #if with unary ========== */
#if -(-5) != 5 || +5 != 5 || !0 != 1 || !!1 != 1
#error "TEST 20 FAILED: Unary operators"
#endif

/* ========== TEST 21: defined() operator ========== */
#define T21_EXISTS 1
#if !defined(T21_EXISTS)
#error "TEST 21 FAILED: defined() true case"
#endif
#if defined(T21_NOT_EXISTS)
#error "TEST 21 FAILED: defined() false case"
#endif

/* ========== TEST 22: defined without parens ========== */
#define T22_EXISTS 1
#if !defined T22_EXISTS
#error "TEST 22 FAILED: defined without parens"
#endif

/* ========== TEST 23: Undefined macro is 0 ========== */
#if T23_UNDEFINED != 0
#error "TEST 23 FAILED: Undefined macro should be 0"
#endif

/* ========== TEST 24: #ifdef ========== */
#define T24_DEF 1
#ifdef T24_DEF
#define T24_OK 1
#endif
#ifndef T24_OK
#error "TEST 24 FAILED: #ifdef"
#endif

/* ========== TEST 25: #ifndef ========== */
#ifndef T25_NOT_DEF
#define T25_OK 1
#endif
#ifndef T25_OK
#error "TEST 25 FAILED: #ifndef"
#endif

/* ========== TEST 26: #else ========== */
#if 0
#define T26_WRONG 1
#else
#define T26_OK 1
#endif
#ifndef T26_OK
#error "TEST 26 FAILED: #else"
#endif
#ifdef T26_WRONG
#error "TEST 26 FAILED: #else (wrong branch taken)"
#endif

/* ========== TEST 27: #elif ========== */
#if 0
#define T27_A 1
#elif 0
#define T27_B 1
#elif 1
#define T27_C 1
#else
#define T27_D 1
#endif
#ifndef T27_C
#error "TEST 27 FAILED: #elif"
#endif

/* ========== TEST 28: Nested conditionals ========== */
#if 1
#if 1
#define T28_INNER 1
#endif
#endif
#ifndef T28_INNER
#error "TEST 28 FAILED: Nested conditionals"
#endif

/* ========== TEST 29: Nested in false branch ========== */
#if 0
#if 1
#define T29_BAD 1
#endif
#endif
#ifdef T29_BAD
#error "TEST 29 FAILED: Nested in false branch"
#endif

/* ========== TEST 30: Balanced skipping ========== */
#if 0
#if 1
#if 1
nested content
#endif
#else
more content
#endif
#endif
#define T30_OK 1

/* ========== TEST 31: Character literals ========== */
#if 'A' != 65 || 'a' != 97 || '0' != 48
#error "TEST 31 FAILED: Character literals"
#endif

/* ========== TEST 32: Escape sequences ========== */
#if '\n' != 10 || '\t' != 9 || '\r' != 13 || '\\' != 92 || '\'' != 39
#error "TEST 32 FAILED: Escape sequences"
#endif

/* ========== TEST 33: Hex and octal in chars ========== */
#if '\x41' != 65 || '\101' != 65
#error "TEST 33 FAILED: Hex/octal in char literals"
#endif

/* ========== TEST 34: Hex numbers ========== */
#if 0xFF != 255 || 0x10 != 16 || 0xDEAD != 57005
#error "TEST 34 FAILED: Hex numbers"
#endif

/* ========== TEST 35: Octal numbers ========== */
#if 010 != 8 || 0777 != 511
#error "TEST 35 FAILED: Octal numbers"
#endif

/* ========== TEST 36: Macro in condition ========== */
#define T36_VAL 50
#if T36_VAL < 100 && T36_VAL > 25
#define T36_OK 1
#endif
#ifndef T36_OK
#error "TEST 36 FAILED: Macro in condition"
#endif

/* ========== TEST 37: Complex expression ========== */
#define T37_A 10
#define T37_B 20
#if (T37_A + T37_B) * 2 == 60
#define T37_OK 1
#endif
#ifndef T37_OK
#error "TEST 37 FAILED: Complex expression with macros"
#endif

/* ========== TEST 38: #undef ========== */
#define T38_VAL 1
#undef T38_VAL
#ifdef T38_VAL
#error "TEST 38 FAILED: #undef"
#endif

/* ========== TEST 39: Redefine after undef ========== */
#define T39_VAL 1
#undef T39_VAL
#define T39_VAL 2
#if T39_VAL != 2
#error "TEST 39 FAILED: Redefine after undef"
#endif

/* ========== TEST 40: Empty macro ========== */
#define T40_EMPTY
int t40 T40_EMPTY = 40;

/* ========== TEST 41: Variadic basic ========== */
#define T41_VA(...) __VA_ARGS__
int t41_arr[] = { T41_VA(1, 2, 3) };

/* ========== TEST 42: Variadic stringify ========== */
#define T42_STR(...) #__VA_ARGS__
const char* t42_s = T42_STR(a, b, c);
/* Should be "a, b, c" */

/* ========== TEST 43: __LINE__ changes ========== */
int t43_line1 = __LINE__;
int t43_line2 = __LINE__;
/* t43_line2 should be t43_line1 + 1 */

/* ========== TEST 44: __FILE__ exists ========== */
const char* t44_file = __FILE__;

/* ========== TEST 45: Argument prescan ========== */
#define T45_VAL 5
#define T45_ADD(a, b) ((a) + (b))
#if T45_ADD(T45_VAL, T45_VAL) != 10
#error "TEST 45 FAILED: Argument prescan"
#endif

/* ========== TEST 46: Multiple arg use ========== */
#define T46_TRIPLE(x) ((x) + (x) + (x))
#if T46_TRIPLE(3) != 9
#error "TEST 46 FAILED: Multiple arg use"
#endif

/* ========== TEST 47: Comma in parens ========== */
#define T47_FIRST(x) x
int t47 = T47_FIRST((1, 2));
/* The (1, 2) is a single argument due to parens */

/* ========== TEST 48: Whitespace in directive ========== */
#   define    T48_VAL    48
#if T48_VAL != 48
#error "TEST 48 FAILED: Whitespace in directive"
#endif

/* ========== TEST 49: Continuation lines ========== */
#define T49_LONG one \
               two \
               three
/* Should expand to: one two three */

/* ========== TEST 50: Precedence && vs || ========== */
#if !(1 || 0 && 0)
/* This should be 1 || (0 && 0) = 1 || 0 = 1 */
#error "TEST 50 FAILED: && vs || precedence"
#endif

/* ========== SUMMARY ========== */
/* If we get here, all tests passed */
int main(void) {
    return 0;
}
