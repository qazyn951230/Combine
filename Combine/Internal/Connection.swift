//
//  Sink.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

class Connection<Downstream>: Subscription where Downstream: Subscriber {
    let downstream: Downstream
    var stop: Bool = false

    init(_ downstream: Downstream) {
        self.downstream = downstream
    }

    func request(_ demand: Subscribers.Demand) {
        // Do nothing.
    }

    func forward(_ input: Downstream.Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        return downstream.receive(input)
    }

    func forward(completion: Subscribers.Completion<Downstream.Failure>) {
        if stop {
            return
        }
        downstream.receive(completion: completion)
    }

    @inline(__always)
    func forwardFinished() {
        forward(completion: Subscribers.Completion.finished)
    }

    @inline(__always)
    func forward(failure: Downstream.Failure) {
        forward(completion: Subscribers.Completion.failure(failure))
    }

    func cancel() {
        stop = true
    }
}
