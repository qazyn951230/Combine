//
//  MapError.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class MapErrorConnection<Failure, Downstream>: Connection<Downstream>, Subscriber
    where Downstream: Subscriber, Failure: Error {
    typealias Input = Downstream.Input
    
    let transform: (Failure) -> Downstream.Failure
    var upstream: Subscription?
    
    init(_ transform: @escaping (Failure) -> Downstream.Failure, _ downstream: Downstream) {
        self.transform = transform
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
        assert(upstream == nil)
        upstream = subscription
        downstream.receive(subscription: self)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        if stop {
            return
        }
        switch completion {
        case .finished:
            forwardFinished()
        case let .failure(error):
            forward(failure: transform(error))
        }
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

public extension Publishers {
    struct MapError<Upstream, Failure>: Publisher where Upstream : Publisher, Failure : Error {
        public typealias Output = Upstream.Output
        
        public let transform: (Upstream.Failure) -> Failure
        public let upstream: Upstream
    
        public  init(upstream: Upstream, _ map: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = map
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = MapErrorConnection(transform, subscriber)
            upstream.subscribe(connection)
        }
    }
}
