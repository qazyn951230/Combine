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

private final class ScanPipe<Input, Downstream>: UpstreamPipe where Downstream: Subscriber {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    var result: Downstream.Input
    let next: (Downstream.Input, Input) -> Downstream.Input

    init(_ downstream: Downstream, _ initial: Downstream.Input,
         _ next: @escaping (Downstream.Input, Input) -> Downstream.Input) {
        self.downstream = downstream
        self.result = initial
        self.next = next
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result = next(result, input)
        return forward(result)
    }
}

public extension Publishers {
    struct Scan<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure

        public let initialResult: Output
        public let nextPartialResult: (Output, Upstream.Output) -> Output
        public let upstream: Upstream

        init(upstream: Upstream, initial: Output, next: @escaping (Output, Upstream.Output) -> Output) {
            self.initialResult = initial
            self.nextPartialResult = next
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = ScanPipe(subscriber, initialResult, nextPartialResult)
            upstream.subscribe(pipe)
        }
    }
}
