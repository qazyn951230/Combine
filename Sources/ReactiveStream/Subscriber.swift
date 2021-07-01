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
///
/// A ``Subscriber`` instance receives a stream of elements from a ``Publisher``, along with life cycle events describing changes to their relationship. A given subscriber’s ``Subscriber/Input`` and ``Subscriber/Failure`` associated types must match the ``Publisher/Output`` and ``Publisher/Failure`` of its corresponding publisher.
///
/// You connect a subscriber to a publisher by calling the publisher’s ``Publisher/subscribe(_:)-4u8kn`` method.  After making this call, the publisher invokes the subscriber’s ``Subscriber/receive(subscription:)`` method. This gives the subscriber a ``Subscription`` instance, which it uses to demand elements from the publisher, and to optionally cancel the subscription. After the subscriber makes an initial demand, the publisher calls ``Subscriber/receive(_:)``, possibly asynchronously, to deliver newly-published elements. If the publisher stops publishing, it calls ``Subscriber/receive(completion:)``, using a parameter of type ``Subscribers/Completion`` to indicate whether publishing completes normally or with an error.
///
/// Combine provides the following subscribers as operators on the ``Publisher`` type:
///
/// - ``Publisher/sink(receiveCompletion:receiveValue:)`` executes arbitrary closures when it receives a completion signal and each time it receives a new element.
/// - ``Publisher/assign(to:on:)`` writes each newly-received value to a property identified by a key path on a given instance.
public protocol Subscriber /*: CustomCombineIdentifierConvertible*/ {

    /// The kind of values this subscriber receives.
    associatedtype Input

    /// The kind of errors this subscriber might receive.
    ///
    /// Use `Never` if this `Subscriber` cannot receive errors.
    associatedtype Failure: Error

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received ``Subscription`` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    func receive(subscription: Subscription)

    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Subscribers.Demand` instance indicating how many more elements the subscriber expects to receive.
    func receive(_ input: Self.Input) -> Subscribers.Demand

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A ``Subscribers/Completion`` case indicating whether publishing completed normally or with an error.
    func receive(completion: Subscribers.Completion<Self.Failure>)
}
