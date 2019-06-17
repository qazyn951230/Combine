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

private final class TryMapConnection<Input, Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Error {

    var stop = false
    var downstream: Downstream
    var upstream: Subscription?
    let transform: (Input) throws -> Downstream.Input

    init(_ transform: @escaping (Input) throws -> Downstream.Input, _ downstream: Downstream) {
        self.transform = transform
        self.downstream = downstream
    }

    var description: String {
        return "TryMap"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        do {
            return forward(try transform(input))
        } catch let error {
            forward(failure: error)
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(error):
            forward(failure: error)
        case .finished:
            forwardFinished()
        }
    }
}

public extension Publishers {
    struct TryMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error

        public let transform: (Upstream.Output) throws -> Output
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = TryMapConnection<Upstream.Output, Upstream.Failure, S>(transform, subscriber)
            upstream.subscribe(pipe)
        }
    }
}
