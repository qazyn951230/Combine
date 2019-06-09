//
//  AnySubscriber.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public struct AnySubscriber<Input, Failure>: Subscriber,
    CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible
    where Failure : Error {
    let receiveSubscription: (Subscription) -> Void
    let receiveValue: (Input) -> Subscribers.Demand
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S : Subscriber {
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

    public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S : Subject {
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
