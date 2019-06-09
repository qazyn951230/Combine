//
//  AllSatisfy.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class AllSatisfyConnection<Input, Downstream>: UpstreamConnection<Input, Downstream>
    where Downstream: Subscriber, Downstream.Input == Bool {
    let predicate: (Input) -> Bool
    var result: Bool = true

    init(_ predicate: @escaping (Input) -> Bool, _ downstream: Downstream) {
        self.predicate = predicate
        super.init(downstream)
    }

    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result = result && predicate(input)
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
    struct AllSatisfy<Upstream>: Publisher where Upstream : Publisher {
        public typealias Output = Bool
        public typealias Failure = Upstream.Failure

        public let predicate: (Upstream.Output) -> Bool
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = AllSatisfyConnection(predicate, subscriber)
            upstream.subscribe(connection)
        }
    }
}
