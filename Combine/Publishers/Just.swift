//
//  Just.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class JustConnection<Downstream>: Connection<Downstream> where Downstream: Subscriber {
    let input: Downstream.Input

    init(_ input: Downstream.Input, _ downstream: Downstream) {
        self.input = input
        super.init(downstream)
    }

    override func request(_ demand: Subscribers.Demand) {
        if demand.many {
            _ = forward(input)
        }
        forward(completion: Subscribers.Completion.finished)
    }
}

public extension Publishers {
    struct Just<Output>: Publisher {
        public typealias Failure = Never

        public let output: Output

        public init(_ output: Output) {
            self.output = output
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = JustConnection(output, subscriber)
            subscriber.receive(subscription: connection)
        }
    }
}
