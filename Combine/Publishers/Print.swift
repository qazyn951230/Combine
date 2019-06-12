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

private final class PrintPipe<Downstream>: UpstreamPipe where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let prefix: String?
    let stream: TextOutputStream?

    init(_ downstream: Downstream, _ prefix: String, _ stream: TextOutputStream?) {
        self.downstream = downstream
        self.prefix = prefix.isEmpty ? nil : prefix
        self.stream = stream
    }

    func request(_ demand: Subscribers.Demand) {
        write("request: \(demand)")
        upstream?.request(demand)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        write("receive value: (\(input))")
        return forward(input)
    }

    func receive(subscription: Subscription) {
        assert(upstream == nil)
        upstream = subscription
        write("receive subscription: (\(subscription))")
        downstream.receive(subscription: self)
    }

    func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        if stop {
            return
        }
        switch completion {
        case let .failure(e):
            write("receive error: (\(e))")
        case .finished:
            write("receive finished")
        }
        forward(completion: completion)
    }

    func clean() {
        write("receive cancel")
    }

    private func write(_ string: String) {
        let value: String
        if let p = prefix {
            value = "\(p): \(string)"
        } else {
            value = string
        }
        if var _stream = stream {
            _stream.write(value)
        } else {
            print(value)
        }
    }
}

public extension Publishers {
    /// A publisher that prints log messages for all publishing events, optionally prefixed with a given string.
    ///
    /// This publisher prints log messages when receiving the following events:
    /// * subscription
    /// * value
    /// * normal completion
    /// * failure
    /// * cancellation
    struct Print<Upstream>: Publisher where Upstream: Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// A string with which to prefix all log messages.
        public let prefix: String

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public let stream: TextOutputStream?

        /// Creates a publisher that prints log messages for all publishing events.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - prefix: A string with which to prefix all log messages.
        public init(upstream: Upstream, prefix: String, to stream: TextOutputStream? = nil) {
            self.upstream = upstream
            self.prefix = prefix
            self.stream = stream
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure,
            Upstream.Output == S.Input {
                let pipe = PrintPipe(subscriber, prefix, stream)
                upstream.subscribe(pipe)
        }
    }
}
