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
/// - SeeAlso: [The Combine Library Reference]
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

    func subscribe<S>(_ subject: S) -> AnyCancellable where S: Subject, Failure == S.Failure, Output == S.Output {
        let subscriber = AnySubscriber(subject)
        receive(subscriber: subscriber)
        return AnyCancellable {
            subject.send(completion: Subscribers.Completion.finished)
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
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
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
        return Publishers.TryComparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
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
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
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
        return Publishers.TryComparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
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

    /// Publishes a single Boolean value that indicates whether all received elements
    ///     pass a given error-throwing predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element.
    ///     If the predicate returns `false`, the publisher produces a `false` value and finishes.
    ///     If the upstream publisher finishes normally, this publisher produces a `true` value and finishes.
    ///     If the predicate throws an error, the publisher fails, passing the error to its downstream.
    ///     As a `reduce`-style operator, this publisher produces at most one value.
    /// Backpressure note: Upon receiving any request greater than zero,
    ///     this publisher requests unlimited elements from the upstream publisher.
    /// - Parameter predicate:  A closure that evaluates each received element.
    ///         Return `true` to continue, or `false` to cancel the upstream and complete.
    ///         The closure may throw, in which case the publisher cancels the upstream publisher and
    ///         fails with the thrown error.
    /// - Returns:  A publisher that publishes a Boolean value that indicates whether
    ///         all received elements pass a given predicate.
    func tryAllSatisfy(_ predicate: @escaping (Output) throws -> Bool) -> Publishers.TryAllSatisfy<Self> {
        return Publishers.TryAllSatisfy(upstream: self, predicate: predicate)
    }

    // MARK: - Applying Sequence Operations to Elements

    /// Ignores elements from the upstream publisher until it receives an element from a second publisher.
    ///
    /// This publisher requests a single value from the upstream publisher,
    ///     and it ignores (drops) all elements from that publisher until the upstream publisher produces a value.
    ///     After the `other` publisher produces an element, this publisher cancels its subscription to
    ///     the `other` publisher, and allows events from the `upstream` publisher to pass through.
    /// After this publisher receives a subscription from the upstream publisher,
    ///     it passes through backpressure requests from downstream to the upstream publisher.
    ///     If the upstream publisher acts on those requests before the other publisher produces an item,
    ///     this publisher drops the elements it receives from the upstream publisher.
    ///
    /// - Parameter publisher: A publisher to monitor for its first emitted element.
    /// - Returns: A publisher that drops elements from the upstream publisher until
    ///         the `other` publisher produces a value.
    func drop<P>(untilOutputFrom publisher: P) -> Publishers.DropUntilOutput<Self, P>
        where P: Publisher, Self.Failure == P.Failure {
        return Publishers.DropUntilOutput(upstream: self, other: publisher)
    }

    // MARK: - Combining Elements from Multiple Publishers

    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///     returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    func combineLatest<P, T>(_ other: P, _ transform: @escaping (Output, P.Output) -> T)
            -> Publishers.CombineLatest<Self, P, T> where P : Publisher, Failure == P.Failure {
        return Publishers.CombineLatest(a: self, b: other, transform: transform)
    }

    /// Subscribes to two additional publishers and invokes a closure upon
    ///     receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///     returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    func combineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q,
                                _ transform: @escaping (Output, P.Output, Q.Output) -> T)
            -> Publishers.CombineLatest3<Self, P, Q, T>
        where P : Publisher, Q : Publisher, Failure == P.Failure, P.Failure == Q.Failure {
        return Publishers.CombineLatest3(a: self, b: publisher1, c: publisher2, transform: transform)
    }

    /// Subscribes to three additional publishers and invokes a closure upon
    ///     receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///     returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    func combineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R,
                                   _ transform: @escaping (Output, P.Output, Q.Output, R.Output) -> T)
            -> Publishers.CombineLatest4<Self, P, Q, R, T> where P : Publisher, Q : Publisher, R : Publisher,
            Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return Publishers.CombineLatest4(a: self, b: publisher1, c: publisher2, d: publisher3, transform: transform)
    }

    /// Subscribes to an additional publisher and invokes an error-throwing closure upon
    ///     receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error.
    ///     `Self.Failure` and `P.Failure` must both be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///         returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    func tryCombineLatest<P, T>(_ other: P, _ transform: @escaping (Output, P.Output) throws -> T)
            -> Publishers.TryCombineLatest<Self, P, T> where P : Publisher, P.Failure == Error {
        return Publishers.TryCombineLatest(a: self, b: other, transform: transform)
    }

    /// Subscribes to two additional publishers and invokes an error-throwing closure upon
    ///     receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error.
    ///     `Self.Failure` and `P.Failure` must both be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///         returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    func tryCombineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q,
                                   _ transform: @escaping (Output, P.Output, Q.Output) throws -> T)
            -> Publishers.TryCombineLatest3<Self, P, Q, T>
        where P : Publisher, Q : Publisher, P.Failure == Error, Q.Failure == Error {
        return Publishers.TryCombineLatest3(a: self, b: publisher1, c: publisher2, transform: transform)
    }

    /// Subscribes to three additional publishers and invokes an error-throwing closure upon
    ///     receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers.
    ///     However, it still obeys the demand-fulfilling rule of only sending the request amount downstream.
    ///     If the demand isn’t `.unlimited`, it drops values from upstream publishers.
    ///     It implements this by using a buffer size of 1 for each upstream,
    ///     and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error.
    ///     `Self.Failure` and `P.Failure` must both be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish.
    ///     If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and
    ///         returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    func tryCombineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R,
                                      _ transform: @escaping (Output, P.Output, Q.Output, R.Output) throws -> T)
            -> Publishers.TryCombineLatest4<Self, P, Q, R, T>
        where P : Publisher, Q : Publisher, R : Publisher, P.Failure == Error, Q.Failure == Error, R.Failure == Error {
        return Publishers.TryCombineLatest4(a: self, b: publisher1, c: publisher2, d: publisher3, transform: transform)
    }

    // MARK: - Controlling Timing

    /// Measures and emits the time interval between events received from an upstream publisher.
    ///
    /// The output type of the returned scheduler is the time interval of the provided scheduler.
    /// - Parameters:
    ///   - scheduler: The scheduler on which to deliver elements.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher that emits elements representing the time interval between the elements it receives.
    func measureInterval<S>(using scheduler: S, options: S.SchedulerOptions? = nil)
            -> Publishers.MeasureInterval<Self, S> where S: Scheduler {
        // TODO: Scheduler options?
        return Publishers.MeasureInterval(upstream: self, scheduler: scheduler)
    }

    // MARK: - Creating Reference-type Publishers

    /// Returns a publisher as a class instance.
    ///
    /// The downstream subscriber receives elements and completion states unchanged from
    ///     the upstream publisher. Use this operator when you want to use reference semantics,
    ///     such as storing a publisher instance in a property.
    ///
    /// - Returns: A class instance that republishes its upstream publisher.
    func share() -> Publishers.Share<Self> {
        return Publishers.Share(upstream: self)
    }

    // MARK: - Instance Methods

    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return AnyPublisher(self)
    }

    /// Prints log messages for all publishing events.
    ///
    /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
    /// - Returns: A publisher that prints log messages for all publishing events.
    func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Publishers.Print<Self> {
        return Publishers.Print(upstream: self, prefix: prefix, to: stream)
    }

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values,
    ///     prior to returning the subscriber.
    /// - parameter receiveComplete: The closure to execute on completion.
    ///         If `nil`, the sink uses an empty closure.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A subscriber that performs the provided closures upon receiving values or completion.
    func sink(receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
              receiveValue: @escaping ((Output) -> Void)) -> Subscribers.Sink<Self> {
        return Subscribers.Sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
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
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: <)
    }

    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items,
    ///     it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher,
    ///         after the upstream publisher finishes.
    func min() -> Publishers.Comparison<Self> {
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: >)
    }
}
