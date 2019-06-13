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

private final class TryRemoveDuplicatesPipe<Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error, Downstream.Failure == Error {
    typealias Input = Downstream.Input

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let predicate: (Input, Input) throws -> Bool
    var values: [Input] = []

    init(_ downstream: Downstream, _ predicate: @escaping (Input, Input) throws -> Bool) {
        self.downstream = downstream
        self.predicate = predicate
    }

    var description: String {
        return "TryRemoveDuplicates"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        do {
            let contains = try values.contains { (value: Input) in
                try self.predicate(input, value)
            }
            if contains {
                return forward(input)
            }
        } catch let failure {
            forward(failure: failure)
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(e):
            forward(failure: e)
        case .finished:
            forwardFinished()
        }
    }

    func cancel() {
        if stop {
            assert(upstream == nil)
            assert(values.isEmpty)
            return
        }
        stop = true
        let up = upstream
        upstream = nil
        values.removeAll(keepingCapacity: false)
        up?.cancel()
    }
}

public extension Publishers {
    struct TryRemoveDuplicates<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        public let upstream: Upstream
        public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool

        init(upstream: Upstream, predicate: @escaping (Upstream.Output, Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Failure {
            let pipe = TryRemoveDuplicatesPipe<Upstream.Failure, S>(subscriber, predicate)
            upstream.subscribe(pipe)
        }
    }
}
