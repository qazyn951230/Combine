//
//  Sink.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public extension Subscribers {
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    // https://developer.apple.com/documentation/combine/subscribers/sink
    final class Sink<Upstream>: Subscriber, Cancellable where Upstream : Publisher {
        public typealias Input = Upstream.Output
        public typealias Failure = Upstream.Failure

        public final let receiveCompletion: (Subscribers.Completion<Upstream.Failure>) -> Void
        public final let receiveValue: (Upstream.Output) -> Void

        private var stop = false

        public init(receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Void)? = nil,
                    receiveValue: @escaping ((Upstream.Output) -> Void)) {
            self.receiveCompletion = receiveCompletion ?? Sink.deafultCompletion
            self.receiveValue = receiveValue
        }

        public func receive(_ input: Input) -> Subscribers.Demand {
            if stop {
                return Subscribers.Demand.none
            }
            receiveValue(input)
            return stop ? Subscribers.Demand.none : Subscribers.Demand.unlimited
        }

        public func receive(subscription: Subscription) {
            if stop {
                return
            }
            subscription.request(Subscribers.Demand.unlimited)
        }

        public func receive(completion: Subscribers.Completion<Failure>) {
            if stop {
                return
            }
            receiveCompletion(completion)
            stop = true
        }

        public func cancel() {
            stop = true
        }

        private static func deafultCompletion(_ completion: Subscribers.Completion<Upstream.Failure>) {
            // Do nothing.
        }
    }
}
