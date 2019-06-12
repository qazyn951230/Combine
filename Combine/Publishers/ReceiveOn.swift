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

private final class ReceiveOnPipe<Downstream, Context>: UpstreamPipe
    where Downstream: Subscriber, Context: Scheduler {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let options: Context.SchedulerOptions?
    let scheduler: Context

    init(_ downstream: Downstream, _ options: Context.SchedulerOptions?, _ scheduler: Context) {
        self.downstream = downstream
        self.options = options
        self.scheduler = scheduler
    }

    func receive(subscription: Subscription) {
        assert(upstream == nil)
        upstream = subscription
        scheduler.schedule(options: options) {
            self.downstream.receive(subscription: self)
        }
    }
}

public extension Publishers {
    /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
    struct ReceiveOn<Upstream, Context>: Publisher where Upstream: Publisher, Context: Scheduler {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let options: Context.SchedulerOptions?
        public let scheduler: Context
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = ReceiveOnPipe(subscriber, options, scheduler)
            subscriber.receive(subscription: pipe)
        }
    }
}
