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

private class CombineLatestPipe<Downstream>: UpstreamPipe, Locking where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let lock = MutexLock(recursive: true)
    var upstream: Subscription?
    var token: AnyCancellable?
    var count: Int
    var receiveInput: [Bool]
    var receiveCompletion: [Bool]

    init(_ downstream: Downstream, _ count: Int) {
        self.downstream = downstream
        self.count = count
        receiveInput = Array(repeating: false, count: count)
        receiveCompletion = Array(repeating: false, count: count)
    }

    var description: String {
        return "CombineLatest"
    }

    func receiveInput(index: Int) {

    }

    func receiveCompletion(index: Int, _ completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure:
            forward(completion: completion)
            cancel()
        case .finished:
            receiveCompletion[index] = true
        }
    }

    @inline(__always)
    func allCompletion() -> Bool {
        return false
    }

    func forward() {
        fatalError("forward() has not been implemented")
    }

    func clean() {
        token?.cancel()
        token = nil
    }
}

private final class CombineLatestPipe2<A, B, Downstream>: UpstreamPipe
    where Downstream: Subscriber, A: Publisher, B: Publisher, A.Failure == B.Failure,
    A.Failure == Downstream.Failure {

    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    var upstream: Subscription?
    let a: A
    let b: B
    let transform: (A.Output, B.Output) -> Input
    var lastA: A.Output?
    var lastB: B.Output?
    var token: AnyCancellable?

    init(_ downstream: Downstream, _ a: A, _ b: B, _ transform: @escaping (A.Output, B.Output) -> Input) {
        self.downstream = downstream
        self.a = a
        self.b = b
        self.transform = transform
    }

    var description: String {
        return "CombineLatest"
    }

    func forward() {
        let aSink = a.sink(receiveCompletion: receiveA(completion:), receiveValue: receive(a:))
        let bSink = b.sink(receiveCompletion: receiveB(completion:), receiveValue: receive(b:))
        token = AnyCancellable {
            aSink.cancel()
            bSink.cancel()
        }
    }

    func clean() {
        token?.cancel()
        token = nil
    }

    @inline(__always)
    func forwardResult(_ a: A.Output, _ b: B.Output) {
        forward(transform(a, b))
    }

    func receive(a input: A.Output) {
        if let b = lastB {
            forwardResult(input, b)
        }
        lastA = input
    }

    func receiveA(completion: Subscribers.Completion<A.Failure>) {

    }

    func receive(b input: B.Output) {
        if let a = lastA {
            forwardResult(a, input)
        }
        lastB = input
    }

    func receiveB(completion: Subscribers.Completion<B.Failure>) {

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
            let pipe = CombineLatestPipe2(subscriber, a, b, transform)
            pipe.forward()
        }
    }

//    /// A publisher that receives and combines the latest elements from three publishers.
//    struct CombineLatest3<A, B, C, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {
//
//        /// The kind of errors this publisher might publish.
//        ///
//        /// Use `Never` if this `Publisher` does not publish errors.
//        public typealias Failure = A.Failure
//
//        public let a: A
//
//        public let b: B
//
//        public let c: C
//
//        public let transform: (A.Output, B.Output, C.Output) -> Output
//
//        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
//        ///
//        /// - SeeAlso: `subscribe(_:)`
//        /// - Parameters:
//        ///     - subscriber: The subscriber to attach to this `Publisher`.
//        ///                   once attached it can begin to receive values.
//        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, C.Failure == S.Failure
//    }
//
//    /// A publisher that receives and combines the latest elements from four publishers.
//    struct CombineLatest4<A, B, C, D, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
//
//        /// The kind of errors this publisher might publish.
//        ///
//        /// Use `Never` if this `Publisher` does not publish errors.
//        public typealias Failure = A.Failure
//
//        public let a: A
//
//        public let b: B
//
//        public let c: C
//
//        public let d: D
//
//        public let transform: (A.Output, B.Output, C.Output, D.Output) -> Output
//
//        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
//        ///
//        /// - SeeAlso: `subscribe(_:)`
//        /// - Parameters:
//        ///     - subscriber: The subscriber to attach to this `Publisher`.
//        ///                   once attached it can begin to receive values.
//        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, D.Failure == S.Failure
//    }
}
