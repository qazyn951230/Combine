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

/// A protocol that declares a type that can receive input from a publisher.
/// - seealso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/subscriber)
public protocol Subscriber: CustomCombineIdentifierConvertible {
    /// The kind of values this subscriber receives.
    associatedtype Input
    /// The kind of errors this subscriber might receive.
    ///
    /// Use `Never` if this `Subscriber` cannot receive errors.
    associatedtype Failure: Error

    // MARK: - Receiving Elements

    /// Tells the subscriber that the publisher has produced an element.
    /// - Parameters:
    ///   - input: The published element.
    /// - Returns: A Demand instance indicating how many more elements
    ///     the subcriber expects to receive.
    func receive(_ input: Input) -> Subscribers.Demand

    // MARK: - Receiving Life Cycle Events

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    func receive(subscription: Subscription)

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    func receive(completion: Subscribers.Completion<Failure>)
}

internal extension Subscriber {
    @inline(__always)
    func receiveFinished() {
        receive(completion: Subscribers.Completion.finished)
    }

    @inline(__always)
    func receive(failure: Failure) {
        receive(completion: Subscribers.Completion.failure(failure))
    }
}
