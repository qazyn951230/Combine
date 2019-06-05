//
//  Empty.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class EmptyConnection<Downstream>: Connection<Downstream> where Downstream: Subscriber {
    override func request(_ demand: Subscribers.Demand) {
        forward(completion: Subscribers.Completion.finished)
    }
}

public extension Publishers {
    struct Empty<Output, Failure>: Publisher where Failure : Error {
        public let completeImmediately: Bool

        public init(completeImmediately: Bool = true) {
            self.completeImmediately = completeImmediately
        }

        public init(completeImmediately: Bool = true, outputType: Output.Type, failureType: Failure.Type) {
            self.completeImmediately = completeImmediately
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            if completeImmediately {
                subscriber.receive(completion: Subscribers.Completion.finished)
            } else {
                let connection = EmptyConnection(subscriber)
                subscriber.receive(subscription: connection)
            }
        }
    }
}
