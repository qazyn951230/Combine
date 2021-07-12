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

#ifndef REACTIVE_STREAM_ATOMICS_H
#define REACTIVE_STREAM_ATOMICS_H

#include <stdlib.h>
#include <stdbool.h>
#include <stdatomic.h>
#include "Config.h"

SA_C_FILE_BEGIN

/**
 * @see https://en.cppreference.com/w/c/atomic/memory_order
 */
typedef SA_CLOSED_ENUM(int, SAMemoryOrder) {
    SAMemoryOrderRelaxed = memory_order_relaxed,
    SAMemoryOrderConsume = memory_order_consume,
    SAMemoryOrderAcquire = memory_order_acquire,
    SAMemoryOrderRelease = memory_order_release,
    SAMemoryOrderAcquireAndRelease = memory_order_acq_rel,
    SAMemoryOrderSequentiallyConsistent = memory_order_seq_cst,
} SA_SWIFT_NAME(MemoryOrder);

#define SA_ATOMIC_TYPE_CREATE(swift_type, swift_name, raw_type, atomic_type)                                    \
typedef struct sa_atomic_##swift_name* SA##swift_type##Ref;                                                     \
static inline SA##swift_type##Ref sa_##swift_name##_create(raw_type value) {                                    \
    atomic_##atomic_type* result = (atomic_##atomic_type*)malloc(sizeof(atomic_##atomic_type));                 \
    atomic_init(result, value);                                                                                 \
    return SA_POINTER_CAST(SA##swift_type##Ref, result);                                                        \
}                                                                                                               \
static inline void sa_##swift_name##_init(SA##swift_type##Ref ref, raw_type value) {                            \
    atomic_##atomic_type* result = SA_POINTER_CAST(atomic_##atomic_type*, ref);                                 \
    atomic_init(result, value);                                                                                 \
}                                                                                                               \
static inline void sa_##swift_name##_free(SA##swift_type##Ref ref) {                                            \
    free(SA_POINTER_CAST(atomic_##atomic_type*, ref));                                                          \
}                                                                                                               \
static inline size_t sa_##swift_name##_required_size() {                                                        \
    return sizeof(atomic_##atomic_type);                                                                        \
}                                                                                                               \

#define SA_ATOMIC_TYPE_STORE(swift_type, swift_name, raw_type, atomic_type)                                     \
static inline void sa_##swift_name##_store(SA##swift_type##Ref ref, raw_type value) {                           \
    return atomic_store(SA_POINTER_CAST(atomic_##atomic_type*, ref), value);                                    \
}                                                                                                               \
static inline void sa_##swift_name##_store_explicit(SA##swift_type##Ref ref, raw_type value,                    \
                                                     SAMemoryOrder order) {                                     \
    return atomic_store_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), value, order);                    \
}                                                                                                               \

#define SA_ATOMIC_TYPE_LOAD(swift_type, swift_name, raw_type, atomic_type)                                      \
static inline raw_type sa_##swift_name##_load(SA##swift_type##Ref ref) {                                        \
    return atomic_load(SA_POINTER_CAST(atomic_##atomic_type*, ref));                                            \
}                                                                                                               \
static inline raw_type sa_##swift_name##_load_explicit(SA##swift_type##Ref ref,                                 \
                                                     SAMemoryOrder order) {                                     \
    return atomic_load_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), order);                            \
}                                                                                                               \

#define SA_ATOMIC_TYPE_EXCHANGE(swift_type, swift_name, raw_type, atomic_type)                                  \
static inline raw_type sa_##swift_name##_exchange(SA##swift_type##Ref ref, raw_type value) {                    \
    return atomic_exchange(SA_POINTER_CAST(atomic_##atomic_type*, ref), value);                                 \
}                                                                                                               \
static inline raw_type sa_##swift_name##_exchange_explicit(SA##swift_type##Ref ref, raw_type value,             \
                                                     SAMemoryOrder order) {                                     \
    return atomic_exchange_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), value, order);                 \
}                                                                                                               \

#define SA_ATOMIC_TYPE_COMPARE_STRONG(swift_type, swift_name, raw_type, atomic_type)                            \
static inline bool sa_##swift_name##_compare_strong(SA##swift_type##Ref ref, raw_type expected,                 \
                                               raw_type desired) {                                              \
    raw_type value = expected;                                                                                  \
    return atomic_compare_exchange_strong(SA_POINTER_CAST(atomic_##atomic_type*, ref), &value, desired);        \
}                                                                                                               \
static inline bool sa_##swift_name##_compare_strong_explicit(SA##swift_type##Ref ref,                           \
                   raw_type expected, raw_type desired, SAMemoryOrder success, SAMemoryOrder fail) {            \
    raw_type value = expected;                                                                                  \
    return atomic_compare_exchange_strong_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), &value,         \
                                                  desired, success, fail);                                      \
}                                                                                                               \

#define SA_ATOMIC_TYPE_COMPARE_WEAK(swift_type, swift_name, raw_type, atomic_type)                              \
static inline bool sa_##swift_name##_compare_weak(SA##swift_type##Ref ref, raw_type expected,                   \
                                               raw_type desired) {                                              \
    raw_type value = expected;                                                                                  \
    return atomic_compare_exchange_weak(SA_POINTER_CAST(atomic_##atomic_type*, ref), &value, desired);          \
}                                                                                                               \
static inline bool sa_##swift_name##_compare_weak_explicit(SA##swift_type##Ref ref,                             \
                   raw_type expected, raw_type desired, SAMemoryOrder success, SAMemoryOrder fail) {            \
    raw_type value = expected;                                                                                  \
    return atomic_compare_exchange_weak_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), &value,           \
                                                  desired, success, fail);                                      \
}                                                                                                               \

#define SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, action)                             \
static inline raw_type sa_##swift_name##_##action(SA##swift_type##Ref ref, raw_type value) {                    \
    return atomic_fetch_##action(SA_POINTER_CAST(atomic_##atomic_type*, ref), value);                           \
}                                                                                                               \
static inline raw_type sa_##swift_name##_##action##_explicit(SA##swift_type##Ref ref, raw_type value,           \
                                                     SAMemoryOrder order) {                                     \
    return atomic_fetch_##action##_explicit(SA_POINTER_CAST(atomic_##atomic_type*, ref), value, order);         \
}                                                                                                               \

#define SA_ATOMIC_TYPE_OPERATION(swift_type, swift_name, raw_type, atomic_type)                                 \
SA_ATOMIC_TYPE_STORE(swift_type, swift_name, raw_type, atomic_type)                                             \
SA_ATOMIC_TYPE_LOAD(swift_type, swift_name, raw_type, atomic_type)                                              \
SA_ATOMIC_TYPE_EXCHANGE(swift_type, swift_name, raw_type, atomic_type)                                          \
SA_ATOMIC_TYPE_COMPARE_STRONG(swift_type, swift_name, raw_type, atomic_type)                                    \
SA_ATOMIC_TYPE_COMPARE_WEAK(swift_type, swift_name, raw_type, atomic_type)                                      \
SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, add)                                        \
SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, sub)                                        \
SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, or)                                         \
SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, xor)                                        \
SA_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, and)                                        \

#define SA_MAKE_ATOMIC_TYPE(swift_type, swift_name, raw_type, atomic_type)                                      \
SA_ATOMIC_TYPE_CREATE(swift_type, swift_name, raw_type, atomic_type)                                            \
SA_ATOMIC_TYPE_OPERATION(swift_type, swift_name, raw_type, atomic_type)                                         \


// C11 => #define bool _Bool,
// after expanded from macro `atomic_bool` => `atomic__Bool`
SA_ATOMIC_TYPE_CREATE(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_STORE(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_LOAD(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_EXCHANGE(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_COMPARE_STRONG(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_COMPARE_WEAK(Bool, bool, bool, bool)
SA_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, add)
SA_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, sub)
SA_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, or)
SA_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, xor)
SA_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, and)

SA_MAKE_ATOMIC_TYPE(Int8, int8, signed char, schar)
SA_MAKE_ATOMIC_TYPE(UInt8, uint8, unsigned char, uchar)
SA_MAKE_ATOMIC_TYPE(Int16, int16, short, short)
SA_MAKE_ATOMIC_TYPE(UInt16, uint16, unsigned short, ushort)
SA_MAKE_ATOMIC_TYPE(Int32, int32, int, int)
SA_MAKE_ATOMIC_TYPE(UInt32, uint32, unsigned int, uint)
SA_MAKE_ATOMIC_TYPE(Int, int, long, long)
SA_MAKE_ATOMIC_TYPE(UInt, uint, unsigned long, ulong)
SA_MAKE_ATOMIC_TYPE(Int64, int64, long long, llong)
SA_MAKE_ATOMIC_TYPE(UInt64, uint64, unsigned long long, ullong)

#undef SA_ATOMIC_TYPE_CREATE
#undef SA_ATOMIC_TYPE_STORE
#undef SA_ATOMIC_TYPE_LOAD
#undef SA_ATOMIC_TYPE_EXCHANGE
#undef SA_ATOMIC_TYPE_COMPARE_STRONG
#undef SA_ATOMIC_TYPE_COMPARE_WEAK
#undef SA_ATOMIC_TYPE_FETCH
#undef SA_MAKE_ATOMIC_TYPE
#undef SA_ATOMIC_TYPE_OPERATION

SA_C_FILE_END

#endif // REACTIVE_STREAM_ATOMICS_H

// typedef struct sa_atomic_int* SAIntRef;
//
// static inline SAIntRef sa_int_create(long value) {
//     atomic_long* result = (atomic_long*) malloc(sizeof(atomic_long));
//     __c11_atomic_init(result, value);
//     return (reinterpret_cast<SAIntRef>(result));
// }
//
// static inline void sa_int_init(SAIntRef ref, long value) {
//     atomic_long* result = (reinterpret_cast<atomic_long*>(ref));
//     __c11_atomic_init(result, value);
// }
//
// static inline void sa_int_free(SAIntRef ref) {
//     free((reinterpret_cast<atomic_long*>(ref)));
// }
//
// static inline size_t sa_int_required_size() {
//     return sizeof(atomic_long);
// }
//
// static inline void sa_int_store(SAIntRef ref, long value) {
//     return __c11_atomic_store((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline void sa_int_store_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_store((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline long sa_int_load(SAIntRef ref) {
//     return __c11_atomic_load((reinterpret_cast<atomic_long*>(ref)), 5);
// }
//
// static inline long sa_int_load_explicit(SAIntRef ref, SAMemoryOrder order) {
//     return __c11_atomic_load((reinterpret_cast<atomic_long*>(ref)), order);
// }
//
// static inline long sa_int_exchange(SAIntRef ref, long value) {
//     return __c11_atomic_exchange((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_exchange_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_exchange((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline bool sa_int_compare_strong(SAIntRef ref, long expected, long desired) {
//     long value = expected;
//     return __c11_atomic_compare_exchange_strong((reinterpret_cast<atomic_long*>(ref)), &value, desired, 5, 5);
// }
//
// static inline bool sa_int_compare_strong_explicit(SAIntRef ref, long expected, long desired,
//     SAMemoryOrder success, SAMemoryOrder fail) {
//     long value = expected;
//     return __c11_atomic_compare_exchange_strong((reinterpret_cast<atomic_long*>(ref)), &value,
//        desired, success, fail);
// }
//
// static inline bool sa_int_compare_weak(SAIntRef ref, long expected, long desired) {
//     long value = expected;
//     return __c11_atomic_compare_exchange_weak((reinterpret_cast<atomic_long*>(ref)), &value, desired, 5, 5);
// }
//
// static inline bool sa_int_compare_weak_explicit(SAIntRef ref, long expected, long desired,
//     SAMemoryOrder success, SAMemoryOrder fail) {
//     long value = expected;
//     return __c11_atomic_compare_exchange_weak((reinterpret_cast<atomic_long*>(ref)), &value,
//         desired, success, fail);
// }
//
// static inline long sa_int_add(SAIntRef ref, long value) {
//     return __c11_atomic_fetch_add((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_add_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_fetch_add((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline long sa_int_sub(SAIntRef ref, long value) {
//     return __c11_atomic_fetch_sub((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_sub_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_fetch_sub((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline long sa_int_or(SAIntRef ref, long value) {
//     return __c11_atomic_fetch_or((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_or_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_fetch_or((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline long sa_int_xor(SAIntRef ref, long value) {
//     return __c11_atomic_fetch_xor((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_xor_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_fetch_xor((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
//
// static inline long sa_int_and(SAIntRef ref, long value) {
//     return __c11_atomic_fetch_and((reinterpret_cast<atomic_long*>(ref)), value, 5);
// }
//
// static inline long sa_int_and_explicit(SAIntRef ref, long value, SAMemoryOrder order) {
//     return __c11_atomic_fetch_and((reinterpret_cast<atomic_long*>(ref)), value, order);
// }
