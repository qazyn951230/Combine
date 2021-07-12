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

import Atomics

private final class JustPipe<Downstream>: SourcePipe where Downstream: Subscriber {
    var demand: Subscribers.Demand = .unlimited
    let downstream: Downstream
    let input: Downstream.Input
    private var state = Atomic<Int>.make(State.initialized.rawValue)

    init(downstream: Downstream, input: Downstream.Input) {
        self.downstream = downstream
        self.input = input
    }

    func cancel() {
        state.store(State.canceled.rawValue)
    }

    func request(_ demand: Subscribers.Demand) {
        precondition(demand.rawValue >= 0)
        if state.compare(expected: State.initialized.rawValue, desired: State.finished.rawValue) {
            _ =  downstream.receive(input)
            if state.load() != State.finished.rawValue {
                downstream.receive(completion: .finished)
            }
        }
    }

    var description: String {
        "Just"
    }

    @frozen
    enum State: Int {
        case initialized = 0
        case finished = 1
        case canceled = 2
    }
}

/// A publisher that emits an output to each subscriber just once, and then finishes.
///
/// You can use a ``Just`` publisher to start a chain of publishers.
/// A ``Just`` publisher is also useful when replacing a value with ``Publishers/Catch``.
///
/// In contrast with <doc://com.apple.documentation/documentation/Swift/Result/Publisher>,
/// a ``Just`` publisher can’t fail with an error.
/// And unlike <doc://com.apple.documentation/documentation/Swift/Optional/Publisher>,
/// a ``Just`` publisher always produces a value.
public struct Just<Output>: Publisher {

    public typealias Failure = Never

    /// The one element that the publisher emits.
    public let output: Output

    /// Initializes a publisher that emits the specified output just once.
    ///
    /// - Parameter output: The one element that the publisher emits.
    public init(_ output: Output) {
        self.output = output
    }

    public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Failure {
        let pipe = JustPipe(downstream: subscriber, input: output)
        subscriber.receive(subscription: pipe)
    }
}

extension Just : Equatable where Output : Equatable {

    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    /// - Parameters:
    ///   - lhs: A `Just` publisher to compare for equality.
    ///   - rhs: Another `Just` publisher to compare for equality.
    /// - Returns: `true` if the publishers have equal `output` properties; otherwise `false`.
    public static func == (lhs: Just<Output>, rhs: Just<Output>) -> Bool {
        lhs.output == rhs.output
    }
}

extension Just where Output : Comparable {

    public func min() -> Just<Output> {
        self
    }

    public func max() -> Just<Output> {
        self
    }
}

extension Just where Output : Equatable {

    public func contains(_ output: Output) -> Just<Bool> {
        Just<Bool>(self.output == output)
    }

    public func removeDuplicates() -> Just<Output> {
        self
    }
}

extension Just {

    public func allSatisfy(_ predicate: (Output) -> Bool) -> Just<Bool> {
        Just<Bool>(predicate(output))
    }

//    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.Publisher

    public func collect() -> Just<[Output]> {
        Just<[Output]>([output])
    }

//    public func compactMap<T>(_ transform: (Output) -> T?) -> Optional<T>.Publisher

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Just<Output> {
        self
    }

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Just<Output> {
        self
    }

//    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Just<Output>.Failure>
//
//    public func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Just<Output>.Failure> where Output == S.Element, S : Sequence
//
//    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Just<Output>.Failure>
//
//    public func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Just<Output>.Failure> where Output == S.Element, S : Sequence
//
    public func contains(where predicate: (Output) -> Bool) -> Just<Bool> {
        Just<Bool>(predicate(output))
    }

//    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.Publisher

    public func count() -> Just<Int> {
        Just<Int>(1)
    }

//    public func dropFirst(_ count: Int = 1) -> Optional<Output>.Publisher
//
//    public func drop(while predicate: (Output) -> Bool) -> Optional<Output>.Publisher

    public func first() -> Just<Output> {
        self
    }

//    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.Publisher

    public func last() -> Just<Output> {
        self
    }

//    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.Publisher
//
//    public func filter(_ isIncluded: (Output) -> Bool) -> Optional<Output>.Publisher
//
//    public func ignoreOutput() -> Empty<Output, Just<Output>.Failure>
//
    public func map<T>(_ transform: (Output) -> T) -> Just<T> {
        Just<T>(transform(output))
    }

//    public func tryMap<T>(_ transform: (Output) throws -> T) -> Result<T, Error>.Publisher
//
//    public func mapError<E>(_ transform: (Just<Output>.Failure) -> E) -> Result<Output, E>.Publisher where E : Error
//
//    public func output(at index: Int) -> Optional<Output>.Publisher
//
//    public func output<R>(in range: R) -> Optional<Output>.Publisher where R : RangeExpression, R.Bound == Int
//
//    public func prefix(_ maxLength: Int) -> Optional<Output>.Publisher
//
//    public func prefix(while predicate: (Output) -> Bool) -> Optional<Output>.Publisher
//
//    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Just<Output>.Failure>.Publisher
//
//    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.Publisher

    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Just<Output> {
        self
    }

//    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Result<Output, Error>.Publisher

    public func replaceError(with output: Output) -> Just<Output> {
        self
    }

    public func replaceEmpty(with output: Output) -> Just<Output> {
        self
    }

    public func retry(_ times: Int) -> Just<Output> {
        self
    }

//    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Just<Output>.Failure>.Publisher
//
//    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.Publisher
//
//    public func setFailureType<E>(to failureType: E.Type) -> Result<Output, E>.Publisher where E : Error
}
