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

/// A type-erasing subject.
/// - SeeAlso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/anysubject)
///
/// Use AnySubject to wrap a subject whose type has details you don’t want to
///     expose to subscribers or other publishers.
public final class AnySubject<Output, Failure>: Subject where Failure: Error {
    private let subscribe: (AnySubscriber<Output, Failure>) -> Void
    private let receive: (Output) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S: Subject {
        subscribe = { i in
            subject.receive(subscriber: i)
        }
        receive = { i in
            subject.send(i)
        }
        receiveCompletion = { i in
            subject.send(completion: i)
        }
    }

    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void,
                _ receive: @escaping (Output) -> Void,
                _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.subscribe = subscribe
        self.receive = receive
        self.receiveCompletion = receiveCompletion
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscribe(AnySubscriber(subscriber))
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public func send(_ value: Output) {
        receive(value)
    }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether
    ///         publishing has finished normally or failed with an error.
    public func send(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
    }
}
