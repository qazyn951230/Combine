//
//  ConnectablePublisher.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/6.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

/// A publisher that provides an explicit means of connecting and canceling publication.
/// https://developer.apple.com/documentation/combine/connectablepublisher
public protocol ConnectablePublisher: Publisher {
    func connect() -> Cancellable
    func autoconnect() -> Publishers.Autoconnect<Self>
}

public extension ConnectablePublisher {
    func autoconnect() -> Publishers.Autoconnect<Self> {
        return Publishers.Autoconnect(self)
    }
}
