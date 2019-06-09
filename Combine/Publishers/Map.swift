//
//  Map.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class MapConnection<Input, Downstream>: UpstreamConnection<Input, Downstream> where Downstream: Subscriber {
    let transform: (Input) -> Downstream.Input

    init(_ transform: @escaping (Input) -> Downstream.Input, _ downstream: Downstream) {
        self.transform = transform
        super.init(downstream)
    }

    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        return forward(transform(input))
    }
}

public extension Publishers {
    struct Map<Upstream, Output>: Publisher where Upstream : Publisher {
        public typealias Failure = Upstream.Failure

        public let transform: (Upstream.Output) -> Output
        public let upstream: Upstream
        
        init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            self.transform = transform
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = MapConnection(transform, subscriber)
            upstream.subscribe(connection)
        }
    }
}
