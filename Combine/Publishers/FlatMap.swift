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

//private final class FlatMapChild<Upstream, Downstream>: Subscriber, Cancellable
//    where Downstream: Subscriber, Upstream: Publisher, Upstream.Failure == Downstream.Failure {
//    typealias Input = Upstream.Output
//    typealias Failure = Upstream.Failure
//    typealias Parent = FlatMapChild<Input, Upstream, Downstream>
//
//    let parent: Parent
//    var stop = false
//
//    init(_ parent: Parent) {
//        self.parent = parent
//    }
//
//    func receive(subscription: Subscription) {
//        if stop {
//            return
//        }
//        return parent.receive(subscription: subscription)
//    }
//
//    func receive(_ input: Input) -> Subscribers.Demand {
//        if stop {
//            return Subscribers.Demand.none
//        }
//        return parent.receive(input)
//    }
//
//    func receive(completion: Subscribers.Completion<Failure>) {
//        if stop {
//            return
//        }
//        return parent.receive(completion: completion)
//    }
//
//    func cancel() {
//        stop = true
//    }
//}
//
//private final class FlatMapPipe<Input, Output, Downstream>: UpstreamPipe
//    where Downstream: Subscriber, Output: Publisher, Output.Failure == Downstream.Failure {
//    typealias Failure = Downstream.Failure
//
//    var stop = false
//    let downstream: Downstream
//    var upstream: Subscription?
//    let transform: (Input) -> Output
//    var count: Int = 0
//
//    init(_ downstream: Downstream, _ transform: @escaping (Input) -> Output) {
//        self.downstream = downstream
//        self.transform = transform
//    }
//
//    func receive(_ input: Input) -> Subscribers.Demand {
////        let output = transform(input)
////        let child = FlatMapChild(self)
////        output.subscribe(child)
//        return Subscribers.Demand.unlimited
//    }
//}

public extension Publishers {
    struct FlatMap<P, Upstream>: Publisher where P: Publisher, Upstream: Publisher, P.Failure == Upstream.Failure {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let maxPublishers: Subscribers.Demand
        public let transform: (Upstream.Output) -> P
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
//            let pipe = FlatMapPipe(subscriber, transform)
//            upstream.subscribe(pipe)
        }
    }
}
