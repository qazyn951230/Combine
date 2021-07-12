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

public protocol AtomicNumber {
    associatedtype AtomicReference

    static func atomic_required_size() -> Int
    static func atomic_create(_ ref: AtomicReference, value: Self)
    static func atomic_free(_ ref: AtomicReference)
    static func atomic_store(_ ref: AtomicReference, value: Self)
    static func atomic_load(_ ref: AtomicReference) -> Self
    static func atomic_exchange(_ ref: AtomicReference, desired: Self)
    static func atomic_compare(_ ref: AtomicReference, expected: Self, desired: Self) -> Bool
    static func atomic_add(_ ref: AtomicReference, value: Self) -> Self
    static func atomic_sub(_ ref: AtomicReference, value: Self) -> Self
    static func atomic_or(_ ref: AtomicReference, value: Self) -> Self
    static func atomic_xor(_ ref: AtomicReference, value: Self) -> Self
    static func atomic_and(_ ref: AtomicReference, value: Self) -> Self
}

public final class Atomic<Number> where Number: AtomicNumber {
    @usableFromInline
    typealias Manager = ManagedBufferPointer<Void, UInt8>

    @inlinable
    public static func make(_ value: Number) -> Atomic<Number> {
        let manager = Manager(bufferClass: self, minimumCapacity: Number.atomic_required_size()) { _, _ in }
        manager.withUnsafeMutablePointerToElements {
            let ref = unsafeBitCast($0, to: Number.AtomicReference.self)
            Number.atomic_create(ref, value: value)
        }
        return manager.buffer as! Atomic<Number>
    }

    deinit {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointers { header, elements in
            header.deinitialize(count: 1)
            elements.deinitialize(count: Number.atomic_required_size())
        }
    }

    @inlinable
    public func store(_ value: Number) {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer -> Void in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_store(ref, value: value)
        }
    }

    @inlinable
    public func load() -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_load(ref)
        }
    }

    @inlinable
    public func exchange(desired: Number) {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            Number.atomic_exchange(ref, desired: desired)
        }
    }

    @inlinable
    public func compare(expected: Number, desired: Number) -> Bool {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_compare(ref, expected: expected, desired: desired)
        }
    }

    @inlinable
    @discardableResult
    public func add(_ value: Number) -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_add(ref, value: value)
        }
    }

    @inlinable
    @discardableResult
    public func sub(_ value: Number) -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_sub(ref, value: value)
        }
    }

    @inlinable
    @discardableResult
    public func or(_ value: Number) -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_or(ref, value: value)
        }
    }

    @inlinable
    @discardableResult
    public func xor(_ value: Number) -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_xor(ref, value: value)
        }
    }

    @inlinable
    @discardableResult
    public func and(_ value: Number) -> Number {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: Number.AtomicReference.self)
            return Number.atomic_and(ref, value: value)
        }
    }
}
