//
//  AnySubject.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public final class AnySubject<Output, Failure>: Subject where Failure : Error {
    private let subscribe: (AnySubscriber<Output, Failure>) -> Void
    private let receive: (Output) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S : Subject {
        subscribe = { i in
            subject.receive(subscriber: i)
        }
        receive = { i in
            subject.send(i)
        }
        receiveCompletion = { i in
            subject.send(completion: i)
        }
    }

    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void,
         _ receive: @escaping (Output) -> Void,
         _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.subscribe = subscribe
        self.receive = receive
        self.receiveCompletion = receiveCompletion
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscribe(AnySubscriber(subscriber))
    }

    public func send(_ value: Output) {
        receive(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
    }
}
