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

public extension Subscribers {

    /// A simple subscriber that requests an unlimited number of values upon subscription.
    /// - SeeAlso: [The Combine Library Reference]
    ///     (https://developer.apple.com/documentation/combine/subscribers/sink)
    final class Sink<Upstream>: Subscriber, Cancellable where Upstream: Publisher {
        public typealias Input = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let receiveCompletion: (Subscribers.Completion<Upstream.Failure>) -> Void
        public let receiveValue: (Upstream.Output) -> Void
        private var upstream: Subscription?

        public init(receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Void)? = nil,
                    receiveValue: @escaping ((Upstream.Output) -> Void)) {
            self.receiveCompletion = receiveCompletion ?? Sink.defaultCompletion
            self.receiveValue = receiveValue
        }

        public func receive(_ input: Input) -> Subscribers.Demand {
            receiveValue(input)
            return Subscribers.Demand.none
        }

        public func receive(subscription: Subscription) {
            if upstream != nil {
                subscription.cancel()
            }
            upstream = subscription
            subscription.request(Subscribers.Demand.unlimited)
        }

        public func receive(completion: Subscribers.Completion<Failure>) {
            receiveCompletion(completion)
        }

        public func cancel() {
            upstream?.cancel()
            upstream = nil
        }

        private static func defaultCompletion(_ completion: Subscribers.Completion<Upstream.Failure>) {
            // Do nothing.
        }
    }
}
