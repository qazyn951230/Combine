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

private final class CombineLatestChildPipe<Input, Downstream>: UpstreamPipe, Locking
    where Downstream: Subscriber {

    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let lock: MutexLock
    let receiveValue: (Input) -> Void
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    var upstream: Subscription?

    init(downstream: Downstream, lock: MutexLock, receiveValue: @escaping (Input) -> Void,
         receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.downstream = downstream
        self.lock = lock
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }

    var description: String {
        return "CombineLatest"
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        synchronized {
            receiveValue(input)
        }
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        synchronized {
            receive(completion: completion)
        }
    }
}

private class CombineLatestPipe<Downstream>: Pipe, Locking where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let lock = MutexLock(recursive: true)
    var upstream: Subscription?
    var token: AnyCancellable?
    var count: Int
    private var receiveInput: [Bool]
    private var numberOfInput: Int = 0
    private var receiveCompletion: Int = 0

    init(_ downstream: Downstream, _ count: Int) {
        self.downstream = downstream
        self.count = count
        receiveInput = Array(repeating: false, count: count)
    }

    var description: String {
        return "CombineLatest"
    }

    func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        upstream?.request(demand)
    }

    func receive(subscription: Subscription) {
        assert(upstream == nil)
        upstream = subscription
        downstream.receive(subscription: self)
        subscription.request(Subscribers.Demand.unlimited)
    }

    func receiveInput(index: Int) -> Bool {
        if !receiveInput[index] {
            receiveInput[index] = true
            numberOfInput += 1
        }
        return numberOfInput == count
    }

    func receiveCompletion(index: Int, _ completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure:
            forward(completion: completion)
            cancel()
        case .finished:
            receiveCompletion += 1
            if receiveCompletion == count {
                forwardFinished()
            }
        }
    }

    func cancel() {
        if stop {
            assert(upstream == nil)
            return
        }
        stop = true
        let up = upstream
        upstream = nil
        up?.cancel()
        clean()
    }

    func clean() {
        token?.cancel()
        token = nil
    }
}

private final class CombineLatestPipe2<A, B, Downstream>: CombineLatestPipe<Downstream>
    where Downstream: Subscriber, A: Publisher, B: Publisher, A.Failure == Downstream.Failure,
    A.Failure == B.Failure {

    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    let transform: (A.Output, B.Output) -> Input
    var lastA: A.Output?
    var lastB: B.Output?

    init(_ downstream: Downstream, _ transform: @escaping (A.Output, B.Output) -> Input) {
        self.transform = transform
        super.init(downstream, 2)
    }

    func forward(a: A, b: B) {
        let aChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(a:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 0, completion)
        }
        let bChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(b:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 1, completion)
        }
        a.subscribe(aChild)
        b.subscribe(bChild)
        token = AnyCancellable {
            aChild.cancel()
            bChild.cancel()
        }
    }

    func receive(a input: A.Output) {
        lastA = input
        forwardResult(index: 0)
    }

    func receive(b input: B.Output) {
        lastB = input
        forwardResult(index: 1)
    }

    @inline(__always)
    func forwardResult(index: Int) {
        guard receiveInput(index: index) else {
            return
        }
        if let a = lastA, let b = lastB {
            forward(transform(a, b))
        }
    }
}

private final class CombineLatestPipe3<A, B, C, Downstream>: CombineLatestPipe<Downstream>
    where Downstream: Subscriber, A: Publisher, B: Publisher, C: Publisher, A.Failure == Downstream.Failure,
    A.Failure == B.Failure, A.Failure == C.Failure {

    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    let transform: (A.Output, B.Output, C.Output) -> Input
    var lastA: A.Output?
    var lastB: B.Output?
    var lastC: C.Output?

    init(_ downstream: Downstream, _ transform: @escaping (A.Output, B.Output, C.Output) -> Input) {
        self.transform = transform
        super.init(downstream, 3)
    }

    func forward(a: A, b: B, c: C) {
        let aChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(a:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 0, completion)
        }
        let bChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(b:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 1, completion)
        }
        let cChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(c:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 2, completion)
        }
        a.subscribe(aChild)
        b.subscribe(bChild)
        c.subscribe(cChild)
        token = AnyCancellable {
            aChild.cancel()
            bChild.cancel()
            cChild.cancel()
        }
    }

    func receive(a input: A.Output) {
        lastA = input
        forwardResult(index: 0)
    }

    func receive(b input: B.Output) {
        lastB = input
        forwardResult(index: 1)
    }

    func receive(c input: C.Output) {
        lastC = input
        forwardResult(index: 2)
    }

    @inline(__always)
    func forwardResult(index: Int) {
        guard receiveInput(index: index) else {
            return
        }
        if let a = lastA, let b = lastB, let c = lastC {
            forward(transform(a, b, c))
        }
    }
}

private final class CombineLatestPipe4<A, B, C, D, Downstream>: CombineLatestPipe<Downstream>
    where Downstream: Subscriber, A: Publisher, B: Publisher, C: Publisher, D: Publisher,
    A.Failure == Downstream.Failure, A.Failure == B.Failure, A.Failure == C.Failure, A.Failure == D.Failure {

    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    let transform: (A.Output, B.Output, C.Output, D.Output) -> Input
    var lastA: A.Output?
    var lastB: B.Output?
    var lastC: C.Output?
    var lastD: D.Output?

    init(_ downstream: Downstream, _ transform: @escaping (A.Output, B.Output, C.Output, D.Output) -> Input) {
        self.transform = transform
        super.init(downstream, 4)
    }

    func forward(a: A, b: B, c: C, d: D) {
        let aChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(a:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 0, completion)
        }
        let bChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(b:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 1, completion)
        }
        let cChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(c:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 2, completion)
        }
        let dChild = CombineLatestChildPipe(downstream: self, lock: lock,
            receiveValue: receive(d:)) { (completion: Subscribers.Completion<Failure>) in
            self.receiveCompletion(index: 3, completion)
        }
        a.subscribe(aChild)
        b.subscribe(bChild)
        c.subscribe(cChild)
        d.subscribe(dChild)
        token = AnyCancellable {
            aChild.cancel()
            bChild.cancel()
            cChild.cancel()
            dChild.cancel()
        }
    }

    func receive(a input: A.Output) {
        lastA = input
        forwardResult(index: 0)
    }

    func receive(b input: B.Output) {
        lastB = input
        forwardResult(index: 1)
    }

    func receive(c input: C.Output) {
        lastC = input
        forwardResult(index: 2)
    }

    func receive(d input: D.Output) {
        lastD = input
        forwardResult(index: 3)
    }

    @inline(__always)
    func forwardResult(index: Int) {
        guard receiveInput(index: index) else {
            return
        }
        if let a = lastA, let b = lastB, let c = lastC, let d = lastD {
            forward(transform(a, b, c, d))
        }
    }
}

public extension Publishers {

    /// A publisher that receives and combines the latest elements from two publishers.
    struct CombineLatest<A, B, Output>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure {
        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let transform: (A.Output, B.Output) -> Output

        init(a: A, b: B, transform: @escaping (A.Output, B.Output) -> Output) {
            self.a = a
            self.b = b
            self.transform = transform
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, B.Failure == S.Failure {
            let pipe = CombineLatestPipe2<A, B, S>(subscriber, transform)
            pipe.forward(a: a, b: b)
        }
    }

    /// A publisher that receives and combines the latest elements from three publishers.
    struct CombineLatest3<A, B, C, Output>: Publisher
        where A: Publisher, B: Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {

        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C
        public let transform: (A.Output, B.Output, C.Output) -> Output

        init(a: A, b: B, c: C, transform: @escaping (A.Output, B.Output, C.Output) -> Output) {
            self.a = a
            self.b = b
            self.c = c
            self.transform = transform
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, C.Failure == S.Failure {
            let pipe = CombineLatestPipe3<A, B, C, S>(subscriber, transform)
            pipe.forward(a: a, b: b, c: c)
        }
    }

    /// A publisher that receives and combines the latest elements from four publishers.
    struct CombineLatest4<A, B, C, D, Output>: Publisher
        where A: Publisher, B: Publisher, C: Publisher, D: Publisher,
        A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C
        public let d: D
        public let transform: (A.Output, B.Output, C.Output, D.Output) -> Output

        init(a: A, b: B, c: C, d: D, transform: @escaping (A.Output, B.Output, C.Output, D.Output) -> Output) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.transform = transform
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, D.Failure == S.Failure {
            let pipe = CombineLatestPipe4<A, B, C, D, S>(subscriber, transform)
            pipe.forward(a: a, b: b, c: c, d: d)
        }
    }
}
