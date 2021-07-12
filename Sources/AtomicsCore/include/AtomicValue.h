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

#ifndef REACTIVE_STREAM_ATOMIC_VALUE_H
#define REACTIVE_STREAM_ATOMIC_VALUE_H

#include <stdatomic.h>
#include <stdlib.h>
#include "Atomics.h"

SA_C_FILE_BEGIN

typedef atomic_uintptr_t _AtomicValue;
typedef struct AtomicValue* AtomicRef;

static inline AtomicRef sa_ref_create(void* value) {
    _AtomicValue* result = (_AtomicValue*)malloc(sizeof(_AtomicValue));
    atomic_init(result, (uintptr_t)value);
    return SA_POINTER_CAST(AtomicRef, result);
}

static inline void sa_ref_init(AtomicRef ref, void* value) {
    _AtomicValue* result = SA_POINTER_CAST(_AtomicValue*, ref);
    atomic_init(result, (uintptr_t)value);
}

static inline void sa_ref_free(AtomicRef ref) {
    free(SA_POINTER_CAST(_AtomicValue*, ref));
}

static inline size_t sa_ref_required_size() {
    return sizeof(_AtomicValue);
}

static inline void sa_ref_store_explicit(AtomicRef ref, void* value, SAMemoryOrder order) {
    return atomic_store_explicit(SA_POINTER_CAST(_AtomicValue*, ref), (uintptr_t)value, order);
}

static inline void* sa_ref_load(AtomicRef ref) {
    return (void*)atomic_load(SA_POINTER_CAST(_AtomicValue*, ref));
}

static inline void* sa_ref_load_explicit(AtomicRef ref, SAMemoryOrder order) {
    return (void*)atomic_load_explicit(SA_POINTER_CAST(_AtomicValue*, ref), order);
}

static inline void* sa_ref_exchange(AtomicRef ref, void* value) {
    return (void*)atomic_exchange(SA_POINTER_CAST(_AtomicValue*, ref), (uintptr_t)value);
}

static inline void* sa_ref_exchange_explicit(AtomicRef ref, void* value, SAMemoryOrder order) {
    return (void*)atomic_exchange_explicit(SA_POINTER_CAST(_AtomicValue*, ref), (uintptr_t)value, order);
}

static inline bool sa_ref_compare_strong(AtomicRef ref, void* expected, void* desired) {
    uintptr_t value = (uintptr_t)expected;
    return atomic_compare_exchange_strong(SA_POINTER_CAST(_AtomicValue*, ref), &value, (uintptr_t)desired);
}

static inline bool sa_ref_compare_strong_explicit(AtomicRef ref, void* expected, void* desired,
    SAMemoryOrder success, SAMemoryOrder fail) {
    uintptr_t value = (uintptr_t)expected;
    return atomic_compare_exchange_strong_explicit(SA_POINTER_CAST(_AtomicValue*, ref), &value,
        (uintptr_t)desired, success, fail);
}

static inline bool sa_ref_compare_weak(AtomicRef ref, void* expected, void* desired) {
    uintptr_t value = (uintptr_t)expected;
    return atomic_compare_exchange_weak(SA_POINTER_CAST(_AtomicValue*, ref), &value, (uintptr_t)desired);
}

static inline bool sa_ref_compare_weak_explicit(AtomicRef ref, void* expected, void* desired,
    SAMemoryOrder success, SAMemoryOrder fail) {
    uintptr_t value = (uintptr_t)expected;
    return atomic_compare_exchange_weak_explicit(SA_POINTER_CAST(_AtomicValue*, ref), &value,
        (uintptr_t)desired, success, fail);
}

SA_C_FILE_END

#endif // REACTIVE_STREAM_ATOMIC_VALUE_H
