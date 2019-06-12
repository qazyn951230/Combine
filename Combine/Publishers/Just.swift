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

private final class JustPipe<Downstream>: Pipe, CustomStringConvertible where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let input: Input

    init(_ downstream: Downstream, _ input: Input) {
        self.downstream = downstream
        self.input = input
    }
    
    var description: String {
        return "Just"
    }

    func request(_ demand: Subscribers.Demand) {
        if demand.many {
            forward(input)
        }
        forwardFinished()
    }
}

public extension Publishers {
    struct Just<Output>: Publisher {
        public typealias Failure = Never

        public let output: Output

        public init(_ output: Output) {
            self.output = output
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = JustPipe(subscriber, output)
            subscriber.receive(subscription: pipe)
        }
    }
}

public extension Publishers.Just {
    func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T> {
        return Publishers.Just<T>(transform(output))
    }
}

extension Publishers.Just: Equatable where Output: Equatable {
    public static func ==(lhs: Publishers.Just<Output>, rhs: Publishers.Just<Output>) -> Bool {
        return lhs.output == rhs.output
    }
}
