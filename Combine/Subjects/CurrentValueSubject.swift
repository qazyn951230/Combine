//
//  CurrentValueSubject.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

/// A subject that wraps a single value and publishes a new element whenever the value changes.
public final class CurrentValueSubject<Output, Failure>: Subject where Failure : Error {
    private var downstream: AnySubscriber<Output, Failure>?
    public var _value: Output
    public var value: Output {
        get {
            return _value
        }
        set {
            _value = newValue
            send(_value)
        }
    }

    init(_ value: Output) {
        _value = value
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        downstream = AnySubscriber(subscriber)
    }

    public func send(_ value: Output) {
        _value = value
        _ = downstream?.receive(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        downstream?.receive(completion: completion)
        downstream = nil
    }
}
