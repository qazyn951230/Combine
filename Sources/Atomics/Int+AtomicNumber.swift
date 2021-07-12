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

import AtomicsCore

extension Int: AtomicNumber {
    public typealias AtomicReference = SAIntRef

    @inline(__always)
    public static func atomic_required_size() -> Int {
        sa_int_required_size()
    }

    @inline(__always)
    public static func atomic_create(_ ref: SAIntRef, value: Int) {
        sa_int_init(ref, value)
    }

    @inline(__always)
    public static func atomic_free(_ ref: SAIntRef) {
        sa_int_free(ref)
    }

    @inline(__always)
    public static func atomic_store(_ ref: SAIntRef, value: Int) {
        sa_int_store(ref, value)
    }

    @inline(__always)
    public static func atomic_load(_ ref: SAIntRef) -> Int {
        sa_int_load(ref)
    }

    @inline(__always)
    public static func atomic_exchange(_ ref: SAIntRef, desired: Int) {
        sa_int_exchange(ref, desired)
    }

    @inline(__always)
    public static func atomic_compare(_ ref: SAIntRef, expected: Int, desired: Int) -> Bool {
        sa_int_compare_strong(ref, expected, desired)
    }

    @inline(__always)
    public static func atomic_add(_ ref: SAIntRef, value: Int) -> Int {
        sa_int_add_explicit(ref, value, .relaxed)
    }

    @inline(__always)
    public static func atomic_sub(_ ref: SAIntRef, value: Int) -> Int {
        sa_int_sub_explicit(ref, value, .relaxed)
    }

    @inline(__always)
    public static func atomic_or(_ ref: SAIntRef, value: Int) -> Int {
        sa_int_or_explicit(ref, value, .relaxed)
    }

    @inline(__always)
    public static func atomic_xor(_ ref: SAIntRef, value: Int) -> Int {
        sa_int_xor_explicit(ref, value, .relaxed)
    }

    @inline(__always)
    public static func atomic_and(_ ref: SAIntRef, value: Int) -> Int {
        sa_int_and_explicit(ref, value, .relaxed)
    }
}
