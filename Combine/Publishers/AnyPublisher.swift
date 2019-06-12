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

/// A type-erasing publisher.
/// - SeeAlso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/anypublisher)
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to
///     expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure> where Failure: Error {
    // https://github.com/apple/swift-evolution/blob/master/proposals/0193-cross-module-inlining-and-specialization.md
    @usableFromInline
    let receiveSubscriber: (AnySubscriber<Output, Failure>) -> Void

    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    @inlinable
    public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P: Publisher {
        receiveSubscriber = { s in
            publisher.receive(subscriber: s)
        }
    }

    /// Creates a type-erasing publisher implemented by the provided closure.
    ///
    /// - Parameters:
    ///   - subscribe: A closure to invoke when a subscriber subscribes to the publisher.
    @inlinable
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        receiveSubscriber = subscribe
    }
}

extension AnyPublisher : Publisher {
    @inlinable
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        receiveSubscriber(AnySubscriber(subscriber))
    }
}
