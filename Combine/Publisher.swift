//
//  Publisher.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public protocol Publisher {
    associatedtype Output
    associatedtype Failure: Error

    // MARK: - Working with Subscribers
    /// Attaches the specified subscriber to this publisher.
    /// - Parameters:
    ///   - subscriber: The subscriber to attach to this Publisher. After attaching,
    ///       the subscriber can start to receive values.
    ///
    /// Always call this function instead of receive(subscriber:).
    /// Adopters of Publisher must implement receive(subscriber:).
    /// The implementation of subscribe(_:) in this extension calls through to receive(subscriber:).
    func subscribe<S>(_ subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input

    /// Attaches the specified Subscriber to this Publisher.
    /// - Parameters:
    ///   - subscriber: The subscriber to attach to this Publisher. once attached it can begin to receive values.
    func subscribe<S>(_ subject: S) -> AnyCancellable where S : Subject, Failure == S.Failure, Output == S.Output

    /// This function is called to attach the specified Subscriber to this Publisher by subscribe(_:)
    /// - Parameters:
    ///   - subscriber: The subscriber to attach to this Publisher. once attached it can begin to receive values.
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input

    // MARK: - Mapping Elements
    func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Self, T>

    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure>
}

public extension Publisher {
    func subscribe<S>(_ subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        receive(subscriber: subscriber)
    }

    func subscribe<S>(_ subject: S) -> AnyCancellable where S : Subject, Failure == S.Failure, Output == S.Output {
        let subscriber = AnySubscriber(subject)
        receive(subscriber: subscriber)
        return AnyCancellable { }
    }

    func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Self, T> {
        return Publishers.Map(transform: transform, upstream: self)
    }

    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return AnyPublisher(self)
    }
}
