/*
 * Conditional Compilation Deep Tests
 * Focus on edge cases that often break preprocessors
 */

/* ============================================================================
 * TEST SET A: NESTED CONDITIONALS
 * ============================================================================ */

// A1: Deep nesting with all branches
#if 1
    #define DEPTH_1 1
    #if 1
        #define DEPTH_2 1
        #if 1
            #define DEPTH_3 1
            #if 1
                #define DEPTH_4 1
            #else
                #define DEPTH_4 0
            #endif
        #else
            #define DEPTH_3 0
        #endif
    #else
        #define DEPTH_2 0
    #endif
#else
    #define DEPTH_1 0
#endif

// A2: Nested in FALSE branch (content should be skipped but balanced)
#if 0
    #if 1
        should not appear
        #if 1
            #define NEVER_DEFINED 1
        #else
            more skipped
        #endif
    #else
        #if 0
            even more skipped
        #endif
    #endif
#else
    #define CORRECTLY_DEFINED 1
#endif

// A3: elif chains in nested context
#if 1
    #if 0
        skip
    #elif 0
        skip
    #elif 1
        #define NESTED_ELIF_WORKS 1
    #else
        skip
    #endif
#endif

// A4: else after nested if
#if 0
    #if 1
        skip
    #endif
#else
    #if 1
        #define ELSE_AFTER_NESTED 1
    #endif
#endif


/* ============================================================================
 * TEST SET B: COMPLEX EXPRESSIONS
 * ============================================================================ */

// B1: All operators
#if 1 + 2 * 3 == 7
    #define MATH_ORDER_OK 1
#endif

#if (1 + 2) * 3 == 9
    #define PARENS_WORK 1
#endif

#if 10 / 3 == 3
    #define INT_DIV_OK 1
#endif

#if 10 % 3 == 1
    #define MODULO_OK 1
#endif

#if -5 + 10 == 5
    #define NEGATIVE_OK 1
#endif

#if ~0 != 0
    #define BITWISE_NOT_OK 1
#endif

#if (0xFF & 0x0F) == 0x0F
    #define BITWISE_AND_OK 1
#endif

#if (0xF0 | 0x0F) == 0xFF
    #define BITWISE_OR_OK 1
#endif

#if (0xFF ^ 0x0F) == 0xF0
    #define BITWISE_XOR_OK 1
#endif

#if (1 << 4) == 16
    #define LEFT_SHIFT_OK 1
#endif

#if (16 >> 2) == 4
    #define RIGHT_SHIFT_OK 1
#endif

// B2: Comparison operators
#if 1 < 2 && 2 > 1 && 1 <= 1 && 1 >= 1 && 1 == 1 && 1 != 2
    #define ALL_COMPARISONS_OK 1
#endif

// B3: Logical operators
#if 1 && 1
    #define LOGICAL_AND_OK 1
#endif

#if 0 || 1
    #define LOGICAL_OR_OK 1
#endif

#if !0
    #define LOGICAL_NOT_OK 1
#endif

// B4: Ternary
#if (1 ? 100 : 200) == 100
    #define TERNARY_TRUE_OK 1
#endif

#if (0 ? 100 : 200) == 200
    #define TERNARY_FALSE_OK 1
#endif

// B5: Nested ternary
#if (1 ? (0 ? 1 : 2) : 3) == 2
    #define NESTED_TERNARY_OK 1
#endif

// B6: Precedence edge cases
#if 1 || 0 && 0              // && binds tighter: 1 || (0 && 0) = 1
    #define PREC_AND_OR_OK 1
#endif

#if (1 | 2) == 3             // Bitwise or
    #define PREC_BITOR_OK 1
#endif

#if (5 & 3) == 1             // Bitwise and
    #define PREC_BITAND_OK 1
#endif

// B7: Comma operator (if supported in preprocessor - it usually isn't)
// #if (1, 2, 3) == 3
//     #define COMMA_OP_OK 1
// #endif


/* ============================================================================
 * TEST SET C: defined() OPERATOR
 * ============================================================================ */

#define DEFINED_A 1

// C1: Basic defined
#if defined(DEFINED_A)
    #define DEFINED_CHECK_OK 1
#endif

// C2: defined without parens
#if defined DEFINED_A
    #define DEFINED_NO_PARENS_OK 1
#endif

// C3: !defined
#if !defined(UNDEFINED_MACRO_XYZ)
    #define NOT_DEFINED_OK 1
#endif

// C4: defined in complex expression
#if defined(DEFINED_A) && !defined(UNDEFINED_MACRO_XYZ)
    #define DEFINED_COMPLEX_OK 1
#endif

// C5: defined with OR
#if defined(UNDEFINED_MACRO_XYZ) || defined(DEFINED_A)
    #define DEFINED_OR_OK 1
#endif

// C6: defined in ternary
#if (defined(DEFINED_A) ? 1 : 0)
    #define DEFINED_TERNARY_OK 1
#endif

// C7: defined result in arithmetic
#if defined(DEFINED_A) + 1 == 2
    #define DEFINED_ARITH_OK 1
#endif


/* ============================================================================
 * TEST SET D: MACRO EXPANSION IN CONDITIONS
 * ============================================================================ */

#define TEN 10
#define TWENTY 20
#define ADD_EM (TEN + TWENTY)

// D1: Simple macro in condition
#if TEN == 10
    #define MACRO_COND_OK 1
#endif

// D2: Macro arithmetic
#if TEN + TWENTY == 30
    #define MACRO_ARITH_COND_OK 1
#endif

// D3: Macro with parens
#if ADD_EM == 30
    #define MACRO_PARENS_COND_OK 1
#endif

// D4: Macro chain
#define LEVEL_A 1
#define LEVEL_B LEVEL_A
#define LEVEL_C LEVEL_B
#if LEVEL_C == 1
    #define MACRO_CHAIN_OK 1
#endif

// D5: Undefined macro is 0
#if COMPLETELY_UNDEFINED == 0
    #define UNDEF_IS_ZERO_OK 1
#endif

// D6: Undefined in expression
#if COMPLETELY_UNDEFINED + 1 == 1
    #define UNDEF_ARITH_OK 1
#endif


/* ============================================================================
 * TEST SET E: CHARACTER LITERALS
 * ============================================================================ */

#if 'A' == 65
    #define CHAR_A_OK 1
#endif

#if 'a' == 97
    #define CHAR_a_OK 1
#endif

#if '0' == 48
    #define CHAR_0_OK 1
#endif

#if ' ' == 32
    #define CHAR_SPACE_OK 1
#endif

#if '\n' == 10
    #define CHAR_NEWLINE_OK 1
#endif

#if '\t' == 9
    #define CHAR_TAB_OK 1
#endif

#if '\r' == 13
    #define CHAR_CR_OK 1
#endif

#if '\\' == 92
    #define CHAR_BACKSLASH_OK 1
#endif

#if '\'' == 39
    #define CHAR_QUOTE_OK 1
#endif

#if '\"' == 34
    #define CHAR_DQUOTE_OK 1
#endif

#if '\0' == 0
    #define CHAR_NULL_OK 1
#endif

#if '\x41' == 65
    #define CHAR_HEX_OK 1
#endif

#if '\101' == 65
    #define CHAR_OCTAL_OK 1
#endif


/* ============================================================================
 * TEST SET F: NUMBER FORMATS
 * ============================================================================ */

#if 0x10 == 16
    #define HEX_LOWER_OK 1
#endif

#if 0X10 == 16
    #define HEX_UPPER_OK 1
#endif

#if 0xDEAD == 57005
    #define HEX_WORD_OK 1
#endif

#if 010 == 8
    #define OCTAL_OK 1
#endif

#if 0777 == 511
    #define OCTAL_FULL_OK 1
#endif

// Binary (extension)
#ifdef __GNUC__
#if 0b1010 == 10
    #define BINARY_OK 1
#endif
#endif

// Suffixes (should be ignored or handled)
#if 1L == 1
    #define SUFFIX_L_OK 1
#endif

#if 1U == 1
    #define SUFFIX_U_OK 1
#endif

#if 1UL == 1
    #define SUFFIX_UL_OK 1
#endif

#if 1LL == 1
    #define SUFFIX_LL_OK 1
#endif


/* ============================================================================
 * TEST SET G: #ifdef / #ifndef
 * ============================================================================ */

#define IS_DEFINED 1

#ifdef IS_DEFINED
    #define IFDEF_OK 1
#endif

#ifndef NOT_DEFINED_HERE
    #define IFNDEF_OK 1
#endif

#ifdef NOT_DEFINED_HERE
    #define SHOULD_NOT_EXIST 1
#endif

#ifndef IS_DEFINED
    #define SHOULD_NOT_EXIST_2 1
#endif


/* ============================================================================
 * TEST SET H: BALANCED SKIPPING
 * ============================================================================ */

// When skipping, must still balance #if/#endif

#if 0
    // This entire block is skipped, but must be balanced
    #if 1
        #if 1
            nested in skipped
        #endif
    #endif
    #if 0
    #elif 1
    #else
    #endif
    regular text that looks like code: } ] ) 
    even invalid tokens: @#$%^
#endif
#define BALANCED_SKIP_OK 1

// H2: ifdef/ifndef in skipped blocks
#if 0
    #ifdef ANYTHING
        skipped
    #endif
    #ifndef ANYTHING
        also skipped
    #endif
#endif
#define BALANCED_IFDEF_OK 1


/* ============================================================================
 * TEST SET I: EDGE CASES
 * ============================================================================ */

// I1: Empty #if branch
#if 1
#endif
#define EMPTY_IF_OK 1

// I2: Empty #else branch
#if 0
    skip
#else
#endif
#define EMPTY_ELSE_OK 1

// I3: Only elif taken
#if 0
    skip
#elif 1
    #define ONLY_ELIF_OK 1
#endif

// I4: Multiple empty elif
#if 0
#elif 0
#elif 0
#elif 1
    #define MULTI_ELIF_OK 1
#endif

// I5: All branches empty
#if 0
#elif 0
#else
#endif
#define ALL_EMPTY_OK 1

// I6: Whitespace in directive
#  if   1
    #define WHITESPACE_DIRECTIVE_OK 1
#  endif

// I7: Comments in condition (if supported)
#if 1 /* comment */ + 1 == 2
    #define COMMENT_IN_COND_OK 1
#endif

// I8: Very long condition
#if 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 == 10
    #define LONG_CONDITION_OK 1
#endif


/* ============================================================================
 * TEST SET J: #elif SPECIFIC TESTS
 * ============================================================================ */

// J1: elif with defined
#if 0
    skip
#elif defined(IS_DEFINED)
    #define ELIF_DEFINED_OK 1
#endif

// J2: elif with complex expression
#define VAL 5
#if VAL < 3
    too_small
#elif VAL >= 3 && VAL < 7
    #define ELIF_RANGE_OK 1
#elif VAL >= 7
    too_big
#endif

// J3: Multiple elif, last one taken
#if 0
    a
#elif 0
    b
#elif 0
    c
#elif 1
    #define LAST_ELIF_OK 1
#else
    e
#endif

// J4: elif but else taken
#if 0
    a
#elif 0
    b
#else
    #define ELIF_ELSE_OK 1
#endif


/* ============================================================================
 * VERIFICATION
 * ============================================================================ */

// Check that all expected defines are present
#ifndef DEPTH_1
#error "DEPTH_1 not defined"
#endif

#ifndef CORRECTLY_DEFINED
#error "CORRECTLY_DEFINED not defined"
#endif

#ifdef NEVER_DEFINED
#error "NEVER_DEFINED should not be defined"
#endif

#ifndef NESTED_ELIF_WORKS
#error "NESTED_ELIF_WORKS not defined"
#endif

// Add more verification as needed...

int main(void) {
    // Use the defines to avoid warnings
    int sum = 0;
    #ifdef DEPTH_4
    sum += DEPTH_4;
    #endif
    #ifdef CORRECTLY_DEFINED
    sum += CORRECTLY_DEFINED;
    #endif
    return sum > 0 ? 0 : 1;
}
