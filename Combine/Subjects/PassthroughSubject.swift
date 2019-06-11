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

public final class PassthroughSubject<Output, Failure>: Subject where Failure: Error {
    private var subscribers = Bag<AnySubscriber<Output, Failure>>()
    private var lock = MutexLock(recursive: true)
    private var stop = false

    public init() {
        // Do nothing.
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        lock.locking {
            if stop {
                return
            }
            _ = subscribers.update(with: AnySubscriber(subscriber))
        }
    }

    public func send(_ value: Output) {
        if stop {
            return
        }
        let set = lock.locking { () -> Bag<AnySubscriber<Output, Failure>> in
            return subscribers
        }
        receive(value, set: set)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        if stop {
            return
        }
        stop = true
        let set = lock.locking { () -> Bag<AnySubscriber<Output, Failure>> in
            let temp = subscribers
            subscribers.removeAll(keepingCapacity: false)
            return temp
        }
        receive(completion: completion, set: set)
    }

    private func receive(_ input: Output, set: Bag<AnySubscriber<Output, Failure>>) {
        set.forEach { item in
            _ = item.receive(input)
        }
    }

    private func receive(completion: Subscribers.Completion<Failure>, set: Bag<AnySubscriber<Output, Failure>>) {
        set.forEach { item in
            item.receive(completion: completion)
        }
    }
}
