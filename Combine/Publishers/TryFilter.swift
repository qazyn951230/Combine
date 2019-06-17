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

private final class TryFilterPipe<Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Error {
    typealias Input = Downstream.Input

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let isIncluded: (Input) throws -> Bool

    init(_ downstream: Downstream, _ isIncluded: @escaping (Input) throws -> Bool) {
        self.downstream = downstream
        self.isIncluded = isIncluded
    }

    var description: String {
        return "TryFilter"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        do {
            if try isIncluded(input) {
                return forward(input)
            }
        } catch let error {
            forward(failure: error)
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
        case .finished:
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that republishes all elements that match a provided error-throwing closure.
    struct TryFilter<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) throws -> Bool

        init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.isIncluded = isIncluded
        }

        public func receive<S>(subscriber: S)
            where S : Subscriber, Upstream.Output == S.Input, S.Failure == Failure {
            let pipe = TryFilterPipe<Upstream.Failure, S>(subscriber, isIncluded)
            upstream.subscribe(pipe)
        }
    }
}
