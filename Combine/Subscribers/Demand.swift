//
//  Demand.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public extension Subscribers {
    // https://developer.apple.com/documentation/combine/subscribers/demand
    enum Demand {
        case max(Int)
        case unlimited

        public var max: Int? {
            switch self {
            case let .max(value):
                return value
            case .unlimited:
                return nil
            }
        }

        var none: Bool {
            switch self {
            case let .max(value):
                return value < 1
            case .unlimited:
                return false
            }
        }

        var many: Bool {
            switch self {
            case let .max(value):
                return value > 0
            case .unlimited:
                return true
            }
        }

        public static var none: Demand {
            return Demand.max(0)
        }

        // MAKR: Comparing Demands
    }
}
