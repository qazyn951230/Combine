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

private final class TryReducePipe<Input, Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Error {
    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    var result: Downstream.Input
    let next: (Downstream.Input, Input) throws -> Downstream.Input

    init(_ downstream: Downstream, _ initial: Downstream.Input,
         _ next: @escaping (Downstream.Input, Input) throws -> Downstream.Input) {
        self.downstream = downstream
        self.result = initial
        self.next = next
    }

    var description: String {
        return "TryReduce"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        do {
            result = try next(result, input)
            return Subscribers.Demand.unlimited
        } catch let failure as Failure {
            forward(failure: failure)
        } catch let e {
            print(e)
            cancel()
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
        case .finished:
            forward(result)
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that applies an error-throwing closure to all received elements and
    ///     produces an accumulated value when the upstream publisher finishes.
    struct TryReduce<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error
        public let upstream: Upstream

        /// The initial value provided on the first invocation of the closure.
        public let initial: Output

        /// An error-throwing closure that takes the previously-accumulated value and
        ///     the next element from the upstream to produce a new value.
        ///
        /// If this closure throws an error, the publisher fails and passes the error to its subscriber.
        public let nextPartialResult: (Output, Upstream.Output) throws -> Output

        init(upstream: Upstream, initial: Output, next: @escaping (Output, Upstream.Output) throws -> Output) {
            self.upstream = upstream
            self.initial = initial
            self.nextPartialResult = next
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Failure {
            let pipe = TryReducePipe<Upstream.Output, Upstream.Failure, S>(subscriber, initial, nextPartialResult)
            upstream.subscribe(pipe)
        }
    }
}
