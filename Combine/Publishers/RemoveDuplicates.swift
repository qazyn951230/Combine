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

private final class RemoveDuplicatesPipe<Downstream>: UpstreamPipe, Locking where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let lock = MutexLock(recursive: true)
    let predicate: (Input, Input) -> Bool
    var values: [Input] = []

    init(_ downstream: Downstream, _ predicate: @escaping (Input, Input) -> Bool) {
        self.downstream = downstream
        self.predicate = predicate
    }

    var description: String {
        return "RemoveDuplicates"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        let newly = synchronized { () -> Bool in
            let contains = self.values.contains { (value: Input) in
                self.predicate(input, value)
            }
            if !contains {
                self.values.append(input)
            }
            return !contains
        }
        if newly {
            return forward(input)
        } else {
            return Subscribers.Demand.none
        }
    }

    func clean() {
        values.removeAll(keepingCapacity: false)
    }
}

public extension Publishers {
    struct RemoveDuplicates<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream
        public let predicate: (Upstream.Output, Upstream.Output) -> Bool

        init(upstream: Upstream, predicate: @escaping (Upstream.Output, Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure,
            Upstream.Output == S.Input {
            let pipe = RemoveDuplicatesPipe(subscriber, predicate)
            upstream.subscribe(pipe)
        }
    }
}
