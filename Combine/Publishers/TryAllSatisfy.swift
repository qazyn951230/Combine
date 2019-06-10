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

private final class TryAllSatisfyPipe<Input, Failure, Downstream>: UpstreamPipe
    where Failure: Error, Downstream: Subscriber, Downstream.Input == Bool, Downstream.Failure == Error {

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let predicate: (Input) throws -> Bool
    var result: Bool = true

    init(_ downstream: Downstream, _ predicate: @escaping (Input) throws -> Bool) {
        self.downstream = downstream
        self.predicate = predicate
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if result {
            do {
                result = try predicate(input)
            } catch let failure {
                forward(failure: failure)
                return Subscribers.Demand.none
            }
        }
        return Subscribers.Demand.unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(e):
            forward(failure: e)
        case .finished:
            _ = forward(result)
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that publishes a single Boolean value that indicates whether
    ///     all received elements pass a given error-throwing predicate.
    struct TryAllSatisfy<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Bool
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that evaluates each received element.
        ///
        /// Return `true` to continue, or `false` to cancel the upstream and complete.
        ///     The closure may throw, in which case the publisher cancels the upstream publisher and
        ///     fails with the thrown error.
        public let predicate: (Upstream.Output) throws -> Bool

        init(upstream: Upstream, predicate: @escaping (Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let pipe = TryAllSatisfyPipe<Upstream.Output, Upstream.Failure, S>(subscriber, predicate)
            upstream.subscribe(pipe)
        }
    }
}
