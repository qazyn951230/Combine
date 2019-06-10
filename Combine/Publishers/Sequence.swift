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

private final class SequencePipe<Elements, Downstream>: Pipe
    where Downstream: Subscriber, Elements: Swift.Sequence, Downstream.Input == Elements.Element {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let input: Elements
    var _iterator: Elements.Iterator?

    init(_ downstream: Downstream, _ input: Elements) {
        self.downstream = downstream
        self.input = input
    }

    func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        var breaked = false
        var iterator = _iterator ?? input.makeIterator()
        _iterator = iterator
        switch demand {
        case let .max(count):
            var index = 0
            while let next = iterator.next(), index < count {
                let ask = forward(next)
                if ask.none {
                    breaked = true
                    break
                }
                index += 1
            }
        case .unlimited:
            while let next = iterator.next() {
                let ask = forward(next)
                if ask.none {
                    breaked = true
                    break
                }
            }
        }
        if iterator.next() == nil || breaked {
            forwardFinished()
        }
    }

    func cancel() {
        stop = true
        _iterator = nil
    }
}

public extension Publishers {
    struct Sequence<Elements, Failure>: Publisher where Elements: Swift.Sequence, Failure: Error {
        public typealias Output = Elements.Element

        public let sequence: Elements

        public init(sequence: Elements) {
            self.sequence = sequence
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = SequencePipe(subscriber, sequence)
            subscriber.receive(subscription: pipe)
        }
    }
}
