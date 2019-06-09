//
//  Scan.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/9.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class ScanConnection<Input, Downstream>: UpstreamConnection<Input, Downstream>
    where Downstream: Subscriber {
    var result: Downstream.Input
    let next: (Downstream.Input, Input) -> Downstream.Input
    
    init(_ downstream: Downstream, _ initial: Downstream.Input,
         _ next: @escaping (Downstream.Input, Input) -> Downstream.Input) {
        self.result = initial
        self.next = next
        super.init(downstream)
    }
    
    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result = next(result, input)
        return Subscribers.Demand.unlimited
    }
    
    override func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
        case .finished:
            _ = forward(result)
            forwardFinished()
        }
    }
}

extension Publishers {
    struct Scan<Upstream, Output>: Publisher where Upstream : Publisher {
        public typealias Failure = Upstream.Failure
        
        public let initialResult: Output
        public let nextPartialResult: (Output, Upstream.Output) -> Output
        public let upstream: Upstream
        
        init(upstream: Upstream, initial: Output, next: @escaping (Output, Upstream.Output) -> Output) {
            self.initialResult = initial
            self.nextPartialResult = next
            self.upstream = upstream
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = ScanConnection(subscriber, initialResult, nextPartialResult)
            upstream.subscribe(connection)
        }
    }
}
