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

private final class CollectByTimePipe<Input, Downstream, Context>: UpstreamPipe
    where Downstream: Subscriber, Downstream.Input == [Input], Context: Scheduler {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    var result: [Input] = []
    let scheduler: Context
    let timeout: Context.SchedulerTimeType.Stride
    let count: Int?
    let options: Context.SchedulerOptions?
    var now: Context.SchedulerTimeType?

    init(_ downstream: Downstream, _ strategy: Publishers.TimeGroupingStrategy<Context>,
         _ options: Context.SchedulerOptions?) {
        self.downstream = downstream
        self.options = options
        switch strategy {
        case let .byTime(c, s):
            scheduler = c
            timeout = s
            count = nil
        case let .byTimeOrCount(c, s, n):
            scheduler = c
            timeout = s
            count = n
        }
    }

    var description: String {
        return "CollectByTime"
    }

    @inline(__always)
    func isTimeout() -> Bool {
        let _now = now ?? scheduler.now
        now = _now
        return !(_now < scheduler.now)
    }

    func request(_ demand: Subscribers.Demand) {
        if stop || isTimeout() {
            return
        }
        if let _count = count {
            upstream?.request(demand * _count)
        } else {
            upstream?.request(Subscribers.Demand.unlimited)
        }
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop || isTimeout() {
            return Subscribers.Demand.none
        }
        result.append(input)
        if let _count = count {
            let max = result.count - _count
            if max == 0 {
                let temp = result
                result.removeAll(keepingCapacity: true)
                _ = forward(temp)
            }
            return Subscribers.Demand.max(max > 0 ? max : _count)
        } else {
            return Subscribers.Demand.unlimited
        }
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
}

public extension Publishers {
    /// A strategy for collecting received elements.
    ///
    /// - byTime: Collect and periodically publish items.
    /// - byTimeOrCount: Collect and publish items, either periodically or when a buffer reaches its maximum size.
    enum TimeGroupingStrategy<Context> where Context: Scheduler {
        case byTime(Context, Context.SchedulerTimeType.Stride)
        case byTimeOrCount(Context, Context.SchedulerTimeType.Stride, Int)
    }

    /// A publisher that buffers and periodically publishes its items.
    struct CollectByTime<Upstream, Context>: Publisher where Upstream: Publisher, Context: Scheduler {
        public typealias Output = [Upstream.Output]
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The strategy with which to collect and publish elements.
        public let strategy: TimeGroupingStrategy<Context>

        /// `Scheduler` options to use for the strategy.
        public let options: Context.SchedulerOptions?

        init(upstream: Upstream, strategy: TimeGroupingStrategy<Context>, options: Context.SchedulerOptions?) {
            self.upstream = upstream
            self.strategy = strategy
            self.options = options
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure,
            S.Input == [Upstream.Output] {
            let pipe = CollectByTimePipe(subscriber, strategy, options)
            upstream.subscribe(pipe)
        }
    }
}
