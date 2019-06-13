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

    /// - SeeAlso: [The Combine Library Reference]
    ///     (https://developer.apple.com/documentation/combine/subscribers/assign)
    final class Assign<Root, Input> : Subscriber, Cancellable, CustomStringConvertible,
        CustomReflectable, CustomPlaygroundDisplayConvertible {
        public typealias Failure = Never

        public private(set) var object: Root?
        public let keyPath: ReferenceWritableKeyPath<Root, Input>
        private var upstream: Subscription?

        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }

        public var description: String {
            return "\(object!)"
        }

        public var customMirror: Mirror {
            return Mirror(reflecting: object!)
        }

        public var playgroundDescription: Any {
            return description
        }

        public func receive(subscription: Subscription) {
            if upstream != nil {
                subscription.cancel()
            }
            upstream = subscription
            subscription.request(Subscribers.Demand.unlimited)
        }

        public func receive(_ value: Input) -> Subscribers.Demand {
            if let temp = object {
                temp[keyPath: keyPath] = value
            }
            return Subscribers.Demand.none
        }

        public func receive(completion: Subscribers.Completion<Never>) {
            object = nil
        }

        public func cancel() {
            upstream?.cancel()
            upstream = nil
        }
    }
}
