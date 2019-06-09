//
//  Subscriber.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public protocol Subscriber: CustomCombineIdentifierConvertible {
    /// The kind of values this subscriber receives.
    associatedtype Input
    /// The kind of errors this subscriber might receive.
    ///
    /// Use `Never` if this `Subscriber` cannot receive errors.
    associatedtype Failure: Error

    // MARK: - Receiving Elements

    /// Tells the subscriber that the publisher has produced an element.
    /// - Parameters:
    ///   - input: The published element.
    /// - Returns: A Demand instance indicating how many more elements
    ///     the subcriber expects to receive.
    func receive(_ input: Input) -> Subscribers.Demand

    // MARK: - Receiving Life Cycle Events

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    func receive(subscription: Subscription)

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    func receive(completion: Subscribers.Completion<Failure>)
}
