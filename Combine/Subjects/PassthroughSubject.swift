//
//  PassthroughSubject.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public final class PassthroughSubject<Output, Failure>: Subject where Failure : Error {
    private var downstream: AnySubscriber<Output, Failure>?

    public init() {
        downstream = nil
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        downstream = AnySubscriber(subscriber)
    }

    public func send(_ value: Output) {
        _ = downstream?.receive(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        downstream?.receive(completion: completion)
        downstream = nil
    }
}
