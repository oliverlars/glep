/*
 * Comprehensive C Preprocessor Test Suite
 * Covers: macros, conditionals, includes, operators, edge cases
 */

/* ============================================================================
 * SECTION 1: OBJECT-LIKE MACROS
 * ============================================================================ */

// 1.1 Simple replacement
#define ANSWER 42
int simple_value = ANSWER;

// 1.2 Empty macro
#define EMPTY
int x EMPTY = 5;

// 1.3 Multi-token replacement
#define DECLARATION int a, b, c
DECLARATION;

// 1.4 Macro expanding to another macro
#define INNER 100
#define OUTER INNER
int chained = OUTER;

// 1.5 Self-referential (should not infinitely recurse)
#define SELF SELF
int self_ref = SELF;

// 1.6 Mutually recursive macros
#define PING PONG
#define PONG PING
int mutual = PING;

// 1.7 Macro with parentheses (not function-like)
#define PARENS (1 + 2)
int with_parens = PARENS * 3;  // Should be (1 + 2) * 3 = 9

// 1.8 Redefining a macro (same definition - allowed)
#define REDEF 50
#define REDEF 50

// 1.9 Undef and redefine
#define CHANGEME 1
#undef CHANGEME
#define CHANGEME 2
int changed = CHANGEME;


/* ============================================================================
 * SECTION 2: FUNCTION-LIKE MACROS
 * ============================================================================ */

// 2.1 Simple function macro
#define SQUARE(x) ((x) * (x))
int sq = SQUARE(5);

// 2.2 Multiple arguments
#define ADD(a, b) ((a) + (b))
int sum = ADD(3, 4);

// 2.3 No arguments
#define FUNC() 123
int no_args = FUNC();

// 2.4 Argument used multiple times
#define TRIPLE(x) ((x) + (x) + (x))
int tripled = TRIPLE(7);

// 2.5 Nested macro calls
#define DOUBLE(x) ((x) * 2)
int nested = DOUBLE(SQUARE(3));

// 2.6 Macro call as argument
int nested2 = SQUARE(ADD(1, 2));

// 2.7 Arguments with commas (protected by parens)
int comma_arg = ADD((1, 2), 3);  // (1,2) evaluates to 2, result is 5

// 2.8 Empty argument
#define MAYBE(x) x ## _suffix
// MAYBE() would give _suffix

// 2.9 Whitespace in arguments
int whitespace = ADD(  5  ,  10  );

// 2.10 Macro that doesn't use all arguments
#define FIRST(a, b) a
int first = FIRST(100, 200);

// 2.11 Macro with complex body
#define CLAMP(val, lo, hi) ((val) < (lo) ? (lo) : ((val) > (hi) ? (hi) : (val)))
int clamped = CLAMP(50, 0, 100);


/* ============================================================================
 * SECTION 3: STRINGIFICATION (#)
 * ============================================================================ */

// 3.1 Basic stringification
#define STRINGIFY(x) #x
const char* s1 = STRINGIFY(hello);          // "hello"

// 3.2 Stringify expression
const char* s2 = STRINGIFY(1 + 2);          // "1 + 2"

// 3.3 Stringify with special chars
const char* s3 = STRINGIFY(a "b" c);        // "a \"b\" c"

// 3.4 Stringify empty
#define STRINGIFY_EMPTY(x) #x
const char* s4 = STRINGIFY_EMPTY();         // ""

// 3.5 Stringify doesn't expand macros
#define VALUE 42
const char* s5 = STRINGIFY(VALUE);          // "VALUE" not "42"

// 3.6 Indirect stringify (to expand first)
#define XSTRINGIFY(x) STRINGIFY(x)
const char* s6 = XSTRINGIFY(VALUE);         // "42"

// 3.7 Stringify with backslash
const char* s7 = STRINGIFY(a\b);            // "a\\b"


/* ============================================================================
 * SECTION 4: TOKEN PASTING (##)
 * ============================================================================ */

// 4.1 Basic concatenation
#define PASTE(a, b) a ## b
int PASTE(var, 1) = 10;                     // int var1 = 10;

// 4.2 Paste to form number
#define PASTE_NUM(a, b) a ## b
int big = PASTE_NUM(12, 34);                // int big = 1234;

// 4.3 Paste identifier parts
#define MAKE_GETTER(name) get_ ## name
int MAKE_GETTER(value)(void);               // int get_value(void);

// 4.4 Multiple pastes
#define PASTE3(a, b, c) a ## b ## c
int PASTE3(x, y, z) = 1;                    // int xyz = 1;

// 4.5 Paste with empty
#define PASTE_EMPTY(a) prefix_ ## a
int PASTE_EMPTY() = 5;                      // int prefix_ = 5; (if allowed)

// 4.6 Paste doesn't expand args directly
#define A x
#define B y
#define PASTE_DIRECT(a, b) a ## b
// PASTE_DIRECT(A, B) gives AB, not xy

// 4.7 Indirect paste for expansion
#define XPASTE(a, b) PASTE(a, b)
// XPASTE(A, B) gives xy


/* ============================================================================
 * SECTION 5: VARIADIC MACROS
 * ============================================================================ */

// 5.1 Basic variadic
#define PRINTF_LIKE(fmt, ...) printf(fmt, __VA_ARGS__)

// 5.2 Variadic with no extra args (GNU comma deletion)
#define LOG(fmt, ...) printf(fmt, ##__VA_ARGS__)

// 5.3 __VA_OPT__ (C23)
#define LOG2(fmt, ...) printf(fmt __VA_OPT__(,) __VA_ARGS__)

// 5.4 Stringify variadic
#define STRINGIFY_ARGS(...) #__VA_ARGS__
const char* args_str = STRINGIFY_ARGS(a, b, c);  // "a, b, c"

// 5.5 Count arguments (classic trick)
#define COUNT_ARGS(...) COUNT_ARGS_IMPL(__VA_ARGS__, 5, 4, 3, 2, 1, 0)
#define COUNT_ARGS_IMPL(_1, _2, _3, _4, _5, N, ...) N
int count = COUNT_ARGS(a, b, c);            // 3

// 5.6 Variadic with named args before
#define VARIADIC_NAMED(first, second, ...) first + second


/* ============================================================================
 * SECTION 6: CONDITIONAL COMPILATION
 * ============================================================================ */

// 6.1 Simple #if
#if 1
int if_true = 1;
#endif

// 6.2 #if 0
#if 0
this should not compile or even be valid syntax @#$%
#endif

// 6.3 #if with expression
#if 2 + 2 == 4
int math_works = 1;
#endif

// 6.4 #ifdef
#define FEATURE_A
#ifdef FEATURE_A
int has_feature_a = 1;
#endif

// 6.5 #ifndef
#ifndef FEATURE_B
int no_feature_b = 1;
#endif

// 6.6 #else
#if 0
int unreachable = 1;
#else
int reachable = 1;
#endif

// 6.7 #elif
#define MODE 2
#if MODE == 1
int mode_1 = 1;
#elif MODE == 2
int mode_2 = 1;
#elif MODE == 3
int mode_3 = 1;
#else
int mode_unknown = 1;
#endif

// 6.8 Nested conditionals
#if 1
    #if 1
        int nested_both = 1;
    #endif
#endif

// 6.9 Nested in false branch
#if 0
    #if 1
        not reached
    #else
        also not reached
    #endif
#endif

// 6.10 defined() operator
#if defined(FEATURE_A)
int defined_check = 1;
#endif

// 6.11 defined without parens
#if defined FEATURE_A
int defined_no_parens = 1;
#endif

// 6.12 !defined
#if !defined(FEATURE_B)
int not_defined = 1;
#endif

// 6.13 Complex expression with defined
#if defined(FEATURE_A) && !defined(FEATURE_B)
int complex_defined = 1;
#endif

// 6.14 Arithmetic in conditions
#define VERSION 305
#if VERSION >= 300 && VERSION < 400
int version_3xx = 1;
#endif

// 6.15 Bitwise ops in conditions
#if (0xFF & 0x0F) == 0x0F
int bitwise_works = 1;
#endif

// 6.16 Ternary in condition
#if (1 ? 5 : 10) == 5
int ternary_works = 1;
#endif

// 6.17 Undefined macro in expression (treated as 0)
#if UNDEFINED_MACRO
int wont_happen = 1;
#else
int undefined_is_zero = 1;
#endif

// 6.18 Macro expansion in condition
#define CHECK_VALUE 42
#if CHECK_VALUE == 42
int macro_in_condition = 1;
#endif

// 6.19 #elifdef / #elifndef (C23)
#ifdef __STDC_VERSION__
#if __STDC_VERSION__ >= 202311L
#define HAS_ELIFDEF 1
#endif
#endif

#ifdef HAS_ELIFDEF
#undef MAYBE_DEFINED
#elifndef MAYBE_DEFINED
int elifndef_works = 1;
#endif


/* ============================================================================
 * SECTION 7: INCLUDE DIRECTIVES
 * ============================================================================ */

// 7.1 System include
#include <stddef.h>

// 7.2 Local include  
// #include "myheader.h"

// 7.3 Macro expanding to include path
#define HEADER <stdint.h>
#include HEADER

// 7.4 Computed include
#define INCLUDE_FILE "somefile.h"
// #include INCLUDE_FILE

// 7.5 Include guard pattern
#ifndef MY_HEADER_H
#define MY_HEADER_H
// header content
#endif

// 7.6 #pragma once equivalent
// #pragma once


/* ============================================================================
 * SECTION 8: SPECIAL MACROS AND OPERATORS
 * ============================================================================ */

// 8.1 __FILE__
const char* current_file = __FILE__;

// 8.2 __LINE__
int current_line = __LINE__;

// 8.3 __DATE__
const char* compile_date = __DATE__;

// 8.4 __TIME__
const char* compile_time = __TIME__;

// 8.5 __func__ (not preprocessor, but related)
void test_func(void) {
    const char* fn = __func__;
}

// 8.6 __STDC__
#ifdef __STDC__
int is_standard_c = 1;
#endif

// 8.7 __STDC_VERSION__
#ifdef __STDC_VERSION__
long stdc_version = __STDC_VERSION__;
#endif

// 8.8 __COUNTER__ (extension)
#ifdef __COUNTER__
int counter1 = __COUNTER__;
int counter2 = __COUNTER__;
int counter3 = __COUNTER__;
#endif

// 8.9 _Pragma operator
_Pragma("once")

// 8.10 #pragma
#pragma message("This is a pragma message")


/* ============================================================================
 * SECTION 9: LINE AND ERROR DIRECTIVES
 * ============================================================================ */

// 9.1 #line directive
#line 1000
int at_line_1000 = __LINE__;  // Should be 1000

// 9.2 #line with filename
#line 1 "fake_file.c"
int fake_file_line = __LINE__;

// Reset for rest of file
#line 400 "preprocessor_tests.c"

// 9.3 #error (commented out to not break compilation)
// #if 0
// #error "This is an error message"
// #endif

// 9.4 #warning (extension, commented out)
// #warning "This is a warning"


/* ============================================================================
 * SECTION 10: EDGE CASES AND TRICKY SCENARIOS
 * ============================================================================ */

// 10.1 Macro in macro definition
#define BASE 10
#define DERIVED (BASE + 5)
int derived = DERIVED;

// 10.2 Recursive-looking but not recursive
#define FOO (4 + FOO_HELPER)
#define FOO_HELPER 2
int foo = FOO;                              // (4 + 2) = 6

// 10.3 Argument prescan
#define EXPAND(x) x
#define INDIRECT(x) EXPAND(x)
#define VALUE_X 100
int prescan = INDIRECT(VALUE_X);            // 100

// 10.4 Blue paint (preventing recursion)
#define RECURSE(x) x RECURSE
// RECURSE(a) gives: a RECURSE (RECURSE is painted blue, won't expand again)

// 10.5 Token pasting creating new macro name
#define CAT(a, b) a ## b
#define XY 999
int from_paste = CAT(X, Y);                 // 999

// 10.6 Empty arguments
#define SURROUND(x) [x]
// SURROUND() gives []

// 10.7 Whitespace preservation
#define SPACY    a    b    c
// Should preserve internal whitespace: a    b    c

// 10.8 Continuation lines
#define MULTILINE one \
                  two \
                  three
int multiline_result = MULTILINE;           // one two three as separate tokens

// 10.9 Macro call split across lines
int split_call = ADD(1,
                     2);

// 10.10 Comments in macro
#define WITH_COMMENT value /* comment */ + 1
int with_comment = WITH_COMMENT;

// 10.11 Stringification preserves whitespace
const char* spacy_str = STRINGIFY(  a   b  );  // "a b" (normalized)

// 10.12 Paste at start/end
#define PREFIX_(x) prefix_ ## x
#define _SUFFIX(x) x ## _suffix
int PREFIX_(name) = 1;
int _SUFFIX(name) = 2;

// 10.13 Function-like macro without parens
#define FUNCLIKE(x) x
int not_a_call = FUNCLIKE;                  // FUNCLIKE stays as identifier

// 10.14 Nested function macro calls
#define OUTER_FUNC(x) INNER_FUNC(x)
#define INNER_FUNC(x) ((x) * 2)
int double_nested = OUTER_FUNC(5);

// 10.15 Argument stringification with macro
#define STR_ARG(x) #x
#define SHOW(x) STR_ARG(x)
const char* show_expanded = SHOW(VALUE_X);  // "100"

// 10.16 Variadic edge: single argument that contains comma
#define SHOW_ARGS(...) __VA_ARGS__
int arr[] = { SHOW_ARGS(1, 2, 3) };

// 10.17 Chained redirection  
#define LEVEL1 LEVEL2
#define LEVEL2 LEVEL3
#define LEVEL3 42
int chained_deep = LEVEL1;                  // 42

// 10.18 Operator-like macros
#define AND &&
#define OR ||
#define NOT !
int logical = (1 AND 1) OR (NOT 0);

// 10.19 Macro defining another directive (doesn't work)
#define DEFINE_X #define X 1
// DEFINE_X  // This won't create a new macro

// 10.20 Unicode in macros (implementation-defined)
#define EMOJI 1
int emoji_val = EMOJI;


/* ============================================================================
 * SECTION 11: APPLE/CLANG SPECIFIC PATTERNS
 * ============================================================================ */

// 11.1 __has_feature
#ifdef __has_feature
    #if __has_feature(objc_arc)
        // ARC is enabled
    #endif
#endif

// 11.2 __has_include
#ifdef __has_include
    #if __has_include(<optional>)
        // Can include <optional>
    #endif
#endif

// 11.3 __has_attribute
#ifdef __has_attribute
    #if __has_attribute(always_inline)
        #define FORCE_INLINE __attribute__((always_inline))
    #else
        #define FORCE_INLINE
    #endif
#endif

// 11.4 __has_builtin
#ifdef __has_builtin
    #if __has_builtin(__builtin_expect)
        #define LIKELY(x) __builtin_expect(!!(x), 1)
    #else
        #define LIKELY(x) (x)
    #endif
#endif

// 11.5 Availability macros (simplified)
#define API_AVAILABLE(...) __attribute__((availability(__VA_ARGS__)))
#define API_DEPRECATED(...) __attribute__((deprecated(__VA_ARGS__)))

// 11.6 __has_extension
#ifdef __has_extension
    #if __has_extension(c_static_assert)
        // Has static assert
    #endif
#endif

// 11.7 Feature test macro pattern
#ifndef __has_feature
    #define __has_feature(x) 0
#endif
#ifndef __has_extension
    #define __has_extension(x) __has_feature(x)
#endif

// 11.8 Complex availability (like Apple's __API_AVAILABLE)
#define __AVAILABILITY_INTERNAL(...)
#define __API_A(x) __AVAILABILITY_INTERNAL(x)


/* ============================================================================
 * SECTION 12: PRACTICAL PATTERNS
 * ============================================================================ */

// 12.1 Assert macro
#define ASSERT(cond) do { if (!(cond)) { /* abort */ } } while(0)

// 12.2 Debug print
#ifdef DEBUG
    #define DPRINTF(fmt, ...) printf("[DEBUG] " fmt, ##__VA_ARGS__)
#else
    #define DPRINTF(fmt, ...) ((void)0)
#endif

// 12.3 MIN/MAX
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

// 12.4 Array size
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

// 12.5 Stringify for debug
#define TRACE(var) printf(#var " = %d\n", var)

// 12.6 Concatenate for struct accessors
#define GETTER(type, field) type get_##field(void)
#define SETTER(type, field) void set_##field(type value)

// 12.7 X-Macros pattern
#define COLORS \
    X(RED, 0xFF0000) \
    X(GREEN, 0x00FF00) \
    X(BLUE, 0x0000FF)

// Generate enum
#define X(name, value) COLOR_##name = value,
enum Colors { COLORS };
#undef X

// Generate string array
#define X(name, value) #name,
const char* color_names[] = { COLORS };
#undef X

// 12.8 Static assert (pre-C11)
#define STATIC_ASSERT(cond, msg) typedef char static_assert_##msg[(cond) ? 1 : -1]

// 12.9 Likely/Unlikely branch hints
#ifndef LIKELY
    #define LIKELY(x) (x)
#endif
#ifndef UNLIKELY
    #define UNLIKELY(x) (x)
#endif

// 12.10 Compile-time offsetof
#define OFFSETOF(type, member) ((size_t)&(((type*)0)->member))

// 12.11 Container_of pattern
#define CONTAINER_OF(ptr, type, member) \
    ((type*)((char*)(ptr) - OFFSETOF(type, member)))

// 12.12 Scope guard pattern (GCC extension)
#ifdef __GNUC__
#define CLEANUP(func) __attribute__((cleanup(func)))
#endif

// 12.13 Versioned symbols
#define VERSION_MAJOR 1
#define VERSION_MINOR 2
#define VERSION_PATCH 3
#define VERSION_STRING \
    XSTRINGIFY(VERSION_MAJOR) "." \
    XSTRINGIFY(VERSION_MINOR) "." \
    XSTRINGIFY(VERSION_PATCH)

// 12.14 Platform detection
#if defined(_WIN32)
    #define PLATFORM_WINDOWS 1
#elif defined(__APPLE__)
    #define PLATFORM_APPLE 1
#elif defined(__linux__)
    #define PLATFORM_LINUX 1
#endif

// 12.15 Compiler detection
#if defined(__clang__)
    #define COMPILER_CLANG 1
#elif defined(__GNUC__)
    #define COMPILER_GCC 1
#elif defined(_MSC_VER)
    #define COMPILER_MSVC 1
#endif


/* ============================================================================
 * SECTION 13: OPERATOR PRECEDENCE IN CONDITIONS
 * ============================================================================ */

// 13.1 Logical operators
#if 1 || 0 && 0          // && higher precedence than ||
int logic_precedence = 1;
#endif

// 13.2 Comparison chains
#if 1 < 2 && 2 < 3
int chained_compare = 1;
#endif

// 13.3 Bitwise vs logical
#if (1 & 0) || 1
int bitwise_logical = 1;
#endif

// 13.4 Shift operators
#if (1 << 3) == 8
int shift_works = 1;
#endif

// 13.5 Unary operators
#if -1 < 0 && +1 > 0 && !0 && ~0 != 0
int unary_works = 1;
#endif

// 13.6 Complex nested
#if ((1 + 2) * 3 - 4) / 2 == 2
int complex_math = 1;  // (3*3-4)/2 = 5/2 = 2
#endif

// 13.7 Comparison operators
#if 1 == 1 && 1 != 2 && 1 < 2 && 2 > 1 && 1 <= 1 && 2 >= 2
int all_comparisons = 1;
#endif

// 13.8 Modulo
#if 10 % 3 == 1
int modulo_works = 1;
#endif

// 13.9 Division (integer)
#if 7 / 2 == 3
int int_division = 1;
#endif

// 13.10 Negative numbers
#if -5 + 10 == 5
int negative_add = 1;
#endif


/* ============================================================================
 * SECTION 14: CHARACTER AND NUMERIC LITERALS IN PREPROCESSOR
 * ============================================================================ */

// 14.1 Character literals
#if 'A' == 65
int char_literal = 1;
#endif

// 14.2 Multi-char literals (implementation-defined)
#if 'AB' != 0
int multichar = 1;
#endif

// 14.3 Hex literals
#if 0xFF == 255
int hex_literal = 1;
#endif

// 14.4 Octal literals
#if 010 == 8
int octal_literal = 1;
#endif

// 14.5 Binary literals (C23/extension)
#ifdef __GNUC__
#if 0b1010 == 10
int binary_literal = 1;
#endif
#endif

// 14.6 Suffixed literals (usually ignored in preprocessor)
#if 1L == 1
int long_suffix = 1;
#endif

// 14.7 Unsigned
#if 1U == 1
int unsigned_suffix = 1;
#endif

// 14.8 Escape sequences in char literals
#if '\n' == 10
int newline_char = 1;
#endif

#if '\t' == 9
int tab_char = 1;
#endif

#if '\\' == 92
int backslash_char = 1;
#endif

#if '\'' == 39
int quote_char = 1;
#endif

// 14.9 Hex escape in char
#if '\x41' == 'A'
int hex_escape = 1;
#endif

// 14.10 Octal escape in char
#if '\101' == 'A'
int octal_escape = 1;
#endif


/* ============================================================================
 * SECTION 15: WHITESPACE AND FORMATTING EDGE CASES
 * ============================================================================ */

// 15.1 No space after #
#/*comment*/define/**/ COMMENT_IN_DIRECTIVE 1

// 15.2 Space before directive
   #define INDENTED_DIRECTIVE 1

// 15.3 Tab before directive
	#define TABBED_DIRECTIVE 1

// 15.4 Multiple continuations
#define VERY_LONG_MACRO \
    part1 \
    part2 \
    part3 \
    part4

// 15.5 Continuation with nothing after backslash
#define TRAILING_BACKSLASH abc\
def

// 15.6 Empty continuation lines
#define EMPTY_CONT \
\
value

// 15.7 Directive name variations
#  define  EXTRA_SPACES  1

// 15.8 Null directive
#
# 

// 15.9 Stringify whitespace normalization
#define STR(x) #x
const char* ws1 = STR(a    b);              // "a b"
const char* ws2 = STR(  a  );               // "a"


/* ============================================================================
 * SECTION 16: SPECIAL TOKEN HANDLING
 * ============================================================================ */

// 16.1 Digraphs
#define DIGRAPH_TEST <: :> <% %> %: %:%:
// <: is [, :> is ]
// <% is {, %> is }
// %: is #, %:%: is ##

// 16.2 Alternative tokens
#define ALT_AND and
#define ALT_OR or
// These require <iso646.h> in standard C

// 16.3 Paste creating invalid token
// #define BAD_PASTE(a, b) a ## ## b  // Error: ## ## is invalid

// 16.4 Paste creating valid preprocessing number
#define MAKE_FLOAT(a, b) a ## . ## b
// MAKE_FLOAT(3, 14) gives 3.14

// 16.5 String concatenation (not paste - compiler feature)
const char* concat = "hello" " " "world";

// 16.6 Wide strings
const wchar_t* wide = L"wide string";

// 16.7 UTF-8 strings (C11+)
#ifdef __STDC_VERSION__
#if __STDC_VERSION__ >= 201112L
const char* utf8 = u8"UTF-8 string";
#endif
#endif


/* ============================================================================
 * SECTION 17: ERROR CONDITIONS (commented to not break compilation)
 * ============================================================================ */

/*
// 17.1 Unterminated macro call
// ADD(1, 2

// 17.2 Wrong number of arguments
// ADD(1)
// ADD(1, 2, 3)

// 17.3 # not followed by parameter
// #define BAD_STRINGIFY(x) # y

// 17.4 ## at start or end
// #define BAD_PASTE1 ## a
// #define BAD_PASTE2 a ##

// 17.5 Undefined behavior: pasting to create invalid token
// #define INVALID_PASTE(a) a ## "string"

// 17.6 Recursive include (if created)
// #include "preprocessor_tests.c"

// 17.7 Include file not found
// #include <nonexistent.h>
// #include "nonexistent.h"

// 17.8 Invalid directive
// #invalid_directive

// 17.9 Missing endif
// #if 1

// 17.10 Else without if
// #else

// 17.11 Endif without if
// #endif

// 17.12 Invalid constant expression
// #if 1 / 0

// 17.13 Incomplete defined()
// #if defined(

// 17.14 Invalid token in condition
// #if 1 + "string"
*/


/* ============================================================================
 * SECTION 18: PRAGMA DIRECTIVES
 * ============================================================================ */

// 18.1 Standard pragmas
#pragma STDC FP_CONTRACT ON
#pragma STDC FENV_ACCESS OFF
#pragma STDC CX_LIMITED_RANGE ON

// 18.2 Pragma once
#pragma once

// 18.3 Pragma push/pop (common extension)
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4996)
#pragma warning(pop)
#endif

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic pop
#endif

#ifdef __GNUC__
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic pop
#endif

// 18.4 Pragma pack
#pragma pack(push, 1)
struct Packed { char a; int b; };
#pragma pack(pop)

// 18.5 _Pragma operator
#define DO_PRAGMA(x) _Pragma(#x)
#define DIAGNOSTIC_PUSH DO_PRAGMA(GCC diagnostic push)


/* ============================================================================
 * SECTION 19: MACRO EXPANSION ORDER TESTS
 * ============================================================================ */

// 19.1 Argument prescan (arguments expanded before substitution)
#define DOUBLE_IT(x) x + x
#define FIVE 5
int prescan_test = DOUBLE_IT(FIVE);         // 5 + 5, not FIVE + FIVE

// 19.2 But not if stringified or pasted
#define STR_IT(x) #x
const char* no_prescan = STR_IT(FIVE);      // "FIVE", not "5"

// 19.3 Rescan after substitution
#define A_VAL 1
#define B_VAL 2
#define GET_VAL(x) x ## _VAL
int rescan_test = GET_VAL(A);               // A_VAL -> 1

// 19.4 Multiple expansion levels
#define L1(x) L2(x)
#define L2(x) L3(x)
#define L3(x) (x)
#define DEEPVAL 42
int deep_expansion = L1(DEEPVAL);           // 42

// 19.5 Painted blue stays blue
#define PAINT_TEST PAINT_TEST
int paint_stays = PAINT_TEST;               // PAINT_TEST (no infinite recursion)

// 19.6 Complex recursion prevention
#define REC1(x) REC2(x) REC1
#define REC2(x) x
// REC1(a) gives: a REC1 (REC1 is blue in this context)


/* ============================================================================
 * SECTION 20: MISCELLANEOUS
 * ============================================================================ */

// 20.1 Long macro names
#define THIS_IS_A_VERY_LONG_MACRO_NAME_THAT_TESTS_IDENTIFIER_LENGTH_LIMITS 1

// 20.2 Macro with keywords as name (don't do this, but technically allowed)
// #define int long  // This is valid but horrible

// 20.3 Macro shadowing
#define shadow 1
int use_shadow = shadow;
#undef shadow
#define shadow 2
int use_shadow2 = shadow;

// 20.4 Conditional within macro (doesn't work as expected)
#define COND_MACRO(x) \
    x + 1
// Directives inside macros are not processed as directives

// 20.5 Empty #if branch
#if 0
#elif 1
int empty_if = 1;
#endif

// 20.6 Multiple elif
#define CHOICE 3
#if CHOICE == 1
int c1 = 1;
#elif CHOICE == 2
int c2 = 1;
#elif CHOICE == 3
int c3 = 1;
#elif CHOICE == 4
int c4 = 1;
#else
int c_other = 1;
#endif

// 20.7 Defined on macro-expanded name
#define FEATURE_NAME FEATURE_A
#if defined(FEATURE_NAME)  // checks if FEATURE_NAME is defined, not FEATURE_A
int defined_direct = 1;
#endif

// 20.8 Trigraphs (obsolete, usually disabled)
// ??= is #, ??( is [, ??) is ]
// Most compilers disable these by default

// 20.9 Very deep nesting
#if 1
#if 1
#if 1
#if 1
#if 1
int deep_nest = 1;
#endif
#endif
#endif
#endif
#endif

// 20.10 Almost recursive through function-like
#define ALMOST_REC(x) ALMOST_REC_HELPER(x)
#define ALMOST_REC_HELPER(x) x
int almost_rec = ALMOST_REC(ALMOST_REC(5)); // Works fine, inner is blue in outer


/* ============================================================================
 * END OF TESTS
 * ============================================================================ */

int main(void) {
    return 0;
}
