//
//  CombineIdentifier.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public struct CombineIdentifier: CustomStringConvertible, Hashable {
    public init() {
    }

    public init(_ object: AnyObject) {

    }

    public var description: String {
        return "CombineIdentifier: \(hashValue)"
    }

    public func hash(into hasher: inout Hasher) {
    }
}
