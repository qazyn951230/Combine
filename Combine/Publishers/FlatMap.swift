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

private final class FlatMapChildPipe<Pipe, Upstream, Origin>: UpstreamPipe
    where Upstream: Publisher, Origin: Subscriber, Upstream.Failure == Origin.Failure {
    typealias Downstream = FlatMapPipe<Pipe, Upstream, Origin>
    typealias Input = Upstream.Output
    typealias Failure = Upstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?

    init(_ downstream: Downstream) {
        self.downstream = downstream
    }

    var description: String {
        return "FlatMap"
    }

    // Input -> Upstream.Output -> Inner.Output
    func receive(_ input: Input) -> Subscribers.Demand {
        return downstream.receiveChild(input)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        downstream.receiveChild(self, completion: completion)
    }
}

private final class FlatMapPipe<Input, Inner, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Inner: Publisher, Inner.Failure == Downstream.Failure {
    typealias Failure = Downstream.Failure
    typealias Child = FlatMapChildPipe<Input, Inner, Downstream>

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let transform: (Input) -> Inner
    var count: Int = 0

    init(_ downstream: Downstream, _ transform: @escaping (Input) -> Inner) {
        self.downstream = downstream
        self.transform = transform
    }

    var description: String {
        return "FlatMap"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        let output = transform(input)
        let child = FlatMapChildPipe(self)
        output.subscribe(child)
        return Subscribers.Demand.none
    }

    // Inner -> P
    // Inner.Output -> P.Output -> Output -> S.Input -> Downstream.Input
    func receiveChild(_ input: Inner.Output) -> Subscribers.Demand {
//        forward(input)
        return Subscribers.Demand.none
    }

    func receiveChild(_ child: Child, completion: Subscribers.Completion<Inner.Failure>) {

    }
}

public extension Publishers {
    struct FlatMap<P, Upstream>: Publisher where P: Publisher, Upstream: Publisher, P.Failure == Upstream.Failure {
        public typealias Output = P.Output
        public typealias Failure = Upstream.Failure

        public let maxPublishers: Subscribers.Demand
        public let transform: (Upstream.Output) -> P
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            // Input -> Upstream.Output
            // Inner -> P
            // Downstream -> S
            // Failure -> Downstream.Failure -> S.Failure -> Failure -> Upstream.Failure
            let pipe = FlatMapPipe(subscriber, transform)
            upstream.subscribe(pipe)
        }
    }
}
