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

private final class CollectByCountPipe<Input, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Downstream.Input == [Input] {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    var result: [Input] = []
    let count: Int

    init(_ downstream: Downstream, _ count: Int) {
        self.downstream = downstream
        self.count = count
        result.reserveCapacity(count)
    }

    func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        upstream?.request(demand * count)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        result.append(input)
        let max = result.count - count
        if max == 0 {
            let temp = result
            result.removeAll(keepingCapacity: true)
            _ = forward(temp)
        }
        return Subscribers.Demand.max(max > 0 ? max: count)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case let .failure(e):
            forward(failure: e)
        case .finished:
            if !result.isEmpty {
                _ = forward(result)
            }
            forwardFinished()
        }
    }

    func cancel() {
        if stop {
            assert(upstream == nil)
            assert(result.isEmpty)
            return
        }
        stop = true
        let up = upstream
        upstream = nil
        result.removeAll(keepingCapacity: false)
        up?.cancel()
    }
}

public extension Publishers {
    /// A publisher that buffers a maximum number of items.
    /// - SeeAlso: [The Combine Library Reference]
    ///     (https://developer.apple.com/documentation/combine/publishers/collectbycount)
    struct CollectByCount<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = [Upstream.Output]
        public typealias Failure = Upstream.Failure

        public let count: Int
        public let upstream: Upstream

        init(upstream: Upstream, count: Int) {
            self.upstream = upstream
            self.count = count
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = CollectByCountPipe(subscriber, count)
            upstream.subscribe(pipe)
        }
    }
}
