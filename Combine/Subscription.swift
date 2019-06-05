//
//  Subscription.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

/// A protocol representing the connection of a subscriber to a publisher.
/// - Remark: https://developer.apple.com/documentation/combine/subscription
public protocol Subscription: Cancellable, CustomCombineIdentifierConvertible {
    /// Tells a publisher that it may send more values to the subscriber.
    func request(_ demand: Subscribers.Demand)
}
