//
//  Subscriptions.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class EmptySubscription: Subscription {
    func cancel() {
        // Do nothing.
    }
    
    func request(_ demand: Subscribers.Demand) {
        // Do nothing.
    }
}

public enum Subscriptions {
    public static var empty: Subscription {
        return EmptySubscription()
    }
}
