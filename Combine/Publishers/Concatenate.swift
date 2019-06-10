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

//private final class ConcatenateConnection<Prefix, Suffix, Downstream>:
//    Connection<Downstream> where Downstream: Subscriber, Prefix : Publisher, Suffix : Publisher,
//    Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output, Downstream.Input == Prefix.Output {
//    let prefix: Prefix
//    let suffix: Suffix
//    var _prefixSink: Subscribers.Sink<Prefix>?
//    var _suffixSink: Subscribers.Sink<Suffix>?
//    var prefixFinished = false
//    var suffixFinished = false
//
//    init(_ prefix: Prefix, _ suffix: Suffix, _ downstream: Downstream) {
//        self.prefix = prefix
//        self.suffix = suffix
//        super.init(downstream)
//    }
//
//    override func request(_ demand: Subscribers.Demand) {
//        if stop {
//            return
//        }
//        if !prefixFinished {
//            let prefixSink = _prefixSink ?? Subscribers.Sink(
//        } else if !suffixFinished {
//
//        } else {
//            forwardFinished()
//        }
//    }
//}

public extension Publishers {
    struct Concatenate<Prefix, Suffix>: Publisher where Prefix: Publisher, Suffix: Publisher,
    Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
        public typealias Failure = Suffix.Failure
        public typealias Output = Suffix.Output

        public let prefix: Prefix
        public let suffix: Suffix

        public init(prefix: Prefix, suffix: Suffix) {
            self.prefix = prefix
            self.suffix = suffix
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
//            let connection = ConcatenateConnection(prefix, suffix, subscriber)
//            subscriber.receive(subscription: connection)
        }
    }
}
