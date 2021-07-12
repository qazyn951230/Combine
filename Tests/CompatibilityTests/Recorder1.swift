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

import ReactiveStream

class Recorder1<Input, Failure>: Subscriber where Failure: Error {
    private let onSubscription: (Subscription) -> Demand1
    private let onValue: (Input) -> Demand1
    private let autoConnect: Bool
    private(set) var recorders: [Event] = []

    private(set) var subscription: Subscription?
    private(set) var completion: Subscribers.Completion<Failure>?

    init(autoConnect: Bool = true,
        onSubscription: @escaping (Subscription) -> Demand1 = ReactiveSubscription.unlimited,
        onValue: @escaping (Input) -> Demand1 = ReactiveInput.unlimited) {
        self.autoConnect = autoConnect
        self.onSubscription = onSubscription
        self.onValue = onValue
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        recorders.append(.subscription(subscription))
        if autoConnect {
            subscription.request(onSubscription(subscription))
        }
    }

    func receive(_ input: Input) -> Demand1 {
        recorders.append(.value(input))
        return onValue(input)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        self.completion = completion
        recorders.append(.completion(completion))
    }

    enum Event {
        case subscription(Subscription)
        case value(Input)
        case completion(Subscribers.Completion<Failure>)
    }
}

extension Publisher {
    func makeRecorder(autoConnect: Bool = true,
        onSubscription: @escaping (Subscription) -> Demand1 = ReactiveSubscription.unlimited,
        onValue: @escaping (Output) -> Demand1 = ReactiveInput.unlimited
    ) -> Recorder1<Output, Failure> {
        Recorder1(autoConnect: autoConnect, onSubscription: onSubscription, onValue: onValue)
    }

    func receiveRecorder(autoConnect: Bool = true,
        onSubscription: @escaping (Subscription) -> Demand1 = ReactiveSubscription.unlimited,
        onValue: @escaping (Output) -> Demand1 = ReactiveInput.unlimited
    ) -> Recorder1<Output, Failure> {
        let recorder = Recorder1<Output, Failure>(autoConnect: autoConnect,
            onSubscription: onSubscription, onValue: onValue)
        receive(subscriber: recorder)
        return recorder
    }
}

struct ReactiveSubscription {
    static func unlimited(subscription: Subscription) -> Demand1 {
        .unlimited
    }

    static func none(subscription: Subscription) -> Demand1 {
        .none
    }
}

struct ReactiveInput {
    static func unlimited<Input>(_ input: Input) -> Demand1 {
        .unlimited
    }

    static func none<Input>(_ input: Input) -> Demand1 {
        .none
    }
}
