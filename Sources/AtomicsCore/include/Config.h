// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef JIU_FOUNDATION_CONFIG_H
#define JIU_FOUNDATION_CONFIG_H

// ------------- FILE ------------------

#if (__cplusplus)
    #define SA_EXTERN_C_BEGIN   extern "C" {
    #define SA_EXTERN_C_END     }
    #ifdef SA_CPP_USE_NAMECHACE
        #define SA_CPP_FILE_BEGIN   namespace SA_CPP_NAMECHACE { \
                                    _Pragma("clang assume_nonnull begin")
        #define SA_CPP_FILE_END     _Pragma("clang assume_nonnull end") \
                                    }
    #else
        #define SA_CPP_FILE_BEGIN  _Pragma("clang assume_nonnull begin")
        #define SA_CPP_FILE_END    _Pragma("clang assume_nonnull end")
    #endif // #ifdef SA_CPP_USE_NAMECHACE
#else
    #define SA_EXTERN_C_BEGIN
    #define SA_EXTERN_C_END
    #define SA_CPP_FILE_BEGIN   _Pragma("clang assume_nonnull begin")
    #define SA_CPP_FILE_END     _Pragma("clang assume_nonnull end")
#endif // (__cplusplus)

#define SA_C_FILE_BEGIN SA_EXTERN_C_BEGIN \
                        _Pragma("clang assume_nonnull begin")
#define SA_C_FILE_END   _Pragma("clang assume_nonnull end") \
                        SA_EXTERN_C_END

// ------------- FILE ------------------

#if defined(__clang__) || defined(__GNUC__)
    #define SA_LIKELY(x)    __builtin_expect(!!(x), 1)
    #define SA_UNLIKELY(x)  __builtin_expect(!!(x), 0)
#else
    #define SA_LIKELY(x)    (x)
    #define SA_UNLIKELY(x)  (x)
#endif // defined(__clang__) || defined(__GNUC__)

// ------------- NULLABLE ------------------
// http://clang.llvm.org/docs/AttributeReference.html#nullability-attributes
// A nullable pointer to non-null pointers to const characters.
// const char *join_strings(const char * _Nonnull * _Nullable strings, unsigned n);
#if defined(__clang__)
    // int fetch(int * SA_NONNULL ptr);
    #define SA_NONNULL _Nonnull
    #define SA_NULL_UNCHECIFIED _Null_unspecified
    // int fetch_or_zero(int * SA_NULLABLE ptr);
    #define SA_NULLABLE _Nullable
#else
    #define SA_NONNULL
    #define SA_NULL_UNCHECIFIED
    #define SA_NULLABLE
#endif // defined(__clang__)
// ------------- NULLABLE ------------------

// ------------- NSInteger ------------------
// .../usr/include/objc/NSObjCRuntime.h
#if !__has_include(<NSObjCRuntime.h>)

    #if __LP64__ || 0 || NS_BUILD_32_LIKE_64
        typedef long NSInteger;
        typedef unsigned long NSUInteger;
    #else
        typedef int NSInteger;
        typedef unsigned int NSUInteger;
    #endif

#endif // !__has_include(<NSObjCRuntime.h>)
// ------------- NSInteger ------------------

// ------------- NSEnum ------------------
#if defined(CF_ENUM)
    #define SA_ENUM CF_ENUM
    #define SA_OPTIONS CF_OPTIONS
#else
    // .../CoreFoundation.framework/Headers/CFAvailability.h
    // Enums and Options
    #if __has_attribute(enum_extensibility)
        #define __SA_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
        #define __SA_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
        #define __SA_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
    #else
        #define __SA_ENUM_ATTRIBUTES
        #define __SA_CLOSED_ENUM_ATTRIBUTES
        #define __SA_OPTIONS_ATTRIBUTES
#endif

#define __SA_ENUM_GET_MACRO(_1, _2, NAME, ...) NAME
#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || \
    __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
    #define __SA_NAMED_ENUM(_type, _name)     enum __SA_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
    #define __SA_ANON_ENUM(_type)             enum __SA_ENUM_ATTRIBUTES : _type
    #define SA_CLOSED_ENUM(_type, _name)      enum __SA_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
    #if (__cplusplus)
        #define SA_OPTIONS(_type, _name) _type _name; enum __SA_OPTIONS_ATTRIBUTES : _type
    #else
        #define SA_OPTIONS(_type, _name) enum __SA_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type
    #endif
#else
    #define __SA_NAMED_ENUM(_type, _name) _type _name; enum
    #define __SA_ANON_ENUM(_type) enum
    #define SA_CLOSED_ENUM(_type, _name) _type _name; enum
    #define SA_OPTIONS(_type, _name) _type _name; enum
#endif

/* SA_ENUM supports the use of one or two arguments.
 * The first argument is always the integer type used for the values of the enum.
 * The second argument is an optional type name for the macro.
 * When specifying a type name, you must precede the macro with 'typedef' like so:
typedef SA_ENUM(CFIndex, CFComparisonResult) {
    ...
};
If you do not specify a type name, do not use 'typdef', like so:
SA_ENUM(CFIndex) {
    ...
};
*/

#define SA_ENUM(...) __SA_ENUM_GET_MACRO(__VA_ARGS__, __SA_NAMED_ENUM, __SA_ANON_ENUM, )(__VA_ARGS__)
#endif
// ------------- NSEnum ------------------

// ------------- NS_SWIFT_NAME ------------------
#if defined(CF_SWIFT_NAME)
    #define SA_SWIFT_NAME CF_SWIFT_NAME
#else
    // CoreFoundation.framework/Headers/CFBase.h
    #if __has_attribute(swift_name)
        #define SA_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
    #else
        #define SA_SWIFT_NAME(_name)
    #endif
#endif
// ------------- NS_SWIFT_NAME ------------------

// ------------- NS_NOESCAPE ------------------
#ifdef NS_NOESCAPE
    #define SA_NOESCAPE NS_NOESCAPE
#else
    #if __has_attribute(noescape)
        #define SA_NOESCAPE __attribute__((noescape))
    #else
        #define SA_NOESCAPE
    #endif
#endif
// ------------- NS_NOESCAPE ------------------

// ------------- CAST ------------------
#ifndef SA_OPAQUE_POINTER
    #define SA_OPAQUE_POINTER(x) typedef struct x##_t* x##_p
#endif // SA_OPAQUE_POINTER

#if (__cplusplus)

#define SA_SIMPLE_CONVERSION(CxxType, CRef)                     \
inline CxxType *unwrap(CRef value) {                            \
    return reinterpret_cast<CxxType*>(value);                   \
}                                                               \
                                                                \
inline CRef wrap(const CxxType* value) {                        \
    return reinterpret_cast<CRef>(const_cast<CxxType*>(value)); \
}                                                               \

#define SA_STATIC_CONVERSION(TARGET, SOURCE)                    \
inline TARGET unwrap(const SOURCE& value) {                     \
    return static_cast<TARGET>(value);                          \
}                                                               \
                                                                \
inline SOURCE wrap(const TARGET& value) {                       \
    return static_cast<SOURCE>(value);                          \
}                                                               \

#define SA_CLASS_CONVERSION(TARGET, SOURCE)                                                     \
inline const TARGET& unwrap(const SOURCE& value) {                                              \
    return *const_cast<const TARGET*>(reinterpret_cast<TARGET*>(const_cast<SOURCE*>(&value)));  \
}                                                                                               \
                                                                                                \
inline TARGET& unwrap(SOURCE& value) {                                                          \
    return *reinterpret_cast<TARGET*>(&value);                                                  \
}                                                                                               \
                                                                                                \
inline const SOURCE& wrap(const TARGET& value) {                                                \
    return *const_cast<const SOURCE*>(reinterpret_cast<SOURCE*>(const_cast<TARGET*>(&value)));  \
}                                                                                               \
                                                                                                \
inline SOURCE& wrap(TARGET& value) {                                                            \
    return *reinterpret_cast<SOURCE*>(&value);                                                  \
}                                                                                               \

#define SA_POINTER_CAST(type, source) (reinterpret_cast<type>(source))

#else // (__cplusplus)

#define SA_SIMPLE_CONVERSION(CxxType, CRef)                     \
inline CxxType *unwrap(CRef value) {                            \
    return (CxxType*)(value);                                   \
}                                                               \
                                                                \
inline CRef wrap(const CxxType* value) {                        \
    return (CRef)(const_cast<CxxType*>(value));                 \
}                                                               \

#define SA_STATIC_CONVERSION(TARGET, SOURCE)                    \
inline TARGET unwrap(const SOURCE& value) {                     \
    return (TARGET)(value);                                     \
}                                                               \
                                                                \
inline SOURCE wrap(const TARGET& value) {                       \
    return (SOURCE)(value);                                     \
}                                                               \

#define SA_POINTER_CAST(type, source) ((type)(source))

#endif // (__cplusplus)

// ------------- CAST ------------------

#endif // JIU_FOUNDATION_CONFIG_H
