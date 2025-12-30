/*
 * System Header Pattern Tests
 * Patterns commonly found in macOS/iOS SDK headers
 */

/* ============================================================================
 * SECTION 1: __has_* FEATURE CHECKS
 * ============================================================================ */

// Pattern: Define fallback if not supported
#ifndef __has_feature
    #define __has_feature(x) 0
#endif

#ifndef __has_extension
    #define __has_extension(x) __has_feature(x)
#endif

#ifndef __has_attribute
    #define __has_attribute(x) 0
#endif

#ifndef __has_builtin
    #define __has_builtin(x) 0
#endif

#ifndef __has_include
    #define __has_include(x) 0
#endif

#ifndef __has_include_next
    #define __has_include_next(x) 0
#endif

// Usage patterns
#if __has_feature(objc_arc)
    #define ARC_ENABLED 1
#endif

#if __has_attribute(always_inline)
    #define FORCE_INLINE __attribute__((always_inline)) inline
#else
    #define FORCE_INLINE inline
#endif

#if __has_builtin(__builtin_expect)
    #define LIKELY(x)   __builtin_expect(!!(x), 1)
    #define UNLIKELY(x) __builtin_expect(!!(x), 0)
#else
    #define LIKELY(x)   (x)
    #define UNLIKELY(x) (x)
#endif

#if __has_include(<optional>)
    #define HAS_OPTIONAL 1
#endif


/* ============================================================================
 * SECTION 2: AVAILABILITY MACROS (Simplified)
 * ============================================================================ */

// Basic availability attribute pattern
#define __API_AVAILABLE_PLATFORM_macos(x) macos,introduced=x
#define __API_AVAILABLE_PLATFORM_ios(x) ios,introduced=x
#define __API_AVAILABLE_PLATFORM_tvos(x) tvos,introduced=x
#define __API_AVAILABLE_PLATFORM_watchos(x) watchos,introduced=x

// The complex part: variadic with argument processing
// This is a simplified version of what Apple's headers do

// Helper to count arguments
#define __API_AVAILABLE_ARG_COUNT_IMPL(_1, _2, _3, _4, _5, N, ...) N
#define __API_AVAILABLE_ARG_COUNT(...) __API_AVAILABLE_ARG_COUNT_IMPL(__VA_ARGS__, 5, 4, 3, 2, 1)

// Dispatcher based on argument count
#define __API_AVAILABLE_1(a) __attribute__((availability(a)))
#define __API_AVAILABLE_2(a, b) __attribute__((availability(a), availability(b)))
#define __API_AVAILABLE_3(a, b, c) __attribute__((availability(a), availability(b), availability(c)))

// Main macro (simplified)
#define __API_AVAILABLE_IMPL2(n) __API_AVAILABLE_ ## n
#define __API_AVAILABLE_IMPL(n) __API_AVAILABLE_IMPL2(n)
#define API_AVAILABLE(...) __API_AVAILABLE_IMPL(__API_AVAILABLE_ARG_COUNT(__VA_ARGS__))(__VA_ARGS__)

// Example usage:
// void func(void) API_AVAILABLE(macos(10.15), ios(13.0));


/* ============================================================================
 * SECTION 3: PLATFORM DETECTION PATTERNS
 * ============================================================================ */

// Target OS detection
#if defined(__APPLE__)
    #include <TargetConditionals.h>
    
    // After including TargetConditionals.h, these are defined:
    // TARGET_OS_MAC, TARGET_OS_IPHONE, TARGET_OS_IOS, etc.
    
    #ifndef TARGET_OS_MAC
        #define TARGET_OS_MAC 0
    #endif
    #ifndef TARGET_OS_IPHONE
        #define TARGET_OS_IPHONE 0
    #endif
    #ifndef TARGET_OS_IOS
        #define TARGET_OS_IOS 0
    #endif
    #ifndef TARGET_OS_SIMULATOR
        #define TARGET_OS_SIMULATOR 0
    #endif
#endif

// Architecture detection
#if defined(__x86_64__) || defined(_M_X64)
    #define ARCH_X86_64 1
#elif defined(__i386__) || defined(_M_IX86)
    #define ARCH_X86 1
#elif defined(__aarch64__) || defined(_M_ARM64)
    #define ARCH_ARM64 1
#elif defined(__arm__) || defined(_M_ARM)
    #define ARCH_ARM 1
#endif


/* ============================================================================
 * SECTION 4: SWIFT BRIDGING PATTERNS
 * ============================================================================ */

#if defined(__cplusplus)
    #define SWIFT_EXTERN extern "C"
#else
    #define SWIFT_EXTERN extern
#endif

#if __has_attribute(swift_name)
    #define SWIFT_NAME(name) __attribute__((swift_name(name)))
#else
    #define SWIFT_NAME(name)
#endif

#if __has_attribute(swift_async_name)
    #define SWIFT_ASYNC_NAME(name) __attribute__((swift_async_name(name)))
#else
    #define SWIFT_ASYNC_NAME(name)
#endif

// Example:
// SWIFT_EXTERN void doSomething(int x) SWIFT_NAME("doSomething(x:)");


/* ============================================================================
 * SECTION 5: NULLABILITY PATTERNS
 * ============================================================================ */

#if __has_feature(nullability)
    #define NULLABLE _Nullable
    #define NONNULL _Nonnull
    #define NULL_UNSPECIFIED _Null_unspecified
#else
    #define NULLABLE
    #define NONNULL
    #define NULL_UNSPECIFIED
#endif

// Audited regions
#ifdef __clang__
    #define NS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
    #define NS_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")
#else
    #define NS_ASSUME_NONNULL_BEGIN
    #define NS_ASSUME_NONNULL_END
#endif


/* ============================================================================
 * SECTION 6: DEPRECATION PATTERNS
 * ============================================================================ */

#if __has_attribute(deprecated)
    #define DEPRECATED __attribute__((deprecated))
    #define DEPRECATED_MSG(msg) __attribute__((deprecated(msg)))
#else
    #define DEPRECATED
    #define DEPRECATED_MSG(msg)
#endif

#if __has_attribute(availability)
    #define UNAVAILABLE __attribute__((unavailable))
    #define UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#else
    #define UNAVAILABLE
    #define UNAVAILABLE_MSG(msg)
#endif

// Platform-specific deprecation
#define API_DEPRECATED(msg, ...) __attribute__((deprecated(msg)))
#define API_DEPRECATED_WITH_REPLACEMENT(replacement, ...) \
    __attribute__((deprecated("Use " #replacement " instead")))


/* ============================================================================
 * SECTION 7: ENUM PATTERNS
 * ============================================================================ */

// NS_ENUM / NS_OPTIONS pattern
#if __has_attribute(enum_extensibility)
    #define __ENUM_ATTR_OPEN __attribute__((enum_extensibility(open)))
    #define __ENUM_ATTR_CLOSED __attribute__((enum_extensibility(closed)))
#else
    #define __ENUM_ATTR_OPEN
    #define __ENUM_ATTR_CLOSED
#endif

#if __has_feature(objc_fixed_enum) || __has_extension(cxx_strong_enums)
    #define NS_ENUM(_type, _name) \
        enum _name : _type _name; \
        enum _name : _type
    #define NS_OPTIONS(_type, _name) \
        enum _name : _type _name; \
        enum _name : _type
#else
    #define NS_ENUM(_type, _name) \
        _type _name; \
        enum
    #define NS_OPTIONS(_type, _name) \
        _type _name; \
        enum
#endif

// Usage:
// typedef NS_ENUM(int, MyEnum) {
//     MyEnumValue1,
//     MyEnumValue2
// };


/* ============================================================================
 * SECTION 8: EXPORT/VISIBILITY PATTERNS
 * ============================================================================ */

#if defined(_WIN32)
    #define EXPORT __declspec(dllexport)
    #define IMPORT __declspec(dllimport)
    #define HIDDEN
#elif __has_attribute(visibility)
    #define EXPORT __attribute__((visibility("default")))
    #define IMPORT __attribute__((visibility("default")))
    #define HIDDEN __attribute__((visibility("hidden")))
#else
    #define EXPORT
    #define IMPORT
    #define HIDDEN
#endif

#ifdef BUILDING_LIBRARY
    #define PUBLIC_API EXPORT
#else
    #define PUBLIC_API IMPORT
#endif


/* ============================================================================
 * SECTION 9: COMPLEX VARIADIC PATTERNS
 * ============================================================================ */

// Pattern for dispatching based on argument count
#define PP_NARG(...) PP_NARG_IMPL(__VA_ARGS__, PP_RSEQ_N())
#define PP_NARG_IMPL(...) PP_ARG_N(__VA_ARGS__)
#define PP_ARG_N( \
    _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, \
    _11, _12, _13, _14, _15, _16, N, ...) N
#define PP_RSEQ_N() \
    16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

// Concatenation with expansion
#define PP_CAT(a, b) PP_CAT_IMPL(a, b)
#define PP_CAT_IMPL(a, b) a ## b

// Dispatch to numbered macro
#define DISPATCH(name, ...) PP_CAT(name, PP_NARG(__VA_ARGS__))(__VA_ARGS__)

// Example: OVERLOADED macro
#define OVERLOADED_1(a) one_arg(a)
#define OVERLOADED_2(a, b) two_args(a, b)
#define OVERLOADED_3(a, b, c) three_args(a, b, c)
#define OVERLOADED(...) DISPATCH(OVERLOADED_, __VA_ARGS__)

// Usage:
// OVERLOADED(x)        -> one_arg(x)
// OVERLOADED(x, y)     -> two_args(x, y)
// OVERLOADED(x, y, z)  -> three_args(x, y, z)


/* ============================================================================
 * SECTION 10: MACRO FOREACH PATTERNS
 * ============================================================================ */

// Simple FOREACH (limited count)
#define FE_0(action, x)
#define FE_1(action, x) action(x)
#define FE_2(action, x, ...) action(x) FE_1(action, __VA_ARGS__)
#define FE_3(action, x, ...) action(x) FE_2(action, __VA_ARGS__)
#define FE_4(action, x, ...) action(x) FE_3(action, __VA_ARGS__)
#define FE_5(action, x, ...) action(x) FE_4(action, __VA_ARGS__)

#define GET_FE_IMPL(_1, _2, _3, _4, _5, NAME, ...) NAME
#define FOREACH(action, ...) \
    GET_FE_IMPL(__VA_ARGS__, FE_5, FE_4, FE_3, FE_2, FE_1, FE_0)(action, __VA_ARGS__)

// Usage:
// #define PRINT(x) printf("%s = %d\n", #x, x);
// FOREACH(PRINT, a, b, c)


/* ============================================================================
 * SECTION 11: DEFER/OBSTRUCT PATTERNS (Advanced)
 * ============================================================================ */

// These patterns are used for complex macro metaprogramming

#define EMPTY()
#define DEFER(id) id EMPTY()
#define OBSTRUCT(...) __VA_ARGS__ DEFER(EMPTY)()

#define EXPAND(...) __VA_ARGS__
#define EXPAND1(...) EXPAND(__VA_ARGS__)
#define EXPAND2(...) EXPAND1(EXPAND1(__VA_ARGS__))
#define EXPAND3(...) EXPAND2(EXPAND2(__VA_ARGS__))
#define EXPAND4(...) EXPAND3(EXPAND3(__VA_ARGS__))

// Recursive macro simulation
#define REPEAT_INDIRECT() REPEAT
#define REPEAT(count, macro, ...) \
    macro(__VA_ARGS__) \
    /* Would need more infrastructure for true recursion */


/* ============================================================================
 * SECTION 12: REAL APPLE HEADER APPROXIMATIONS
 * ============================================================================ */

// Approximation of __API_AVAILABLE implementation
#define __API_AVAILABLE_GET_MACRO(_1, _2, _3, _4, _5, _6, _7, _8, NAME, ...) NAME

#define __API_AVAILABLE_IMPL_1(x) __attribute__((availability x))
#define __API_AVAILABLE_IMPL_2(x, y) \
    __attribute__((availability x, availability y))
#define __API_AVAILABLE_IMPL_3(x, y, z) \
    __attribute__((availability x, availability y, availability z))
#define __API_AVAILABLE_IMPL_4(a, b, c, d) \
    __attribute__((availability a, availability b, availability c, availability d))

#define __API_AVAILABLE2(...) \
    __API_AVAILABLE_GET_MACRO(__VA_ARGS__, \
        __API_AVAILABLE_IMPL_4, unused, \
        __API_AVAILABLE_IMPL_3, unused, \
        __API_AVAILABLE_IMPL_2, unused, \
        __API_AVAILABLE_IMPL_1, unused)(__VA_ARGS__)

// Usage:
// void f(void) __API_AVAILABLE2((macos,introduced=10.15));
// void g(void) __API_AVAILABLE2((macos,introduced=10.15), (ios,introduced=13.0));


/* ============================================================================
 * VERIFICATION
 * ============================================================================ */

// Test that key patterns work
#if defined(LIKELY)
    int likely_defined = 1;
#endif

#if defined(FORCE_INLINE)
    int force_inline_defined = 1;
#endif

#if defined(PP_NARG)
    // Test argument counting
    #if PP_NARG(a) == 1
        int narg_1_ok = 1;
    #endif
    #if PP_NARG(a, b, c) == 3
        int narg_3_ok = 1;
    #endif
#endif

int main(void) {
    return 0;
}
