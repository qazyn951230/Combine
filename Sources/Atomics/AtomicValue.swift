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

public final class AtomicValue<T> where T: AnyObject {
    @usableFromInline
    typealias Manager = ManagedBufferPointer<Void, UInt8>

    private init() {
        // Do nothing.
    }

    @inlinable
    public static func make(_ value: __owned T) -> AtomicValue<T> {
        let manager = Manager(bufferClass: self, minimumCapacity: sa_ref_required_size()) { _, _ in
        }
        manager.withUnsafeMutablePointerToElements {
            let ref = unsafeBitCast($0, to: AtomicRef.self)
            sa_ref_init(ref, Unmanaged.passRetained(value).toOpaque())
        }
        return manager.buffer as! AtomicValue<T>
    }

    deinit {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointers { header, elements in
//            let ref = unsafeBitCast(elements, to: AtomicRef.self)
//            Unmanaged<T>.fromOpaque(sa_ref_load_explicit(ref, .relaxed))
//                .release()
            header.deinitialize(count: 1)
            elements.deinitialize(count: sa_ref_required_size())
        }
    }

    @inlinable
    @discardableResult
    public func store(_ value: __owned T) -> T {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer -> T in
            let ref = unsafeBitCast(pointer, to: AtomicRef.self)
            let old = Unmanaged<T>.fromOpaque(sa_ref_load_explicit(ref, .relaxed))
                .takeRetainedValue()
            sa_ref_store_explicit(ref, Unmanaged.passRetained(value).toOpaque(), .relaxed)
            return old
        }
    }

    @inlinable
    public func load() -> T {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: AtomicRef.self)
            return Unmanaged<T>.fromOpaque(sa_ref_load_explicit(ref, .relaxed))
                .takeRetainedValue()
        }
    }

    @inlinable
    public func exchange(desired: T) -> T {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer -> T in
            let ref = unsafeBitCast(pointer, to: AtomicRef.self)
            let new = Unmanaged<T>.passRetained(desired)
                .toOpaque()
            let old = sa_ref_exchange_explicit(ref, new, .relaxed)
            return Unmanaged<T>.fromOpaque(old)
                .takeRetainedValue()
        }
    }

    @inlinable
    public func compare(expected: T, desired: T) -> Bool {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: AtomicRef.self)
            let _expected = Unmanaged<T>.passRetained(expected)
                .toOpaque()
            let _desired = Unmanaged<T>.passRetained(desired)
                .toOpaque()
            return sa_ref_compare_strong_explicit(ref, _expected, _desired, .relaxed, .relaxed)
        }
    }

    @inlinable
    public func weakCompare(expected: T, desired: T) -> Bool {
        Manager(unsafeBufferObject: self).withUnsafeMutablePointerToElements { pointer in
            let ref = unsafeBitCast(pointer, to: AtomicRef.self)
            let _expected = Unmanaged<T>.passRetained(expected)
                .toOpaque()
            let _desired = Unmanaged<T>.passRetained(desired)
                .toOpaque()
            return sa_ref_compare_weak_explicit(ref, _expected, _desired, .relaxed, .relaxed)
        }
    }
}
