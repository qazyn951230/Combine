//
//  File.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public struct AnyPublisher<Output, Failure>: Publisher where Failure : Error {
    private let receiveSubscriber: (AnySubscriber<Output, Failure>) -> Void

    public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P : Publisher {
        receiveSubscriber = { s in
            publisher.receive(subscriber: s)
        }
    }

    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        receiveSubscriber = { s in
            subscribe(s)
        }
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        receiveSubscriber(AnySubscriber(subscriber))
    }
}
