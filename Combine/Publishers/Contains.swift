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

private final class ContainsPipe<Input, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Downstream.Input == Bool, Input: Equatable {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let input: Input
    var contains = false

    init(_ downstream: Downstream, _ input: Input) {
        self.downstream = downstream
        self.input = input
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        if !contains && self.input == input {
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
    /// A publisher that emits a Boolean value when a specified element is received from its upstream publisher.
    struct Contains<Upstream>: Publisher where Upstream: Publisher, Upstream.Output: Equatable {
        public typealias Output = Bool
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The element to scan for in the upstream publisher.
        public let output: Upstream.Output

        init(upstream: Upstream, output: Upstream.Output) {
            self.upstream = upstream
            self.output = output
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, S.Input == Output {
            let pipe = ContainsPipe(subscriber, output)
            upstream.subscribe(pipe)
        }
    }
}

extension Publishers.Contains: Equatable where Upstream: Equatable {
    public static func ==(lhs: Publishers.Contains<Upstream>, rhs: Publishers.Contains<Upstream>) -> Bool {
        return lhs.output == rhs.output && lhs.upstream == rhs.upstream
    }
}
