//
//  ForwardConnection.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

class ForwardConnection<Upstream, Downstream>: Connection<Downstream>, Subscriber where Upstream: Publisher,
    Downstream: Subscriber, Upstream.Failure == Downstream.Failure {
    typealias Input = Upstream.Output
    typealias Failure = Upstream.Failure

    let upstream: Upstream

    init(_ upstream: Upstream, _ downstream: Downstream) {
        self.upstream = upstream
        super.init(downstream)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        return Subscribers.Demand.none
    }

    func receive(subscription: Subscription) {
        if stop {
            subscription.cancel()
            return
        }
        downstream.receive(subscription: self)
        upstream.receive(subscriber: self)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        forward(completion: completion)
    }

    override func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        upstream.receive(subscriber: self)
    }

    override func cancel() {
        super.cancel()
    }
}
