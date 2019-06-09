//
//  ForwardConnection.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

class ForwardConnection<Downstream>: Connection<Downstream>, Subscriber where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var upstream: Subscription?
    
    func receive(_ input: Input) -> Subscribers.Demand {
        return forward(input)
    }
    
    func receive(subscription: Subscription) {
        if stop {
            subscription.cancel()
            return
        }
        assert(upstream == nil)
        upstream = subscription
        downstream.receive(subscription: self)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        forward(completion: completion)
    }
    
    override func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        assert(upstream != nil)
        upstream?.request(demand)
    }
    
    override func cancel() {
        super.cancel()
        let up = upstream
        upstream = nil
        up?.cancel()
    }
}
