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

private final class JustPipe<Downstream>: Pipe where Downstream: Subscriber {
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
        assert(demand.many, "Just should not request `none` element.")
        forward(input)
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

extension Publishers.Just: Equatable where Output: Equatable {
    public static func ==(lhs: Publishers.Just<Output>, rhs: Publishers.Just<Output>) -> Bool {
        return lhs.output == rhs.output
    }
}

public extension Publishers.Just where Output: Equatable {
    func contains(_ output: Output) -> Publishers.Just<Bool> {
        return Publishers.Just(self.output == output)
    }

    func removeDuplicates() -> Publishers.Just<Output> {
        return self
    }
}

public extension Publishers.Just where Output: Comparable {
    func min() -> Publishers.Just<Output> {
        return self
    }

    func max() -> Publishers.Just<Output> {
        return self
    }
}

public extension Publishers.Just {
    func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return Publishers.Just(predicate(output))
    }

    func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return createOnce {
            try predicate(output)
        }
    }

    func collect() -> Publishers.Just<[Output]> {
        return Publishers.Just([output])
    }

    func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(transform(output))
    }

    func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        return createOptional {
            try transform(output)
        }
    }

    func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Just<Output> {
        return self
    }

    func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Just<Output> {
        return self
    }

    // func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure>

    // func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence

    // func append(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure>

    // func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence

    func contains(where predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return Publishers.Just(predicate(output))
    }

    func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return createOnce {
            try predicate(output)
        }
    }

    func count() -> Publishers.Just<Int> {
        return Publishers.Just(1)
    }

    func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(count < 1 ? output : nil)
    }

    func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(predicate(output) ? nil : output)
    }

    func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return createOptional {
            try predicate(output) ? nil : output
        }
    }

    func first() -> Publishers.Just<Output> {
        return self
    }

    func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(predicate(output) ? output : nil)
    }

    func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return createOptional {
            try predicate(output) ? output : nil
        }
    }

    func last() -> Publishers.Just<Output> {
        return self
    }

    func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(predicate(output) ? output : nil)
    }

    func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return createOptional {
            try predicate(output) ? output : nil
        }
    }

    func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(isIncluded(output) ? output : nil)
    }

    func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return createOptional {
            try isIncluded(output) ? output : nil
        }
    }

    func ignoreOutput() -> Publishers.Empty<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Empty()
    }

    func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T> {
        return Publishers.Just<T>(transform(output))
    }

    func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        return createOnce {
            try transform(output)
        }
    }

    func output(at index: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(index == 0 ? output : nil)
    }

    func output<R>(in range: R) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure>
        where R: RangeExpression, R.Bound == Int {
        return Publishers.Optional(range.contains(0) ? output : nil)
    }

    func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(maxLength > 1 ? output : nil)
    }

    func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(predicate(output) ? output : nil)
    }

    func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return createOptional {
            try predicate(output) ? output : nil
        }
    }

    func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T)
            -> Publishers.Once<T, Publishers.Just<Output>.Failure> {
        return Publishers.Once(nextPartialResult(initialResult, output))
    }

    func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return createOnce {
            try nextPartialResult(initialResult, output)
        }
    }

    func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        return Publishers.Once(output)
    }

    func replaceError(with output: Output) -> Publishers.Just<Output> {
        return self
    }

    func replaceEmpty(with output: Output) -> Publishers.Just<Output> {
        return self
    }

    func retry(_ times: Int) -> Publishers.Just<Output> {
        return self
    }

    func retry() -> Publishers.Just<Output> {
        return self
    }

    // TODO: Publishers.Once<T, Publishers.Just<Output>.Failure> ==  Publishers.Just<T>
    func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T)
            -> Publishers.Once<T, Publishers.Just<Output>.Failure> {
        return Publishers.Once(nextPartialResult(initialResult, output))
    }

    func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return createOnce {
            try nextPartialResult(initialResult, output)
        }
    }

    func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E: Error {
        return Publishers.Once(output)
    }
}
