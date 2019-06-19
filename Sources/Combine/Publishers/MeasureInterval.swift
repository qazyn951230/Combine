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

private final class MeasureIntervalPipe<Input, Context, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Context: Scheduler, Downstream.Input == Context.SchedulerTimeType.Stride {
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let scheduler: Context
    var last: Context.SchedulerTimeType?

    init(_ downstream: Downstream, _ scheduler: Context) {
        self.downstream = downstream
        self.scheduler = scheduler
    }

    var description: String {
        return "MeasureInterval"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        let now = scheduler.now
        if stop {
            return Subscribers.Demand.none
        }
        if let current = last {
            let stride = now.distance(to: current)
            forward(stride)
        }
        last = now
        return Subscribers.Demand.none
    }
}

public extension Publishers {

    /// A publisher that measures and emits the time interval between events received from an upstream publisher.
    /// - SeeAlso: [The Combine Library Reference]
    ///     (https://developer.apple.com/documentation/combine/publishers/measureinterval)
    struct MeasureInterval<Upstream, Context>: Publisher where Upstream: Publisher, Context: Scheduler {
        public typealias Output = Context.SchedulerTimeType.Stride
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The scheduler on which to deliver elements.
        public let scheduler: Context

        init(upstream: Upstream, scheduler: Context) {
            self.upstream = upstream
            self.scheduler = scheduler
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure,
            S.Input == Context.SchedulerTimeType.Stride {
            let pipe = MeasureIntervalPipe<Upstream.Output, Context, S>(subscriber, scheduler)
            upstream.subscribe(pipe)
        }
    }
}
