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

private final class TryComparisonPipe<Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Error {
    typealias Input = Downstream.Input
    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let areInIncreasingOrder: (Input, Input) throws -> Bool
    var result: Input?

    init(_ downstream: Downstream, _ areInIncreasingOrder: @escaping (Input, Input) throws -> Bool) {
        self.downstream = downstream
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var description: String {
        return "TryComparison"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if let _result = result {
            do {
                if try areInIncreasingOrder(_result, input) {
                    result = input
                }
            } catch let failure {
                forward(failure: failure)
            }
        } else {
            result = input
        }
        return Subscribers.Demand.unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
        case .finished:
            if let _result = result {
                forward(_result)
            }
            forwardFinished()
        }
    }

    func clean() {
        result = nil
    }
}

public extension Publishers {
    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item, and fails if the ordering logic throws an error.
    struct TryComparison<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) throws -> Bool

        init(upstream: Upstream, areInIncreasingOrder: @escaping (Upstream.Output, Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.areInIncreasingOrder = areInIncreasingOrder
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Failure {
            let pipe = TryComparisonPipe<Upstream.Failure, S>(subscriber, areInIncreasingOrder)
            upstream.subscribe(pipe)
        }
    }
}
