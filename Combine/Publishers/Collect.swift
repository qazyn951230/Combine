//
//  Collect.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class CollectConnection<Input, Downstream>: UpstreamConnection<Input, Downstream>
    where Downstream: Subscriber, Downstream.Input == [Input] {
    var result: [Input] = []

    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result.append(input)
        return Subscribers.Demand.unlimited
    }

    override func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        switch completion {
        case let .failure(e):
            forward(failure: e)
        case .finished:
            _ = forward(result)
            forwardFinished()
        }
    }
}

public extension Publishers {
    struct Collect<Upstream>: Publisher where Upstream : Publisher {
        public typealias Output = [Upstream.Output]
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = CollectConnection(subscriber)
            upstream.subscribe(connection)
        }
    }
}
