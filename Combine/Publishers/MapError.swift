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

private final class MapErrorPipe<Failure, Downstream>: UpstreamPipe
    where Downstream: Subscriber, Failure: Error {
    typealias Input = Downstream.Input

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let transform: (Failure) -> Downstream.Failure

    init(_ downstream: Downstream, _ transform: @escaping (Failure) -> Downstream.Failure) {
        self.downstream = downstream
        self.transform = transform
    }

    var description: String {
        return "MapError"
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        if stop {
            return
        }
        switch completion {
        case .finished:
            forwardFinished()
        case let .failure(error):
            forward(failure: transform(error))
        }
    }
}

public extension Publishers {
    struct MapError<Upstream, Failure>: Publisher where Upstream: Publisher, Failure: Error {
        public typealias Output = Upstream.Output

        public let transform: (Upstream.Failure) -> Failure
        public let upstream: Upstream

        public init(upstream: Upstream, _ map: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = map
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = MapErrorPipe(subscriber, transform)
            upstream.subscribe(pipe)
        }
    }
}
