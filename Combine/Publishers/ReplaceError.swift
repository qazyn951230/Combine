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

private final class ReplaceErrorPipe<Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Never {
    typealias Input = Downstream.Input

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let input: Input

    init(_ downstream: Downstream, _ input: Input) {
        self.downstream = downstream
        self.input = input
    }

    var description: String {
        return "ReplaceError"
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure:
            forward(input)
            cancel()
        case .finished:
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that replaces any errors in the stream with a provided element.
    struct ReplaceError<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Never

        /// The element with which to replace errors from the upstream publisher.
        public let output: Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Upstream.Output) {
            self.output = output
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Failure {
            let pipe = ReplaceErrorPipe<Upstream.Failure, S>(subscriber, output)
            upstream.subscribe(pipe)
        }
    }
}
