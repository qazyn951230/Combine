//
//  FlatMap.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class FlatMapChild<Upstream, Downstream>: Subscriber, Cancellable
    where Downstream: Subscriber, Upstream: Publisher, Upstream.Failure == Downstream.Failure {
    typealias Input = Upstream.Output
    typealias Failure = Upstream.Failure
    typealias Parent = FlatMapConnection<Input, Upstream, Downstream>
    
    let parent: Parent
    var stop = false
    
    init(_ parent: Parent) {
        self.parent = parent
    }
    
    func receive(subscription: Subscription) {
        if stop {
            return
        }
        return parent.receive(subscription: subscription)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        return parent.receive(input)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        if stop {
            return
        }
        return parent.receive(completion: completion)
    }
    
    func cancel() {
        stop = true
    }
}

private final class FlatMapConnection<Input, Output, Downstream>: UpstreamConnection<Input, Downstream>
    where Downstream: Subscriber, Output: Publisher {
    let transform: (Input) -> Output
    var count: Int = 0
    
    init(_ transform: @escaping (Input) -> Output, _ downstream: Downstream) {
        self.transform = transform
        super.init(downstream)
    }
    
    override func receive(_ input: Input) -> Subscribers.Demand {
//        let output = transform(input)
//        let child = FlatMapChild(self)
//        output.subscribe(child)
        return Subscribers.Demand.unlimited
    }
}

public extension Publishers {
    struct FlatMap<P, Upstream>: Publisher where P : Publisher, Upstream : Publisher, P.Failure == Upstream.Failure {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        public let maxPublishers: Subscribers.Demand
        public let transform: (Upstream.Output) -> P
        public let upstream: Upstream
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = FlatMapConnection(transform, subscriber)
            upstream.subscribe(connection)
        }
    }
}
