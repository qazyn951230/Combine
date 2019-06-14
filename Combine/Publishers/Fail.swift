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

private final class FailPipe<Downstream>: Pipe where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure
    
    var stop = true
    let downstream: Downstream
    
    init(_ downstream: Downstream) {
        self.downstream = downstream
    }
    
    var description: String {
        return "Fail"
    }
}

public extension Publishers {

    /// A publisher that immediately terminates with the specified error.
    struct Fail<Output, Failure>: Publisher where Failure: Error {

        /// The failure to send when terminating the publisher.
        public let error: Failure

        /// Creates a publisher that immediately terminates with the specified failure.
        ///
        /// - Parameter error: The failure to send when terminating the publisher.
        public init(error: Failure) {
            self.error = error
        }

        /// Creates publisher with the given output type, that immediately terminates with the specified failure.
        ///
        /// Use this initializer to create a `Fail` publisher that can work with subscribers or
        ///     publishers that expect a given output type.
        /// - Parameters:
        ///   - outputType: The output type exposed by this publisher.
        ///   - failure: The failure to send when terminating the publisher.
        public init(outputType: Output.Type, failure: Failure) {
            self.error = failure
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            let pipe = FailPipe(subscriber)
            subscriber.receive(subscription: pipe)
            pipe.forward(failure: error)
        }
    }
}
