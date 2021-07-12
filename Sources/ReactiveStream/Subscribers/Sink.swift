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

extension Subscribers {

    /// A simple subscriber that requests an unlimited number of values upon subscription.
    public final class Sink<Input, Failure>: Subscriber, Cancellable, CustomStringConvertible,
        CustomReflectable, CustomPlaygroundDisplayConvertible where Failure: Error {

        private var upstream: Subscription?

        /// The closure to execute on receipt of a value.
        public final let receiveValue: (Input) -> Void

        /// The closure to execute on completion.
        public final let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

        public final var description: String {
            "Sink"
        }

        public final var customMirror: Mirror {
            Mirror(self, children: EmptyCollection())
        }

        public final var playgroundDescription: Any {
            description
        }

        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveCompletion: The closure to execute on completion.
        ///   - receiveValue: The closure to execute on receipt of a value.
        public init(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
            receiveValue: @escaping (Input) -> Void) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }

        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received ``Subscription`` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        public final func receive(subscription: Subscription) {
            guard upstream == nil else {
                subscription.cancel()
                return
            }
            upstream = subscription
            subscription.request(.unlimited)
        }

        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Subscribers.Demand` instance indicating how many more elements the subscriber expects to receive.
        public final func receive(_ value: Input) -> Subscribers.Demand {
            return .none
        }

        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A ``Subscribers/Completion`` case indicating whether publishing completed normally or with an error.
        public final func receive(completion: Subscribers.Completion<Failure>) {

        }

        /// Cancel the activity.
        ///
        /// When implementing ``Cancellable`` in support of a custom publisher, implement `cancel()` to request that your publisher stop calling its downstream subscribers. Combine doesn't require that the publisher stop immediately, but the `cancel()` call should take effect quickly. Canceling should also eliminate any strong references it currently holds.
        ///
        /// After you receive one call to `cancel()`, subsequent calls shouldn't do anything. Additionally, your implementation must be thread-safe, and it shouldn't block the caller.
        ///
        /// > Tip: Keep in mind that your `cancel()` may execute concurrently with another call to `cancel()` --- including the scenario where an ``AnyCancellable`` is deallocating --- or to ``Subscription/request(_:)``.
        public final func cancel() {

        }
    }
}
