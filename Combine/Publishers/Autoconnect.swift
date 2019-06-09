//
//  Autoconnect.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class AutoconnectConnection<Downstream>: UpstreamConnection<Downstream.Input, Downstream> where Downstream: Subscriber {
    override func receive(_ input: Downstream.Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        return forward(input)
    }
}

public extension Publishers {
    // TODO: Remove final
    final class Autoconnect<Upstream>: Publisher where Upstream : ConnectablePublisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public final let upstream: Upstream

        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = AutoconnectConnection(subscriber)
            upstream.subscribe(connection)
        }
    }
}
