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

/// Declares that a type can transmit a sequence of values over time.
/// - seealso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/publisher)
public protocol Publisher {
    /// The kind of values published by this publisher.
    associatedtype Output
    /// The kind of errors this publisher might publish.
    ///
    /// Use `Never` if this `Publisher` does not publish errors.
    associatedtype Failure: Error

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input
}

public extension Publisher {
    // MARK: - Mapping Elements

    /// Attaches the specified subscriber to this publisher.
    ///
    /// Always call this function instead of `receive(subscriber:)`.
    /// Adopters of `Publisher` must implement `receive(subscriber:)`.
    /// The implementation of `subscribe(_:)` in this extension calls through to `receive(subscriber:)`.
    /// - SeeAlso: `receive(subscriber:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///         After attaching, the subscriber can start to receive values.
    func subscribe<S>(_ subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        receive(subscriber: subscriber)
    }

    /// Attaches the specified Subscriber to this Publisher.
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///         once attached it can begin to receive values.
    func subscribe<S>(_ subject: S) -> AnyCancellable where S: Subject, Failure == S.Failure, Output == S.Output {
        let subscriber = AnySubscriber(subject)
        receive(subscriber: subscriber)
        return AnyCancellable {
        }
    }

    /// Specifies the scheduler on which to perform subscribe, cancel, and request operations.
    ///
    /// In contrast with `receive(on:options:)`, which affects downstream messages, `subscribe(on:)` changes
    /// the execution context of upstream messages. In the following example, requests to `jsonPublisher` are
    /// performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
    ///
    ///     let ioPerformingPublisher == // Some publisher.
    ///     let uiUpdatingSubscriber == // Some subscriber that updates the UI.
    ///
    ///     ioPerformingPublisher
    ///         .subscribe(on: backgroundQueue)
    ///         .receiveOn(on: RunLoop.main)
    ///         .subscribe(uiUpdatingSubscriber)
    ///
    /// - Parameters:
    ///   - scheduler: The scheduler on which to receive upstream messages.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher which performs upstream operations on the specified scheduler.
    func subscribe<S>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.SubscribeOn<Self, S>
        where S: Scheduler {
        return Publishers.SubscribeOn(upstream: self, scheduler: scheduler, options: options)
    }

    func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Self, T> {
        return Publishers.Map(upstream: self, transform: transform)
    }

    func tryMap<T>(_ transform: @escaping (Output) -> T) -> Publishers.TryMap<Self, T> {
        return Publishers.TryMap(transform: transform, upstream: self)
    }

    func flatMap<T, P>(maxPublishers: Subscribers.Demand = .unlimited,
                       _ transform: @escaping (Output) -> P) -> Publishers.FlatMap<P, Self>
        where T == P.Output, P: Publisher, Failure == P.Failure {
        return Publishers.FlatMap(maxPublishers: maxPublishers, transform: transform, upstream: self)
    }

    /// Converts any failure from the upstream publisher into a new error.
    ///
    /// Until the upstream publisher finishes normally or fails with an error, the returned
    /// publisher republishes all the elements it receives.
    ///
    /// - Parameter transform: A closure that takes the upstream failure as a parameter and returns
    ///     a new error for the publisher to terminate with.
    /// - Returns: A publisher that replaces any upstream failure with a new error produced
    ///     by the `transform` closure.
    func mapError<E>(_ transform: @escaping (Failure) -> E) -> Publishers.MapError<Self, E> where E: Error {
        return Publishers.MapError(upstream: self, transform)
    }

    /// Replaces nil elements in the stream with the proviced element.
    ///
    /// - Parameter output: The element to use when replacing `nil`.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided element.
    func replaceNil<T>(with output: T) -> Publishers.Map<Self, T> where Output == T? {
        return Publishers.Map(upstream: self) {
            $0 ?? output
        }
    }

    func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Publishers.Scan<Self, T> {
        return Publishers.Scan(upstream: self, initial: initialResult, next: nextPartialResult)
    }

    func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T)
            -> Publishers.TryScan<Self, T> {
        return Publishers.TryScan(upstream: self, initial: initialResult, next: nextPartialResult)
    }

    // func setFailureType(to:)

    // MARK: - Filtering Elements

    /// Republishes all elements that match a provided closure.
    ///
    /// - Parameter isIncluded: A closure that takes one element and returns a Boolean value indicating
    ///               whether to republish the element.
    /// - Returns: A publisher that republishes all elements that satisfy the closure.
    func filter(_ isIncluded: @escaping (Output) -> Bool) -> Publishers.Filter<Self> {
        return Publishers.Filter(upstream: self, isIncluded: isIncluded)
    }

    /// Republishes all elements that match a provided error-throwing closure.
    ///
    /// If the `isIncluded` closure throws an error, the publisher fails with that error.
    ///
    /// - Parameter isIncluded:  A closure that takes one element and returns a Boolean value indicating
    ///               whether to republish the element.
    /// - Returns:  A publisher that republishes all elements that satisfy the closure.
    func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Publishers.TryFilter<Self> {
        return Publishers.TryFilter(upstream: self, isIncluded: isIncluded)
    }

    /// Calls a closure with each received element and publishes any returned optional that has a value.
    ///
    /// - Parameter transform: A closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Publishers.CompactMap<Self, T> {
        return Publishers.CompactMap(upstream: self, transform: transform)
    }

    /// Calls an error-throwing closure with each received element and
    ///   publishes any returned optional that has a value.
    ///
    /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error
    ///   to the downstream receiver as a `Failure`.
    /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    func tryCompactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Self, T> {
        return Publishers.TryCompactMap(upstream: self, transform: transform)
    }

    // func removeDuplicates()

    func removeDuplicates(by predicate: @escaping (Output, Output) -> Bool)
            -> Publishers.RemoveDuplicates<Self> {
        return Publishers.RemoveDuplicates(upstream: self, predicate: predicate)
    }

    func tryRemoveDuplicates(by predicate: @escaping (Output, Output) throws -> Bool)
            -> Publishers.TryRemoveDuplicates<Self> {
        return Publishers.TryRemoveDuplicates(upstream: self, predicate: predicate)
    }

    /// Replaces an empty stream with the provided element.
    ///
    /// If the upstream publisher finishes without producing any elements,
    ///   this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher finishes without emitting any elements.
    /// - Returns: A publisher that replaces an empty stream with the provided output element.
    func replaceEmpty(with output: Output) -> Publishers.ReplaceEmpty<Self> {
        return Publishers.ReplaceEmpty(upstream: self, output: output)
    }

    /// Replaces any errors in the stream with the provided element.
    ///
    /// If the upstream publisher fails with an error, this publisher emits the provided element,
    ///     then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher fails.
    /// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
    func replaceError(with output: Output) -> Publishers.ReplaceError<Self> {
        return Publishers.ReplaceError(upstream: self, output: output)
    }

    // MARK: - Reducing Elements

    /// Collects all received elements, and emits a single array of the collection when
    ///     the upstream publisher finishes.
    ///
    /// If the upstream publisher fails with an error, this publisher forwards the error to
    ///     the downstream receiver instead of sending its output.
    /// This publisher requests an unlimited number of elements from the upstream publisher.
    ///     It only sends the collected array to its downstream after a request whose demand is greater than 0 items.
    /// Note: This publisher uses an unbounded amount of memory to store the received values.
    ///
    /// - Returns: A publisher that collects all received items and returns them as an array upon completion.
    func collect() -> Publishers.Collect<Self> {
        return Publishers.Collect(upstream: self)
    }

    /// Collects up to the specified number of elements, and then emits a single array of the collection.
    ///
    /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of
    ///     all the items it has received. This may be fewer than `count` elements.
    /// If the upstream publisher fails with an error, this publisher forwards the error to
    ///     the downstream receiver instead of sending its output.
    /// Note: When this publisher receives a request for `.max(n)` elements,
    ///     it requests `.max(count * n)` from the upstream publisher.
    /// - Parameter count: The maximum number of received elements to buffer before publishing.
    /// - Returns: A publisher that collects up to the specified number of elements,
    ///         and then publishes them as an array.
    func collect(_ count: Int) -> Publishers.CollectByCount<Self> {
        return Publishers.CollectByCount(upstream: self, count: count)
    }

    /// Collects elements by a given strategy, and emits a single array of the collection.
    ///
    /// If the upstream publisher finishes before filling the buffer,
    ///     this publisher sends an array of all the items it has received.
    ///     This may be fewer than `count` elements.
    /// If the upstream publisher fails with an error, this publisher forwards the error
    ///     to the downstream receiver instead of sending its output.
    /// Note: When this publisher receives a request for `.max(n)` elements,
    ///     it requests `.max(count * n)` from the upstream publisher.
    /// - Parameters:
    ///   - strategy: The strategy with which to collect and publish elements.
    ///   - options: `Scheduler` options to use for the strategy.
    /// - Returns: A publisher that collects elements by a given strategy,
    ///         and emits a single array of the collection.
    func collect<S>(_ strategy: Publishers.TimeGroupingStrategy<S>, options: S.SchedulerOptions? = nil)
            -> Publishers.CollectByTime<Self, S> where S: Scheduler {
        return Publishers.CollectByTime(upstream: self, strategy: strategy, options: options)
    }

    /// Ingores all upstream elements, but passes along a completion state (finished or failed).
    ///
    /// The output type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream elements.
    func ignoreOutput() -> Publishers.IgnoreOutput<Self> {
        return Publishers.IgnoreOutput(upstream: self)
    }

    /// Applies a closure that accumulates each element of a stream and publishes a
    ///     final result upon completion.
    ///
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: A closure that takes the previously-accumulated value and
    ///         the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and
    ///         produces an accumulated value when the upstream publisher finishes.
    func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T)
            -> Publishers.Reduce<Self, T> {
        return Publishers.Reduce(upstream: self, initial: initialResult, next: nextPartialResult)
    }

    /// Applies an error-throwing closure that accumulates each element of a stream and
    ///     publishes a final result upon completion.
    ///
    /// If the closure throws an error, the publisher fails, passing the error to its subscriber.
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: An error-throwing closure that takes the previously-accumulated value and
    ///         the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and
    ///         produces an accumulated value when the upstream publisher finishes.
    func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T)
            -> Publishers.TryReduce<Self, T> {
        return Publishers.TryReduce(upstream: self, initial: initialResult, next: nextPartialResult)
    }

    // MARK: - Applying Mathematical Operations on Elements

    /// Publishes the number of elements received from the upstream publisher.
    ///
    /// - Returns: A publisher that consumes all elements until the upstream publisher finishes,
    ///         then emits a single value with the total number of elements received.
    func count() -> Publishers.Count<Self> {
        return Publishers.Count(upstream: self)
    }

    // func max()

    /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and
    ///         returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func max(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Publishers.Comparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.Comparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return areInIncreasingOrder(lhs, rhs)
            }
        }
    }

    /// Publishes the maximum value received from the upstream publisher,
    ///     using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and
    ///         returns `true` if they are in increasing order. If this closure throws,
    ///         the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func tryMax(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool)
            -> Publishers.TryComparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.TryComparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return try areInIncreasingOrder(lhs, rhs)
            }
        }
    }

    // func min()

    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and
    ///         returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func min(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Publishers.Comparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.Comparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return !areInIncreasingOrder(lhs, rhs)
            }
        }
    }

    /// Publishes the minimum value received from the upstream publisher,
    ///     using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and
    ///         returns `true` if they are in increasing order. If this closure throws,
    ///         the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func tryMin(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool)
            -> Publishers.TryComparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.TryComparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return !(try areInIncreasingOrder(lhs, rhs))
            }
        }
    }

    // MARK: - Applying Matching Criteria to Elements

    // func contains(_:)

    /// Publishes a Boolean value upon receiving an element that satisfies the predicate closure.
    ///
    /// This operator consumes elements produced from the upstream publisher until
    ///     the upstream publisher produces a matching element.
    /// - Parameter predicate: A closure that takes an element as its parameter and
    ///         returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
    /// - Returns: A publisher that emits the Boolean value `true` when
    ///         the upstream  publisher emits a matching value.
    func contains(where predicate: @escaping (Output) -> Bool) -> Publishers.ContainsWhere<Self> {
        return Publishers.ContainsWhere(upstream: self, predicate: predicate)
    }

    /// Publishes a Boolean value upon receiving an element that satisfies the throwing predicate closure.
    ///
    /// This operator consumes elements produced from the upstream publisher until
    ///     the upstream publisher produces a matching element. If the closure throws, the stream fails with an error.
    /// - Parameter predicate: A closure that takes an element as its parameter and
    ///         returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
    /// - Returns: A publisher that emits the Boolean value `true` when
    ///         the upstream publisher emits a matching value.
    func tryContains(where predicate: @escaping (Output) throws -> Bool) -> Publishers.TryContainsWhere<Self> {
        return Publishers.TryContainsWhere(upstream: self, predicate: predicate)
    }

    /// Publishes a single Boolean value that indicates whether all received elements pass a given predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element.
    ///     If the predicate returns `false`, the publisher produces a `false` value and finishes.
    //      If the upstream publisher finishes normally, this publisher produces a `true` value and finishes.
    ///     As a `reduce`-style operator, this publisher produces at most one value.
    /// Backpressure note: Upon receiving any request greater than zero,
    ///     this publisher requests unlimited elements from the upstream publisher.
    /// - Parameter predicate: A closure that evaluates each received element.
    ///         Return `true` to continue, or `false` to cancel the upstream and complete.
    /// - Returns: A publisher that publishes a Boolean value that indicates whether
    ///         all received elements pass a given predicate.
    func allSatisfy(_ predicate: @escaping (Output) -> Bool) -> Publishers.AllSatisfy<Self> {
        return Publishers.AllSatisfy(upstream: self, predicate: predicate)
    }

    // MARK: - Instance Methods
    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return AnyPublisher(self)
    }
}

public extension Publisher where Failure == Never {
    /// Changes the failure type declared by the upstream publisher.
    ///
    /// The publisher returned by this method cannot actually fail with the specified type and
    /// instead just finishes normally. Instead, you use this method when you need to match
    /// the error types of two mismatched publishers.
    ///
    /// - Parameter failureType: The `Failure` type presented by this publisher.
    /// - Returns: A publisher that appears to send the specified failure type.
    func setFailureType<E>(to failureType: E.Type) -> Publishers.SetFailureType<Self, E> where E: Error {
        return Publishers.SetFailureType(upstream: self)
    }
}

public extension Publisher where Output: Equatable {
    // Publishes only elements that don’t match the previous element.
    ///
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        return Publishers.RemoveDuplicates(upstream: self, predicate: ==)
    }

    /// Publishes a Boolean value upon receiving an element equal to the argument.
    ///
    /// The contains publisher consumes all received elements until the upstream publisher
    ///     produces a matching element. At that point, it emits `true` and finishes normally.
    ///     If the upstream finishes normally without producing a matching element,
    ///     this publisher emits `false`, then finishes.
    /// - Parameter output: An element to match against.
    /// - Returns: A publisher that emits the Boolean value `true` when
    ///         the upstream publisher emits a matching value.
    func contains(_ output: Output) -> Publishers.Contains<Self> {
        return Publishers.Contains(upstream: self, output: output)
    }
}

public extension Publisher where Output: Comparable {
    /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func max() -> Publishers.Comparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.Comparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return lhs > rhs
            }
        }
    }

    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func min() -> Publishers.Comparison<Self> {
        // TODO: Is this right?
        var send: Bool = false
        return Publishers.Comparison(upstream: self) { lhs, rhs in
            if send {
                return false
            } else {
                send = true
                return lhs < rhs
            }
        }
    }
}
