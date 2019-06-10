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

private final class SetFailureTypePipe<Downstream>: UpstreamPipe
    where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Never

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?

    init(_ downstream: Downstream) {
        self.downstream = downstream
    }

    func receive(completion: Subscribers.Completion<Never>) {
        if stop {
            return
        }
        switch completion {
        case .failure:
            assert(false)
        case .finished:
            forwardFinished()
        }
    }
}

public extension Publishers {
    struct SetFailureType<Upstream, Failure>: Publisher
        where Upstream: Publisher, Failure: Error, Upstream.Failure == Never {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Creates a publisher that appears to send a specified failure type.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Failure == S.Failure, S: Subscriber, Upstream.Output == S.Input {
            let pipe = SetFailureTypePipe(subscriber)
            upstream.receive(subscriber: pipe)
        }

        public func setFailureType<E>(to failure: E.Type) -> SetFailureType<Upstream, E> where E: Error {
            return SetFailureType<Upstream, E>(upstream: upstream)
        }
    }
}
