// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

private final class ContainsWherePipe<Input, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Downstream.Input == Bool {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let predicate: (Input) -> Bool
    var contains = false

    init(_ downstream: Downstream, _ predicate: @escaping (Input) -> Bool) {
        self.downstream = downstream
        self.predicate = predicate
    }

    var description: String {
        return "ContainsWhere"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if !contains && predicate(input) {
            contains = true
            return forward(true)
        }
        return Subscribers.Demand.unlimited
    }

    func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        switch completion {
        case .failure:
            forward(completion: completion)
        case .finished:
            if !contains {
                forward(false)
            }
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that emits a Boolean value upon receiving an element that satisfies the predicate closure.
    struct ContainsWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Bool
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether the publisher should consider an element as a match.
        public let predicate: (Upstream.Output) -> Bool

        init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, S.Input == Output {
            let pipe = ContainsWherePipe(subscriber, predicate)
            upstream.subscribe(pipe)
        }
    }
}
