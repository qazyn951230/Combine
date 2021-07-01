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

/// Declares that a type can transmit a sequence of values over time.
///
/// A publisher delivers elements to one or more ``Subscriber`` instances.
/// The subscriber’s ``Subscriber/Input`` and ``Subscriber/Failure`` associated types must match the ``Publisher/Output`` and ``Publisher/Failure`` types declared by the publisher.
/// The publisher implements the ``Publisher/receive(subscriber:)``method to accept a subscriber.
///
/// After this, the publisher can call the following methods on the subscriber:
/// - ``Subscriber/receive(subscription:)``: Acknowledges the subscribe request and returns a ``Subscription`` instance. The subscriber uses the subscription to demand elements from the publisher and can use it to cancel publishing.
/// - ``Subscriber/receive(_:)``: Delivers one element from the publisher to the subscriber.
/// - ``Subscriber/receive(completion:)``: Informs the subscriber that publishing has ended, either normally or with an error.
///
/// Every ``Publisher`` must adhere to this contract for downstream subscribers to function correctly.
///
/// Extensions on ``Publisher`` define a wide variety of _operators_ that you compose to create sophisticated event-processing chains.
/// Each operator returns a type that implements the ``Publisher`` protocol
/// Most of these types exist as extensions on the ``Publishers`` enumeration.
/// For example, the ``Publisher/map(_:)-99evh`` operator returns an instance of ``Publishers/Map``.
///
/// # Creating Your Own Publishers
///
/// Rather than implementing the ``Publisher`` protocol yourself, you can create your own publisher by using one of several types provided by the Combine framework:
///
/// - Use a concrete subclass of ``Subject``, such as ``PassthroughSubject``, to publish values on-demand by calling its ``Subject/send(_:)`` method.
/// - Use a ``CurrentValueSubject`` to publish whenever you update the subject’s underlying value.
/// - Add the `@Published` annotation to a property of one of your own types. In doing so, the property gains a publisher that emits an event whenever the property’s value changes. See the ``Published`` type for an example of this approach.
public protocol Publisher {

    /// The kind of values published by this publisher.
    associatedtype Output

    /// The kind of errors this publisher might publish.
    ///
    /// Use `Never` if this `Publisher` does not publish errors.
    associatedtype Failure: Error

    /// Attaches the specified subscriber to this publisher.
    ///
    /// Implementations of ``Publisher`` must implement this method.
    ///
    /// The provided implementation of ``Publisher/subscribe(_:)-4u8kn``calls this method.
    ///
    /// - Parameter subscriber: The subscriber to attach to this ``Publisher``, after which it can receive values.
    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
}
