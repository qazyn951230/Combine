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

private final class FuturePipe<Downstream>: Pipe where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure
    typealias Parent = Publishers.Future<Input, Failure>

    var stop = false
    let downstream: Downstream
    var result: Result<Input, Failure>?

    init(_ downstream: Downstream) {
        self.downstream = downstream
    }

    var description: String {
        return "Future"
    }

    func fulfill(result: Result<Input, Failure>) {
        if self.result != nil {
            return
        }
        self.result = result
        switch result {
        case let .success(value):
            forward(value)
            forwardFinished()
        case let .failure(error):
            forward(failure: error)
        }
    }
}

public extension Publishers {

    /// A publisher that eventually produces one value and then finishes or fails.
    final class Future<Output, Failure>: Publisher where Failure: Error {
        private let fulfill: (@escaping (Result<Output, Failure>) -> Void) -> Void

        public init(_ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void) {
            self.fulfill = attemptToFulfill
        }

        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            let pipe = FuturePipe(subscriber)
            subscriber.receive(subscription: pipe)
            fulfill(pipe.fulfill(result:))
        }
    }
}
