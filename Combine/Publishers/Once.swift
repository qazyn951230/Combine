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

private final class OncePipe<Downstream>: Pipe, CustomStringConvertible where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let result: Result<Input, Failure>

    init(_ downstream: Downstream, _ result: Result<Input, Failure>) {
        self.downstream = downstream
        self.result = result
    }

    var description: String {
        return "Once"
    }

    func request(_ demand: Subscribers.Demand) {
        assert(demand.many, "Once should not request `none` element.")
        // TODO: forward failure immediately
        switch result {
        case let .failure(e):
            forward(failure: e)
        case let .success(v):
            forward(v)
            forwardFinished()
        }
    }
}

public extension Publishers {
    /// A publisher that publishes an output to each subscriber exactly once then finishes,
    //      or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value
    //      before sending the output. If `result` is `.failure`, then `Once` sends the failure
    ///     immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    struct Once<Output, Failure>: Publisher where Failure: Error {

        /// The result to deliver to each subscriber.
        public let result: Result<Output, Failure>

        /// Creates a publisher that delivers the specified result.
        ///
        /// If the result is `.success`, the `Once` publisher sends the specified output to
        ///     all subscribers and finishes normally. If the result is `.failure`,
        ///     then the publisher fails immediately with the specified error.
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output, Failure>) {
            self.result = result
        }

        /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
        ///
        /// - Parameter output: The output to deliver to each subscriber.
        public init(_ output: Output) {
            result = Result.success(output)
        }

        /// Creates a publisher that immediately terminates upon subscription with the given failure.
        ///
        /// - Parameter failure: The failure to send when terminating.
        public init(_ failure: Failure) {
            result = Result.failure(failure)
        }

        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            let pipe = OncePipe(subscriber, result)
            subscriber.receive(subscription: pipe)
        }
    }
}

@inline(__always)
internal func createOnce<Output, Failure>(_ method: () throws -> Output)
        -> Publishers.Once<Output, Failure> where Failure: Error {
    do {
        return Publishers.Once<Output, Failure>(try method())
    } catch let error as Failure {
        return Publishers.Once<Output, Failure>(error)
    } catch let e {
        fatalError("\(e)")
    }
}

extension Publishers.Once: Equatable where Output: Equatable, Failure: Equatable {
    public static func ==(lhs: Publishers.Once<Output, Failure>, rhs: Publishers.Once<Output, Failure>) -> Bool {
        return lhs.result == rhs.result
    }
}

public extension Publishers.Once where Output: Equatable {
    func contains(_ output: Output) -> Publishers.Once<Bool, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(value == output)
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func removeDuplicates() -> Publishers.Once<Output, Failure> {
        return self
    }
}

public extension Publishers.Once where Output: Comparable {
    func min() -> Publishers.Once<Output, Failure> {
        return self
    }

    func max() -> Publishers.Once<Output, Failure> {
        return self
    }
}

public extension Publishers.Once {
    func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(predicate(value))
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        switch result {
        case let .success(value):
            return createOnce {
                try predicate(value)
            }
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func collect() -> Publishers.Once<[Output], Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once([value])
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(transform(value))
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try transform(value)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    func contains(where predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(predicate(value))
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        switch result {
        case let .success(value):
            return createOnce {
                try predicate(value)
            }
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func count() -> Publishers.Once<Int, Failure> {
        switch result {
        case .success:
            return Publishers.Once(1)
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(count < 1 ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(predicate(value) ? nil : value)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try predicate(value) ? nil : value
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func first() -> Publishers.Once<Output, Failure> {
        return self
    }

    func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(predicate(value) ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try predicate(value) ? value : nil
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func last() -> Publishers.Once<Output, Failure> {
        return self
    }

    func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(predicate(value) ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try predicate(value) ? value : nil
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(isIncluded(value) ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try isIncluded(value) ? value : nil
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    func map<T>(_ transform: (Output) -> T) -> Publishers.Once<T, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(transform(value))
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        switch result {
        case let .success(value):
            return createOnce {
                try transform(value)
            }
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Once<Output, E> where E: Error {
        switch result {
        case let .success(value):
            return Publishers.Once(value)
        case let .failure(error):
            return Publishers.Once(transform(error))
        }
    }

    func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(index == 0 ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R: RangeExpression, R.Bound == Int {
        switch result {
        case let .success(value):
            return Publishers.Optional(range.contains(0) ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(maxLength > 1 ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Optional(predicate(value) ? value : nil)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return createOptional {
                try predicate(value) ? value : nil
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(nextPartialResult(initialResult, value))
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        switch result {
        case let .success(value):
            return createOnce {
                try nextPartialResult(initialResult, value)
            }
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        switch result {
        case let .success(value):
            return Publishers.Once(value)
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func replaceError(with output: Output) -> Publishers.Once<Output, Never> {
        switch result {
        case let .success(value):
            return Publishers.Once(value)
        case .failure:
            return Publishers.Once(output)
        }
    }

    func replaceEmpty(with output: Output) -> Publishers.Once<Output, Failure> {
        return self
    }

    func retry(_ times: Int) -> Publishers.Once<Output, Failure> {
        return self
    }

    func retry() -> Publishers.Once<Output, Failure> {
        return self
    }

    func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        switch result {
        case let .success(value):
            return Publishers.Once(nextPartialResult(initialResult, value))
        case let .failure(error):
            return Publishers.Once(error)
        }
    }

    func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        switch result {
        case let .success(value):
            return createOnce {
                try nextPartialResult(initialResult, value)
            }
        case let .failure(error):
            return Publishers.Once(error)
        }
    }
}

public extension Publishers.Once where Failure == Never {
    func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E: Error {
        switch result {
        case let .success(value):
            return Publishers.Once(value)
        case let .failure(error):
            if let e = error as? E {
                return Publishers.Once(e)
            } else {
                fatalError("\(error)")
            }
        }
    }
}
