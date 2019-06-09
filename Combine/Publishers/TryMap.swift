//
//  TryMap.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class TryMapConnection<Input, Downstream>: UpstreamConnection<Input, Downstream> where Downstream: Subscriber {
    let transform: (Input) throws -> Downstream.Input
    
    init(_ transform: @escaping (Input) throws -> Downstream.Input, _ downstream: Downstream) {
        self.transform = transform
        super.init(downstream)
    }
    
    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        do {
            return forward(try transform(input))
        } catch let failure as Downstream.Failure {
            forward(failure: failure)
        } catch let e {
            print(e)
            cancel()
        }
        return Subscribers.Demand.none
    }
}

public extension Publishers {
    struct TryMap<Upstream, Output>: Publisher where Upstream : Publisher {
        public typealias Failure = Upstream.Failure
        
        public let transform: (Upstream.Output) throws -> Output
        public let upstream: Upstream
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = TryMapConnection(transform, subscriber)
            upstream.subscribe(connection)
        }
    }
}
