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

private final class TryContainsWherePipe<Input, Failure, Downstream>: UpstreamPipe
    where Failure: Error, Downstream: Subscriber, Downstream.Input == Bool, Downstream.Failure == Error {
    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let predicate: (Input) throws -> Bool
    var contains = false

    init(_ downstream: Downstream, _ predicate: @escaping (Input) throws -> Bool) {
        self.downstream = downstream
        self.predicate = predicate
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if !contains {
            do {
                if try predicate(input) {
                    contains = true
                    return forward(true)
                }
            } catch let failure {
                forward(failure: failure)
            }
        }
        return Subscribers.Demand.unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
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
    struct TryContainsWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Bool
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether this publisher should emit a `true` element.
        public let predicate: (Upstream.Output) throws -> Bool

        init(upstream: Upstream, predicate: @escaping (Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let pipe = TryContainsWherePipe<Upstream.Output, Upstream.Failure, S>(subscriber, predicate)
            upstream.subscribe(pipe)
        }
    }
}
