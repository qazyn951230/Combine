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

    var description: String {
        return "Sequence"
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

    /// A publisher that publishes a given sequence of elements.
    ///
    /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
    struct Sequence<Elements, Failure>: Publisher where Elements: Swift.Sequence, Failure: Error {
        public typealias Output = Elements.Element

        /// The sequence of elements to publish.
        public let sequence: Elements

        /// Creates a publisher for a sequence of elements.
        ///
        /// - Parameter sequence: The sequence of elements to publish.
        public init(sequence: Elements) {
            self.sequence = sequence
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let pipe = SequencePipe(subscriber, sequence)
            subscriber.receive(subscription: pipe)
        }
    }
}

public extension Publishers.Sequence {
    func allSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(sequence.allSatisfy(predicate))
    }

    func tryAllSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Once<Bool, Error> {
        return createOnce {
            try sequence.allSatisfy(predicate)
        }
    }

    func collect() -> Publishers.Once<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Once(Array(sequence))
    }

    func compactMap<T>(_ transform: (Publishers.Sequence<Elements, Failure>.Output) -> T?)
            -> Publishers.Sequence<[T], Failure> {
        return Publishers.Sequence(sequence: sequence.compactMap(transform))
    }

    func min(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output,
                                       Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(sequence.min(by: areInIncreasingOrder))
    }

    func tryMin(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output,
                                          Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return createOptional {
            try sequence.min(by: areInIncreasingOrder)
        }
    }

    func max(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output,
                                       Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(sequence.max(by: areInIncreasingOrder))
    }

    func tryMax(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output,
                                          Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return createOptional {
            try sequence.max(by: areInIncreasingOrder)
        }
    }

    func contains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(sequence.contains(where: predicate))
    }

    func tryContains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Once<Bool, Error> {
        return createOnce {
            try sequence.contains(where: predicate)
        }
    }

    func drop(while predicate: (Elements.Element) -> Bool)
            -> Publishers.Sequence<DropWhileSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: sequence.drop(while: predicate))
    }

    func dropFirst(_ count: Int = 1) -> Publishers.Sequence<DropFirstSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: sequence.dropFirst(count))
    }

    func first(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(sequence.first(where: predicate))
    }

    func tryFirst(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return createOptional {
            try sequence.first(where: predicate)
        }
    }

    func filter(_ isIncluded: (Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Sequence(sequence: sequence.filter(isIncluded))
    }

    func ignoreOutput() -> Publishers.Empty<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Empty()
    }

    func map<T>(_ transform: (Elements.Element) -> T) -> Publishers.Sequence<[T], Failure> {
        return Publishers.Sequence(sequence: sequence.map(transform))
    }

    func prefix(_ maxLength: Int) -> Publishers.Sequence<PrefixSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: sequence.prefix(maxLength))
    }

    func prefix(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<[Elements.Element], Failure> {
        return Publishers.Sequence(sequence: sequence.prefix(while: predicate))
    }

    func reduce<T>(_ initialResult: T,
                   _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T)
            -> Publishers.Once<T, Failure> {
        return Publishers.Once(sequence.reduce(initialResult, nextPartialResult))
    }

    func tryReduce<T>(_ initialResult: T,
                      _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) throws -> T)
            -> Publishers.Once<T, Error> {
        return createOnce {
            try sequence.reduce(initialResult, nextPartialResult)
        }
    }

    func replaceNil<T>(with output: T) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure>
        where Elements.Element == T? {
        return Publishers.Sequence(sequence: sequence.map {
            $0 ?? output
        })
    }

    func scan<T>(_ initialResult: T,
                 _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T)
            -> Publishers.Sequence<[T], Failure> {
        return Publishers.Sequence(sequence: sequence.scan(initialResult, nextPartialResult))
    }

    func setFailureType<E>(to error: E.Type) -> Publishers.Sequence<Elements, E> where E: Error {
        return Publishers.Sequence<Elements, E>(sequence: sequence)
    }
}

public extension Sequence {
    func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Element) throws -> T) rethrows -> [T] {
        var array: [T] = []
        var current = initialResult
        try self.forEach { element in
            current = try nextPartialResult(current, element)
            array.append(current)
        }
        return array
    }
}

public extension Sequence where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var array: [Element] = []
        self.forEach { element in
            if !array.contains(element) {
                array.append(element)
            }
        }
        return array
    }
}

public extension Collection {
    func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Element) throws -> T) rethrows -> [T] {
        var array: [T] = []
        array.reserveCapacity(self.count)
        var current = initialResult
        try self.forEach { element in
            current = try nextPartialResult(current, element)
            array.append(current)
        }
        return array
    }
}

public extension Collection where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var array: [Element] = []
        array.reserveCapacity(self.count)
        self.forEach { element in
            if !array.contains(element) {
                array.append(element)
            }
        }
        return array
    }
}

public extension RangeReplaceableCollection {
    mutating func insert<S>(contentsOf newElements: __owned S, at i: Self.Index)
        where S: Sequence, Self.Element == S.Element {
        var current = self.startIndex
        self.forEach { element in
            self.insert(element, at: current)
            current = self.index(after: current)
        }
    }
}

extension Publishers.Sequence where Elements.Element: Equatable {
    func removeDuplicates() -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Sequence(sequence: sequence.removeDuplicates())
    }

    func contains(_ output: Elements.Element) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(sequence.contains(output))
    }
}

extension Publishers.Sequence where Elements.Element: Comparable {
    func min() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(sequence.min())
    }

    func max() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(sequence.max())
    }
}

extension Publishers.Sequence where Elements: Collection {
    func first() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(sequence.first)
    }

    func count() -> Publishers.Once<Int, Failure> {
        return Publishers.Once(sequence.count)
    }

    func output(at index: Elements.Index)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        if index >= sequence.startIndex && index < sequence.endIndex {
            return Publishers.Optional(sequence[index])
        }
        return Publishers.Optional(nil)
    }

    func output(in range: Range<Elements.Index>)
            -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Sequence(sequence: Array(sequence[range]))
    }
}

extension Publishers.Sequence where Elements: BidirectionalCollection {
    func last() -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(sequence.last)
    }

    func last(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(sequence.last(where: predicate))
    }

    func tryLast(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        return createOptional {
            try sequence.last(where: predicate)
        }
    }
}

extension Publishers.Sequence where Elements: RandomAccessCollection {
    func output(at index: Elements.Index)
            -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        if index >= sequence.startIndex && index < sequence.endIndex {
            return Publishers.Optional(sequence[index])
        }
        return Publishers.Optional(nil)
    }

    func output(in range: Range<Elements.Index>)
            -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Sequence(sequence: Array(sequence[range]))
    }
}

extension Publishers.Sequence where Elements: RandomAccessCollection {
    // TODO: Optional => Once
    func count() -> Publishers.Optional<Int, Failure> {
        return Publishers.Optional(sequence.count)
    }
}

extension Publishers.Sequence where Elements: RangeReplaceableCollection {

    func prepend(_ elements: Publishers.Sequence<Elements, Failure>.Output...)
            -> Publishers.Sequence<Elements, Failure> {
        var temp = sequence
        temp.insert(contentsOf: elements, at: temp.startIndex)
        return Publishers.Sequence(sequence: temp)
    }

    func prepend<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure>
        where S: Sequence, Elements.Element == S.Element {
        var temp = sequence
        temp.insert(contentsOf: elements, at: temp.startIndex)
        return Publishers.Sequence(sequence: temp)
    }

    func prepend(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        var temp = sequence
        temp.insert(contentsOf: publisher.sequence, at: temp.startIndex)
        return Publishers.Sequence(sequence: temp)
    }

    func append(_ elements: Publishers.Sequence<Elements, Failure>.Output...)
            -> Publishers.Sequence<Elements, Failure> {
        var temp = sequence
        temp.append(contentsOf: elements)
        return Publishers.Sequence(sequence: temp)
    }

    func append<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure>
        where S: Sequence, Elements.Element == S.Element {
        var temp = sequence
        temp.append(contentsOf: elements)
        return Publishers.Sequence(sequence: temp)
    }

    func append(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        var temp = sequence
        temp.append(contentsOf: publisher.sequence)
        return Publishers.Sequence(sequence: temp)
    }
}

extension Publishers.Sequence: Equatable where Elements: Equatable {
    public static func ==(lhs: Publishers.Sequence<Elements, Failure>,
                          rhs: Publishers.Sequence<Elements, Failure>) -> Bool {
        return lhs.sequence == rhs.sequence
    }
}
