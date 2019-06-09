//
//  ReceiveOn.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class ReceiveOnConnection<Downstream, Context>: Connection<Downstream>, Subscriber where Downstream: Subscriber, Context: Scheduler {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure
    
    let options: Context.SchedulerOptions?
    let scheduler: Context
    var upstream: Subscription?
    
    init(_ options: Context.SchedulerOptions?, _ scheduler: Context, _ downstream: Downstream) {
        self.options = options
        self.scheduler = scheduler
        super.init(downstream)
    }
    
    func receive(_ input: Downstream.Input) -> Subscribers.Demand {
        return Subscribers.Demand.none
    }
    
    func receive(subscription: Subscription) {
        if stop {
            subscription.cancel()
            return
        }
        assert(upstream == nil)
        upstream = subscription
        scheduler.schedule(options: options) {
            self.downstream.receive(subscription: self)
        }
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

public extension Publishers {
    /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
    struct ReceiveOn<Upstream, Context>: Publisher where Upstream : Publisher, Context: Scheduler {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        public let options: Context.SchedulerOptions?
        public let scheduler: Context
        public let upstream: Upstream
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = ReceiveOnConnection(options, scheduler, subscriber)
            subscriber.receive(subscription: connection)
        }
    }
}
