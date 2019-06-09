//
//  Publisher.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

/// Declares that a type can transmit a sequence of values over time.
/// https://developer.apple.com/documentation/combine/publisher
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
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input
}

public extension Publisher {
    /// Attaches the specified subscriber to this publisher.
    ///
    /// Always call this function instead of `receive(subscriber:)`.
    /// Adopters of `Publisher` must implement `receive(subscriber:)`.
    /// The implementation of `subscribe(_:)` in this extension calls through to `receive(subscriber:)`.
    /// - SeeAlso: `receive(subscriber:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///         After attaching, the subscriber can start to receive values.
    func subscribe<S>(_ subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        receive(subscriber: subscriber)
    }

    /// Attaches the specified Subscriber to this Publisher.
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///         once attached it can begin to receive values.
    func subscribe<S>(_ subject: S) -> AnyCancellable where S : Subject, Failure == S.Failure, Output == S.Output {
        let subscriber = AnySubscriber(subject)
        receive(subscriber: subscriber)
        return AnyCancellable { }
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
        where S : Scheduler {
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
                       where T == P.Output, P : Publisher, Failure == P.Failure {
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
        return Publishers.Map(upstream: self) { $0 ?? output }
    }
    
//    func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Scan<Self, T> {
//        
//    }

    func collect() -> Publishers.Collect<Self> {
        return Publishers.Collect(upstream: self)
    }

    func allSatisfy(_ predicate: @escaping (Output) -> Bool) -> Publishers.AllSatisfy<Self> {
        return Publishers.AllSatisfy(predicate: predicate, upstream: self)
    }

    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return AnyPublisher(self)
    }
}
