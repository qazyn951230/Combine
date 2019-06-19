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

private final class CompactMapPipe<Input, Downstream>: UpstreamPipe where Downstream: Subscriber {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let transform: (Input) -> Downstream.Input?

    init(_ downstream: Downstream, _ transform: @escaping (Input) -> Downstream.Input?) {
        self.downstream = downstream
        self.transform = transform
    }

    var description: String {
        return "CompactMap"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if let next = transform(input) {
            return forward(next)
        }
        return Subscribers.Demand.unlimited
    }
}

public extension Publishers {

    /// A publisher that republishes all non-`nil` results of calling a closure with each received element.
    struct CompactMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that receives values from the upstream publisher and returns optional values.
        public let transform: (Upstream.Output) -> Output?

        init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output?) {
            self.upstream = upstream
            self.transform = transform
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, Upstream.Failure == S.Failure {
            let pipe = CompactMapPipe(subscriber, transform)
            upstream.subscribe(pipe)
        }
    }
}
