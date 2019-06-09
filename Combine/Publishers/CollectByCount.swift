//
//  CollectByCount.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class CollectByCountConnection<Input, Downstream>: UpstreamConnection<Input, Downstream>
where Downstream: Subscriber, Downstream.Input == [Input] {
    var result: [Input] = []
    let count: Int

    init(_ count: Int, _ downstream: Downstream) {
        self.count = count
        result.reserveCapacity(count)
        super.init(downstream)
    }

    override func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        assert(upstream != nil)
        guard let stream = upstream else {
            return
        }
        switch demand {
        case let .max(value):
            // https://developer.apple.com/documentation/combine/publisher/3204693-collect
            let (max, overflow) = value.multipliedReportingOverflow(by: count)
            if overflow {
                stream.request(Subscribers.Demand.unlimited)
            } else {
                stream.request(Subscribers.Demand.max(max))
            }
        case .unlimited:
            stream.request(Subscribers.Demand.unlimited)
        }
    }

    override func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result.append(input)
        let max = result.count - count
        if max == 0 {
            let temp = result
            result.removeAll(keepingCapacity: true)
            _ = forward(temp)
        }
        return max > 0 ? Subscribers.Demand.max(max) : Subscribers.Demand.max(count)
    }

    override func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        switch completion {
        case let .failure(e):
            forward(failure: e)
        case .finished:
            if !result.isEmpty {
                _ = forward(result)
            }
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that buffers a maximum number of items.
    /// https://developer.apple.com/documentation/combine/publishers/collectbycount
    struct CollectByCount<Upstream>: Publisher where Upstream : Publisher {
        public typealias Output = [Upstream.Output]
        public typealias Failure = Upstream.Failure

        public let count: Int
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = CollectByCountConnection(count, subscriber)
            upstream.subscribe(connection)
        }
    }
}
