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

public struct AnySubscriber<Input, Failure>: Subscriber,
    CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible
    where Failure: Error {
    let receiveSubscription: (Subscription) -> Void
    let receiveValue: (Input) -> Subscribers.Demand
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S: Subscriber {
        receiveSubscription = { i in
            s.receive(subscription: i)
        }
        receiveValue = { i in
            s.receive(i)
        }
        receiveCompletion = { i in
            s.receive(completion: i)
        }
    }

    public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S: Subject {
        receiveSubscription = { i in
            i.request(Subscribers.Demand.unlimited)
        }
        receiveValue = { i in
            s.send(i)
            return Subscribers.Demand.unlimited
        }
        receiveCompletion = { i in
            s.send(completion: i)
        }
    }

    public init(receiveSubscription: ((Subscription) -> Void)? = nil,
                receiveValue: ((Input) -> Subscribers.Demand)? = nil,
                receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscription = receiveSubscription ?? AnySubscriber.defaultReceiveSubscription
        self.receiveValue = receiveValue ?? AnySubscriber.defaultReceiveValue
        self.receiveCompletion = receiveCompletion ?? AnySubscriber.defaultReceiveCompletion
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        return receiveValue(input)
    }

    public func receive(subscription: Subscription) {
        receiveSubscription(subscription)
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
    }

    public var description: String {
        return ""
    }

    public var customMirror: Mirror {
        return Mirror(reflecting: self)
    }

    public var playgroundDescription: Any {
        return description
    }

    private static func defaultReceiveSubscription(_ subscription: Subscription) -> Void {
        subscription.request(Subscribers.Demand.unlimited)
    }

    private static func defaultReceiveValue(_ input: Input) -> Subscribers.Demand {
        return Subscribers.Demand.unlimited
    }

    private static func defaultReceiveCompletion(_ completion: Subscribers.Completion<Failure>) -> Void {
        // Do nothing.
    }
}
