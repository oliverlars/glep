
// #include <stdlib.h>
#include <stdio.h>


int main() {

	struct B {
		int x;
		int y;
		int z;
	};
	struct A { 
		int a;
		int b;
		int c;
		struct B the_other;
	};

	struct A adfadf = {};
	adfadf.b = 10;
	adfadf.the_other.x = 10;
	printf("%d\n", adfadf.the_other.x);
}

//#define DO_TEST

#if defined(DO_TEST)
int main(void) {
	// ========================================================================
	// INTEGER PROMOTIONS
	// Types smaller than int promote to int in expressions
	// ========================================================================

	char c1 = 100;
	char c2 = 50;
	signed char sc1 = -10;
	signed char sc2 = 20;
	unsigned char uc1 = 200;
	unsigned char uc2 = 100;
	short s1 = 1000;
	short s2 = 500;
	unsigned short us1 = 60000;
	unsigned short us2 = 10000;

	// All these promote to int before operation
	int promo1 = c1 + c2;           // char + char -> int
	int promo2 = sc1 + sc2;         // signed char + signed char -> int
	int promo3 = uc1 + uc2;         // unsigned char + unsigned char -> int
	int promo4 = s1 + s2;           // short + short -> int
	int promo5 = us1 + us2;         // unsigned short + unsigned short -> int

	printf("char + char: %d (expect 150)\n", promo1);
	printf("schar + schar: %d (expect 10)\n", promo2);
	printf("uchar + uchar: %d (expect 300)\n", promo3);
	printf("short + short: %d (expect 1500)\n", promo4);
	printf("ushort + ushort: %d (expect 70000)\n", promo5);

	// Unary operators also promote
	unsigned char mask = 0x0F;
	int inverted = ~mask;           // promotes to int, then ~, result is negative
	int negated = -sc1;             // promotes to int, then negate

	printf("~(uchar 0x0F): %d (expect -16)\n", inverted);
	printf("-(schar -10): %d (expect 10)\n", negated);

	// ========================================================================
	// USUAL ARITHMETIC CONVERSIONS
	// Binary operators convert operands to common type
	// ========================================================================

	int i1 = 100;
	int i2 = -50;
	unsigned int ui1 = 100u;
	unsigned int ui2 = 200u;
	long l1 = 100000L;
	long l2 = 50000L;
	unsigned long ul1 = 100000uL;
	float f1 = 3.5f;
	float f2 = 2.0f;
	double d1 = 3.5;
	double d2 = 1.5;

	// int + int -> int
	int arith1 = i1 + i2;
	printf("int + int: %d (expect 50)\n", arith1);

	// int + unsigned int -> unsigned int
	unsigned int arith2 = i1 + ui1;
	printf("int + uint: %u (expect 200)\n", arith2);

	// int + long -> long
	long arith3 = i1 + l1;
	printf("int + long: %ld (expect 100100)\n", arith3);

	// long + unsigned long -> unsigned long
	unsigned long arith4 = l1 + ul1;
	printf("long + ulong: %lu (expect 200000)\n", arith4);

	// int + float -> float
	float arith5 = i1 + f1;
	printf("int + float: %f (expect 103.5)\n", arith5);

	// int + double -> double
	double arith6 = i1 + d1;
	printf("int + double: %f (expect 103.5)\n", arith6);

	// float + double -> double
	double arith7 = f1 + d1;
	printf("float + double: %f (expect 7.0)\n", arith7);

	// float + float -> float
	float arith8 = f1 + f2;
	printf("float + float: %f (expect 5.5)\n", arith8);

	// double + double -> double
	double arith9 = d1 + d2;
	printf("double + double: %f (expect 5.0)\n", arith9);

	// ========================================================================
	// ASSIGNMENT CONVERSIONS (implicit casts)
	// ========================================================================

	// Widening: safe, no data loss
	int wide1 = c1;                 // char -> int
	long wide2 = i1;                // int -> long
	double wide3 = f1;              // float -> double
	double wide4 = i1;              // int -> double
	float wide5 = i1;               // int -> float

	printf("char -> int: %d (expect 100)\n", wide1);
	printf("int -> long: %ld (expect 100)\n", wide2);
	printf("float -> double: %f (expect 3.5)\n", wide3);
	printf("int -> double: %f (expect 100.0)\n", wide4);
	printf("int -> float: %f (expect 100.0)\n", wide5);

	// Narrowing: potential data loss
	char narrow1 = i1;              // int -> char
	short narrow2 = i1;             // int -> short
	int narrow3 = l1;               // long -> int (may truncate)
	float narrow4 = d1;             // double -> float

	printf("int(100) -> char: %d (expect 100)\n", narrow1);
	printf("int(100) -> short: %d (expect 100)\n", narrow2);
	printf("long(100000) -> int: %d (expect 100000)\n", narrow3);
	printf("double -> float: %f (expect 3.5)\n", narrow4);

	// Float to int truncation
	int trunc1 = f1;                // 3.5 -> 3
	int trunc2 = d1;                // 3.5 -> 3
	double neg_d = -3.7;
	int trunc3 = neg_d;             // -3.7 -> -3 (truncates toward zero)

	printf("float(3.5) -> int: %d (expect 3)\n", trunc1);
	printf("double(3.5) -> int: %d (expect 3)\n", trunc2);
	printf("double(-3.7) -> int: %d (expect -3)\n", trunc3);

	// ========================================================================
	// POINTER CONVERSIONS
	// ========================================================================

	int x = 42;
	int arr[3] = {10, 20, 30};

	int *ip = &x;                   // address-of
	void *vp = ip;                  // any pointer -> void*
	int *ip2 = vp;                  // void* -> any pointer (implicit in C)

	int *null1 = 0;                 // 0 -> null pointer
	void *null2 = 0;

	int *arr_ptr = arr;             // array -> pointer decay

	printf("*ip: %d (expect 42)\n", *ip);
	printf("*ip2 (via void*): %d (expect 42)\n", *ip2);
	printf("arr[0]: %d, *arr_ptr: %d (expect 10, 10)\n", arr[0], *arr_ptr);

	// Pointer arithmetic (requires knowing pointed-to size)
	int *ip3 = arr + 1;             // pointer + int
	int *ip4 = 2 + arr;             // int + pointer
	int diff = ip3 - arr;           // pointer - pointer -> ptrdiff_t

	printf("*(arr+1): %d (expect 20)\n", *ip3);
	printf("*(2+arr): %d (expect 30)\n", *ip4);
	printf("ptr diff: %d (expect 1)\n", diff);

	// ========================================================================
	// LITERAL SUFFIXES
	// ========================================================================

	// Integer literals
	int lit_i = 42;                 // int
	unsigned int lit_ui = 42u;      // unsigned int
	unsigned int lit_ui2 = 42U;     // unsigned int
	long lit_l = 42l;               // long
	long lit_l2 = 42L;              // long
	unsigned long lit_ul = 42ul;    // unsigned long
	unsigned long lit_ul2 = 42UL;   // unsigned long
	long long lit_ll = 42ll;        // long long
	long long lit_ll2 = 42LL;       // long long
	unsigned long long lit_ull = 42ull;  // unsigned long long

	printf("int lit: %d\n", lit_i);
	printf("uint lit: %u\n", lit_ui);
	printf("long lit: %ld\n", lit_l);
	printf("ulong lit: %lu\n", lit_ul);
	printf("llong lit: %lld\n", lit_ll);
	printf("ullong lit: %llu\n", lit_ull);

	// Float literals
	float lit_f = 3.14f;            // float
	float lit_f2 = 3.14F;           // float
	double lit_d = 3.14;            // double (default)
	long double lit_ld = 3.14l;     // long double
	long double lit_ld2 = 3.14L;    // long double

	printf("float lit: %f\n", lit_f);
	printf("double lit: %f\n", lit_d);
	printf("long double lit: %Lf\n", lit_ld);

	// Hex, octal, binary literals
	int hex = 0xFF;
	int octal = 0777;
	unsigned int hex_u = 0xFFu;
	long hex_l = 0xFFL;

	printf("hex 0xFF: %d (expect 255)\n", hex);
	printf("octal 0777: %d (expect 511)\n", octal);

	// ========================================================================
	// MIXED EXPRESSIONS (combining multiple conversion rules)
	// ========================================================================

	// char + int * float -> float
	float mix1 = c1 + i1 * f1;
	printf("char + int * float: %f (expect 450.0)\n", mix1);

	// (char + char) / double -> double
	double mix2 = (c1 + c2) / d1;
	printf("(char + char) / double: %f (expect ~42.86)\n", mix2);

	// pointer + (char * short) / int -> pointer
	int *mix3 = arr + (c1 * s1) / 50000;
	printf("complex ptr arith: %d (expect 20 or 30)\n", *mix3);

	// ========================================================================
	// COMPARISON OPERATORS (result is always int 0 or 1)
	// ========================================================================

	int cmp1 = i1 < i2;             // int < int -> int
	int cmp2 = f1 > d1;             // float > double -> int
	int cmp3 = c1 == i1;            // char == int -> int
	int cmp4 = ip == ip2;           // ptr == ptr -> int
	int cmp5 = ip != null1;         // ptr != ptr -> int

	printf("100 < -50: %d (expect 0)\n", cmp1);
	printf("3.5f > 3.5: %d (expect 0)\n", cmp2);
	printf("char(100) == int(100): %d (expect 1)\n", cmp3);
	printf("ip == ip2: %d (expect 1)\n", cmp4);
	printf("ip != null: %d (expect 1)\n", cmp5);

	// ========================================================================
	// LOGICAL OPERATORS (operands convert to bool-ish, result is int)
	// ========================================================================

	int log1 = i1 && i2;            // both non-zero -> 1
	int log2 = i1 || 0;             // first non-zero -> 1
	int log3 = !i1;                 // non-zero -> 0
	int log4 = !null1;              // null -> 1
	int log5 = ip && i1;            // ptr && int -> int

	printf("100 && -50: %d (expect 1)\n", log1);
	printf("100 || 0: %d (expect 1)\n", log2);
	printf("!100: %d (expect 0)\n", log3);
	printf("!null: %d (expect 1)\n", log4);
	printf("ptr && int: %d (expect 1)\n", log5);

	// ========================================================================
	// BITWISE OPERATORS
	// ========================================================================

	unsigned int bit1 = ui1 & ui2;      // uint & uint -> uint
	unsigned int bit2 = ui1 | ui2;      // uint | uint -> uint
	unsigned int bit3 = ui1 ^ ui2;      // uint ^ uint -> uint
	int bit4 = c1 & c2;                 // char & char -> int (promoted!)
	int bit5 = ~i1;                     // ~int -> int

	printf("100u & 200u: %u (expect 64)\n", bit1);
	printf("100u | 200u: %u (expect 236)\n", bit2);
	printf("100u ^ 200u: %u (expect 172)\n", bit3);
	printf("char & char: %d (expect 32)\n", bit4);
	printf("~100: %d (expect -101)\n", bit5);

	// Shifts: result type is promoted left operand
	int shift1 = c1 << 2;               // char promotes, shift, result int
	unsigned int shift2 = ui1 << 4;     // uint << int -> uint
	int shift3 = i1 >> 2;               // int >> int -> int

	printf("char(100) << 2: %d (expect 400)\n", shift1);
	printf("100u << 4: %u (expect 1600)\n", shift2);
	printf("100 >> 2: %d (expect 25)\n", shift3);

	// ========================================================================
	// SIZEOF (returns size_t, an unsigned type)
	// ========================================================================

	unsigned long sz1 = sizeof(char);
	unsigned long sz2 = sizeof(int);
	unsigned long sz3 = sizeof(long);
	unsigned long sz4 = sizeof(float);
	unsigned long sz5 = sizeof(double);
	unsigned long sz6 = sizeof(int*);
	unsigned long sz7 = sizeof(arr);        // full array size
	unsigned long sz8 = sizeof(arr) / sizeof(arr[0]);  // element count

	printf("sizeof(char): %lu (expect 1)\n", sz1);
	printf("sizeof(int): %lu (expect 4)\n", sz2);
	printf("sizeof(long): %lu (expect 8 on 64-bit)\n", sz3);
	printf("sizeof(float): %lu (expect 4)\n", sz4);
	printf("sizeof(double): %lu (expect 8)\n", sz5);
	printf("sizeof(int*): %lu (expect 8 on 64-bit)\n", sz6);
	printf("sizeof(arr): %lu (expect 12)\n", sz7);
	printf("array count: %lu (expect 3)\n", sz8);

	// ========================================================================
	// STRING LITERALS
	// ========================================================================

	char *str1 = "hello";               // string literal -> char*
	char str2[] = "world";              // string literal -> char array

	printf("string ptr: %s\n", str1);
	printf("string array: %s\n", str2);
	printf("str2 size: %lu (expect 6, includes null)\n", sizeof(str2));

	// ========================================================================
	// COMPOUND ASSIGNMENT (a op= b means a = a op b with conversions)
	// ========================================================================

	int comp1 = 100;
	comp1 += c1;                    // int += char -> int = int + int
	printf("int += char: %d (expect 200)\n", comp1);

	float comp2 = 10.0f;
	comp2 *= i1;                    // float *= int -> float = float * float
	printf("float *= int: %f (expect 1000.0)\n", comp2);

	unsigned int comp3 = 0xFF00u;
	comp3 |= uc1;                   // uint |= uchar -> uint
	printf("uint |= uchar: %u (expect 65480)\n", comp3);

	return 0;
}
#endif