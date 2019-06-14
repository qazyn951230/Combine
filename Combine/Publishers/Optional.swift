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

private final class OptionalPipe<Downstream>: Pipe where Downstream: Subscriber {
    typealias Input = Downstream.Input
    typealias Failure = Downstream.Failure

    var stop = false
    let downstream: Downstream
    let result: Result<Input?, Failure>

    init(_ downstream: Downstream, _ result: Result<Input?, Failure>) {
        self.downstream = downstream
        self.result = result
    }

    var description: String {
        return "Optional"
    }

    func request(_ demand: Subscribers.Demand) {
        assert(demand.many, "Optional should not request `none` element.")
        switch result {
        case let .failure(e):
            forward(failure: e)
        case let .success(v):
            if let value = v {
                forward(value)
            }
            forwardFinished()
        }
    }
    
    func forward() {
        if case let .failure(e) = result {
            forward(failure: e)
        }
    }
}

public extension Publishers {

    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// If `result` is `.success`, and the value is non-nil, then `Optional` waits until receiving a request for
    //      at least 1 value before sending the output. If `result` is `.failure`,
    //      then `Optional` sends the failure immediately upon subscription.
    //      If `result` is `.success` and the value is nil, then `Optional` sends
    ///     `.finished` immediately upon subscription.
    ///
    /// In contrast with `Just`, an `Optional` publisher can send an error.
    /// In contrast with `Once`, an `Optional` publisher can send zero values and finish normally,
    //      or send zero values and fail with an error.
    struct Optional<Output, Failure>: Publisher where Failure: Error {

        /// The result to deliver to each subscriber.
        public let result: Result<Output?, Failure>

        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output?, Failure>) {
            self.result = result
        }

        public init(_ output: Output?) {
            result = Result.success(output)
        }

        public init(_ failure: Failure) {
            result = Result.failure(failure)
        }

        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            let pipe = OptionalPipe(subscriber, result)
            subscriber.receive(subscription: pipe)
            pipe.forward()
        }
    }
}

@inline(__always)
internal func createOptional<Output, Failure>(_ method: () throws -> Output?)
        -> Publishers.Optional<Output, Failure> where Failure: Error {
    do {
        return Publishers.Optional<Output, Failure>(try method())
    } catch let error as Failure {
        return Publishers.Optional<Output, Failure>(error)
    } catch let e {
        fatalError("\(e)")
    }
}

extension Publishers.Optional: Equatable where Output: Equatable, Failure: Equatable {
    public static func ==(lhs: Publishers.Optional<Output, Failure>,
                          rhs: Publishers.Optional<Output, Failure>) -> Bool {
        return lhs.result == rhs.result
    }
}

public extension Publishers.Optional where Output: Equatable {
    func contains(_ output: Output) -> Publishers.Optional<Bool, Failure> {
        switch result {
        case let .success(value):
            if let temp = value {
                return Publishers.Optional(temp == output)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

    func removeDuplicates() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

public extension Publishers.Optional where Output: Comparable {
    func min() -> Publishers.Optional<Output, Failure> {
        return self
    }

    func max() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

public extension Publishers.Optional {
    func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(predicate(output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func collect() -> Publishers.Optional<[Output], Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional([output])
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(transform(output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try transform(output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func contains(where predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(predicate(output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func count() -> Publishers.Optional<Int, Failure> {
        return Publishers.Optional(1)
    }

    func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(count < 1 ? output : nil)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(predicate(output) ? nil : output)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output) ? nil : output
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func first() -> Publishers.Optional<Output, Failure> {
        return self
    }

    func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(predicate(output) ? output : nil)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output) ? output : nil
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func last() -> Publishers.Optional<Output, Failure> {
        return self
    }

    func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(predicate(output) ? output : nil)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output) ? output : nil
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(isIncluded(output) ? output : nil)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try isIncluded(output) ? output : nil
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }


    func map<T>(_ transform: (Output) -> T) -> Publishers.Optional<T, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(transform(output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Optional<T, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try transform(output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Optional<Output, E> where E: Error {
        switch result {
        case let .success(value):
            return Publishers.Optional(value)
        case let .failure(error):
            return Publishers.Optional(transform(error))
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
            if let output = value {
                return Publishers.Optional(predicate(output) ? output : nil)
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try predicate(output) ? value : nil
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(nextPartialResult(initialResult, output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T)
            -> Publishers.Optional<T, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try nextPartialResult(initialResult, output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }


    func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch result {
        case let .success(value):
            return Publishers.Optional(value)
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func replaceError(with output: Output) -> Publishers.Optional<Output, Never> {
        switch result {
        case let .success(value):
            return Publishers.Optional(value)
        case .failure:
            return Publishers.Optional(output)
        }
    }


    func replaceEmpty(with output: Output) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func retry(_ times: Int) -> Publishers.Optional<Output, Failure> {
        return self
    }

    func retry() -> Publishers.Optional<Output, Failure> {
        return self
    }

    func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        switch result {
        case let .success(value):
            if let output = value {
                return Publishers.Optional(nextPartialResult(initialResult, output))
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }


    func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T)
            -> Publishers.Optional<T, Error> {
        switch result {
        case let .success(value):
            if let output = value {
                return createOptional {
                    try nextPartialResult(initialResult, output)
                }
            } else {
                return Publishers.Optional(nil)
            }
        case let .failure(error):
            return Publishers.Optional(error)
        }
    }

}

public extension Publishers.Optional where Failure == Never {
    func setFailureType<E>(to failureType: E.Type) -> Publishers.Optional<Output, E> where E: Error {
        switch result {
        case let .success(value):
            return Publishers.Optional(value)
        case .failure:
            // Nop
            return Publishers.Optional(nil)
        }
    }
}
