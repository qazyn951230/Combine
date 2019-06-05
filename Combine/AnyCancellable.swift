//
//  AnyCancellable.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

final public class AnyCancellable: Cancellable {
    private var _cancel: (() -> Void)?

    public init(_ cancel: @escaping () -> Void) {
        _cancel = cancel
    }

    public init<C>(_ canceller: C) where C : Cancellable {
        _cancel = {
            canceller.cancel()
        }
    }

    final public func cancel() {
        _cancel?()
        _cancel = nil
    }
}
