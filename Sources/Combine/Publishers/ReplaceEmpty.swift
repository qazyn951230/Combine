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

private final class ReplaceEmptyPipe<Downstream>: UpstreamPipe where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let input: Input
    var hasElement = false

    init(_ downstream: Downstream, _ input: Input) {
        self.downstream = downstream
        self.input = input
    }

    var description: String {
        return "ReplaceEmpty"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        hasElement = true
        return forward(input)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure:
            forward(completion: completion)
        case .finished:
            if !hasElement {
                forward(input)
            }
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that replaces an empty stream with a provided element.
    struct ReplaceEmpty<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The element to deliver when the upstream publisher finishes without delivering any elements.
        public let output: Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Output) {
            self.upstream = upstream
            self.output = output
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure,
            Upstream.Output == S.Input {
            let pipe = ReplaceEmptyPipe(subscriber, output)
            upstream.subscribe(pipe)
        }
    }
}
