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

protocol Pipe: AnyObject, Subscriber, Subscription, CustomStringConvertible {
    associatedtype Downstream where Downstream: Subscriber

    var stop: Bool { get set }
    var downstream: Downstream { get }

    func forward(_ input: Downstream.Input) -> Subscribers.Demand
    func forward(completion: Subscribers.Completion<Downstream.Failure>)
}

extension Pipe {
    func cancel() {
        stop = true
    }

    /// Tells a publisher that it may send more values to the subscriber.
    func request(_ demand: Subscribers.Demand) {
        // Do nothing.
    }

    /// - Parameter subscription: The upstream, see `UpstreamPipe`.
    func receive(subscription: Subscription) {
        if stop {
            return
        }
        subscription.request(Subscribers.Demand.unlimited)
    }

    @discardableResult
    func forward(_ input: Downstream.Input) -> Subscribers.Demand {
        if stop {
            return Subscribers.Demand.none
        }
        return downstream.receive(input)
    }

    func forward(completion: Subscribers.Completion<Downstream.Failure>) {
        if stop {
            return
        }
        stop = true
        downstream.receive(completion: completion)
    }

    @inline(__always)
    func forwardFinished() {
        forward(completion: Subscribers.Completion.finished)
    }

    @inline(__always)
    func forward(failure: Downstream.Failure) {
        forward(completion: Subscribers.Completion.failure(failure))
    }
}

extension Pipe where Input == Downstream.Input {
    func receive(_ input: Input) -> Subscribers.Demand {
        return forward(input)
    }
}

extension Pipe where Failure == Downstream.Failure {
    func receive(completion: Subscribers.Completion<Failure>) {
        forward(completion: completion)
    }
}

