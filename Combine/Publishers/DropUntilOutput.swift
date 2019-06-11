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

private final class DropUntilOutputOtherPipe<Other, Origin>: UpstreamPipe, Locking
    where Other: Publisher, Origin: Subscriber {
    typealias Downstream = DropUntilOutputPipe<Other, Origin>
    typealias Input = Other.Output
    typealias Failure = Other.Failure

    var stop = false
    let downstream: Downstream
    let lock = MutexLock(recursive: true)
    var upstream: Subscription?

    init(_ downstream: Downstream) {
        self.downstream = downstream
    }

    func receive(subscription: Subscription) {
        if stop {
            subscription.cancel()
            return
        }
        assert(upstream == nil)
        upstream = subscription
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        synchronized {
            if !stop {
                downstream.stop = false
                downstream.request(Subscribers.Demand.unlimited)
            }
            cancel()
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Other.Failure>) {
        // Do nothing.
    }
}

private final class DropUntilOutputPipe<Other, Downstream>: UpstreamPipe, Locking
    where Other: Publisher, Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = true
    let downstream: Downstream
    let lock = MutexLock(recursive: true)
    var other: Other?
    var otherPipe: DropUntilOutputOtherPipe<Other, Downstream>?
    var upstream: Subscription?

    init(_ downstream: Downstream, _ other: Other) {
        self.downstream = downstream
        self.other = other
    }

    func receive(subscription: Subscription) {
        if stop {
            subscription.cancel()
            return
        }
        assert(upstream == nil)
        upstream = subscription
        let pipe = DropUntilOutputOtherPipe(self)
        otherPipe = pipe
        other?.subscribe(pipe)
        downstream.receive(subscription: self)
    }

    func receive(_ input: Downstream.Input) -> Subscribers.Demand {
        return synchronized {
            forward(input)
        }
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        synchronized {
            forward(completion: completion)
        }
    }
}

public extension Publishers {
    /// A publisher that ignores elements from the upstream publisher until
    ///     it receives an element from second publisher.
    struct DropUntilOutput<Upstream, Other>: Publisher where Upstream: Publisher,
        Other: Publisher, Upstream.Failure == Other.Failure {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A publisher to monitor for its first emitted element.
        public let other: Other

        /// Creates a publisher that ignores elements from the upstream publisher until
        ///     it receives an element from another publisher.
        ///
        /// - Parameters:
        ///   - upstream: A publisher to drop elements from while waiting for another publisher to emit elements.
        ///   - other: A publisher to monitor for its first emitted element.
        public init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input,
            Other.Failure == S.Failure {
            let pipe = DropUntilOutputPipe(subscriber, other)
            upstream.subscribe(pipe)
        }
    }
}

extension Publishers.DropUntilOutput: Equatable where Upstream: Equatable, Other: Equatable {
    public static func ==(lhs: Publishers.DropUntilOutput<Upstream, Other>,
                          rhs: Publishers.DropUntilOutput<Upstream, Other>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.other == rhs.other
    }
}
