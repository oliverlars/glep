/*
 * Expected Preprocessor Output Reference
 * 
 * This file shows what key constructs should expand to,
 * useful for verifying your preprocessor's output.
 */

/* ============================================================================
 * OBJECT-LIKE MACROS
 * ============================================================================ */

// Input:
//   #define ANSWER 42
//   int x = ANSWER;
// Expected output:
//   int x = 42;

// Input:
//   #define EMPTY
//   int x EMPTY = 5;
// Expected output:
//   int x = 5;

// Input:
//   #define INNER 100
//   #define OUTER INNER
//   int x = OUTER;
// Expected output:
//   int x = 100;

// Input:
//   #define SELF SELF
//   int x = SELF;
// Expected output:
//   int x = SELF;
// Note: SELF is "painted blue" - no infinite recursion

// Input:
//   #define PARENS (1 + 2)
//   int x = PARENS * 3;
// Expected output:
//   int x = (1 + 2) * 3;


/* ============================================================================
 * FUNCTION-LIKE MACROS
 * ============================================================================ */

// Input:
//   #define SQUARE(x) ((x) * (x))
//   int x = SQUARE(5);
// Expected output:
//   int x = ((5) * (5));

// Input:
//   #define ADD(a, b) ((a) + (b))
//   int x = ADD(3, 4);
// Expected output:
//   int x = ((3) + (4));

// Input:
//   #define DOUBLE(x) ((x) * 2)
//   #define SQUARE(x) ((x) * (x))
//   int x = DOUBLE(SQUARE(3));
// Expected output:
//   int x = ((((3) * (3))) * 2);

// Input:
//   #define FUNCLIKE(x) x
//   int x = FUNCLIKE;
// Expected output:
//   int x = FUNCLIKE;
// Note: Without parens after FUNCLIKE, it's not a macro call


/* ============================================================================
 * STRINGIFICATION
 * ============================================================================ */

// Input:
//   #define STRINGIFY(x) #x
//   const char* s = STRINGIFY(hello);
// Expected output:
//   const char* s = "hello";

// Input:
//   #define STRINGIFY(x) #x
//   const char* s = STRINGIFY(a + b);
// Expected output:
//   const char* s = "a + b";

// Input:
//   #define STRINGIFY(x) #x
//   const char* s = STRINGIFY(say "hi");
// Expected output:
//   const char* s = "say \"hi\"";
// Note: Quotes inside get escaped

// Input:
//   #define STRINGIFY(x) #x
//   const char* s = STRINGIFY(a\b);
// Expected output:
//   const char* s = "a\\b";
// Note: Backslashes get escaped

// Input:
//   #define STRINGIFY(x) #x
//   #define VALUE 42
//   const char* s = STRINGIFY(VALUE);
// Expected output:
//   const char* s = "VALUE";
// Note: # prevents argument expansion

// Input:
//   #define STRINGIFY(x) #x
//   #define XSTRINGIFY(x) STRINGIFY(x)
//   #define VALUE 42
//   const char* s = XSTRINGIFY(VALUE);
// Expected output:
//   const char* s = "42";
// Note: Extra indirection allows expansion first

// Input:
//   #define STRINGIFY(x) #x
//   const char* s = STRINGIFY(  a   b  );
// Expected output:
//   const char* s = "a b";
// Note: Whitespace is normalized


/* ============================================================================
 * TOKEN PASTING
 * ============================================================================ */

// Input:
//   #define PASTE(a, b) a ## b
//   int var1 = 0;
//   int x = PASTE(var, 1);
// Expected output:
//   int x = var1;

// Input:
//   #define PASTE(a, b) a ## b
//   #define XY 42
//   int x = PASTE(X, Y);
// Expected output (before rescan):
//   int x = XY;
// Expected output (after rescan):
//   int x = 42;

// Input:
//   #define PASTE(a, b) a ## b
//   #define XPASTE(a, b) PASTE(a, b)
//   #define AA X
//   #define BB Y
//   #define XY 42
//   int x = PASTE(AA, BB);
// Expected output:
//   int x = AABB;
// Note: ## prevents argument prescan

// Input (with XPASTE):
//   int x = XPASTE(AA, BB);
// Expected output:
//   int x = 42;
// Note: Extra indirection allows prescan: AA->X, BB->Y, then XY->42


/* ============================================================================
 * VARIADIC MACROS
 * ============================================================================ */

// Input:
//   #define LOG(fmt, ...) printf(fmt, __VA_ARGS__)
//   LOG("x=%d y=%d", x, y);
// Expected output:
//   printf("x=%d y=%d", x, y);

// Input:
//   #define LOG(fmt, ...) printf(fmt, ##__VA_ARGS__)
//   LOG("hello");
// Expected output:
//   printf("hello");
// Note: ## removes the trailing comma when __VA_ARGS__ is empty

// Input:
//   #define STRINGIFY_ARGS(...) #__VA_ARGS__
//   const char* s = STRINGIFY_ARGS(a, b, c);
// Expected output:
//   const char* s = "a, b, c";


/* ============================================================================
 * CONDITIONAL COMPILATION
 * ============================================================================ */

// Input:
//   #if 1
//   int x = 1;
//   #else
//   int x = 0;
//   #endif
// Expected output:
//   int x = 1;

// Input:
//   #if 0
//   anything here is skipped, even @#$%^ invalid tokens
//   #endif
// Expected output:
//   (empty - nothing output)

// Input:
//   #define FOO 1
//   #if defined(FOO) && FOO == 1
//   int x = 1;
//   #endif
// Expected output:
//   int x = 1;

// Input:
//   #if UNDEFINED_MACRO
//   int x = 1;
//   #else
//   int x = 0;
//   #endif
// Expected output:
//   int x = 0;
// Note: Undefined macros in #if are treated as 0


/* ============================================================================
 * EXPANSION ORDER SUMMARY
 * ============================================================================ */

/*
 * 1. When a function-like macro is invoked:
 *    a. Identify the arguments
 *    b. PRESCAN: Expand macros in each argument (unless used with # or ##)
 *    c. Substitute the expanded arguments into the macro body
 *    d. RESCAN: Expand macros in the substituted body
 *    e. Mark the original macro as "blue" (can't expand again in rescan)
 * 
 * 2. Stringification (#):
 *    - The argument is NOT expanded before stringifying
 *    - Use double indirection (XSTRINGIFY) to expand first
 * 
 * 3. Token pasting (##):
 *    - Arguments are NOT expanded before pasting
 *    - Use double indirection (XPASTE) to expand first
 *    - The result IS subject to rescan
 * 
 * 4. Self-reference:
 *    - During rescan, if the macro being expanded appears, it's "painted blue"
 *    - A blue macro is not expanded, preventing infinite recursion
 */


/* ============================================================================
 * CONDITION EXPRESSION EVALUATION
 * ============================================================================ */

/*
 * Operators (in precedence order, lowest to highest):
 * 
 * 1.  ?:              (ternary, right-to-left)
 * 2.  ||              (logical or)
 * 3.  &&              (logical and)
 * 4.  |               (bitwise or)
 * 5.  ^               (bitwise xor)
 * 6.  &               (bitwise and)
 * 7.  == !=           (equality)
 * 8.  < <= > >=       (relational)
 * 9.  << >>           (shift)
 * 10. + -             (additive)
 * 11. * / %           (multiplicative)
 * 12. ! ~ - +         (unary, right-to-left)
 * 13. defined()       (special unary)
 * 14. ()              (grouping)
 * 
 * Literals:
 * - Decimal: 42
 * - Hex: 0xFF, 0XFF
 * - Octal: 0777
 * - Binary (ext): 0b1010
 * - Character: 'A', '\n', '\x41'
 * - Suffixes (L, U, LL, etc.) should be recognized but don't change value
 * 
 * Special:
 * - Undefined identifiers evaluate to 0
 * - defined(X) or defined X evaluates to 1 if X is defined, 0 otherwise
 */


/* ============================================================================
 * COMMON BUGS TO WATCH FOR
 * ============================================================================ */

/*
 * 1. Not handling self-reference (infinite loop)
 *    #define X X
 *    int a = X;  // Should just be X, not infinite loop
 * 
 * 2. Expanding before stringify/paste
 *    #define V 42
 *    #define S(x) #x
 *    S(V) should be "V", not "42"
 * 
 * 3. Not rescanning after substitution
 *    #define A B
 *    #define B 42
 *    int x = A;  // Should be 42, not B
 * 
 * 4. Wrong handling of empty __VA_ARGS__
 *    #define F(fmt, ...) f(fmt, __VA_ARGS__)
 *    F("x")  // Should not have trailing comma
 * 
 * 5. Not balancing #if/#endif in skipped blocks
 *    #if 0
 *    #if 1
 *    #endif  // This endif is for the inner #if
 *    #endif  // This one ends the #if 0
 * 
 * 6. Treating #if UNDEFINED as error instead of 0
 *    #if NOTDEF
 *    ...
 *    #endif
 * 
 * 7. Not handling defined() in complex expressions
 *    #if defined(X) && X > 0
 * 
 * 8. Wrong operator precedence in conditions
 *    #if 1 || 0 && 0  // Should be 1 || (0 && 0) = 1
 * 
 * 9. Not handling character literals
 *    #if 'A' == 65
 * 
 * 10. Macro call spanning multiple lines
 *    MACRO(a,
 *          b);
 */
