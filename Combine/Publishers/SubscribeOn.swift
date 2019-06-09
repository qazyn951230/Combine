//
//  SubscribeOn.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public extension Publishers {
    /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
    struct SubscribeOn<Upstream, Context>: Publisher where Upstream : Publisher, Context: Scheduler {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        public let options: Context.SchedulerOptions?
        public let scheduler: Context
        public let upstream: Upstream
        
        init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
            self.options = options
            self.scheduler = scheduler
            self.upstream = upstream
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = ForwardConnection(subscriber)
            scheduler.schedule(options: options) {
                subscriber.receive(subscription: connection)
            }
        }
    }
}
