//
//  Demand.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public extension Subscribers {
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    /// https://developer.apple.com/documentation/combine/subscribers/demand
    /// - Overview:
    ///   - unlimited: A request for an unlimited number of items.
    ///   - max: A request for a maximum number of items.
    enum Demand: Comparable, Equatable {
        /// Limits the maximum number of values. The Publisher may send fewer than the requested number.
        ///   Negative values will result in a fatalError.
        case max(Int)
        /// Requests as many values as the Publisher can produce.
        case unlimited

        /// Returns the number of requested values, or nil if unlimited.
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

        /// A demand for no items.
        public static var none: Demand {
            return Demand.max(0)
        }

        // MAKR: Comparing Demands
        public static func == (lhs: Demand, rhs: Demand) -> Bool {
            return lhs.max == rhs.max
        }

        /// If rhs is `.unlimited`, then the result is always false. If lhs is `.unlimited`
        ///   then the result is always false. Otherwise, the two max values are compared.
        public static func > (lhs: Demand, rhs: Demand) -> Bool {
            switch (lhs, rhs) {
            case let (.max(left), .max(right)):
                return left > right
            default:
                return false
            }
        }

        /// If lhs is `.unlimited`, then the result is always false. If rhs is `.unlimited`
        ///   then the result is always false. Otherwise, the two max values are compared.
        public static func < (lhs: Demand, rhs: Demand) -> Bool {
            switch (lhs, rhs) {
            case let (.max(left), .max(right)):
                return left < right
            default:
                return false
            }
        }

        /// If `lhs` is `.unlimited` and `rhs` is `.unlimited` then the result is true.
        ///   Otherwise, the rules for `>` are followed.
        public static func >= (lhs: Demand, rhs: Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return true
            default:
                return lhs > rhs
            }
        }

        /// If `lhs` is `.unlimited` and `rhs` is `.unlimited` then the result is true.
        ///   Otherwise, the rules for `<` are followed.
        public static func <= (lhs: Demand, rhs: Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return true
            default:
                return lhs < rhs
            }
        }

        ///  Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Demand, rhs: Int) -> Bool {
            return lhs.max != rhs
        }

        // Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Int, rhs: Demand) -> Bool {
            return lhs != rhs.max
        }

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Demand, rhs: Int) -> Bool {
            return lhs.max == rhs
        }

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Int, rhs: Demand) -> Bool {
            return lhs == rhs.max
        }

        public static func > (lhs: Demand, rhs: Int) -> Bool {
            if let left = lhs.max {
                return left > rhs
            }
            // lhs is `.unlimited`
            return true
        }

        public static func > (lhs: Int, rhs: Demand) -> Bool {
            if let right = rhs.max {
                return lhs > right
            }
            // rhs is `.unlimited`
            return false
        }

        public static func < (lhs: Demand, rhs: Int) -> Bool {
            if let left = lhs.max {
                return left < rhs
            }
            // lhs is `.unlimited`
            return false
        }

        public static func < (lhs: Int, rhs: Demand) -> Bool {
            if let right = rhs.max {
                return lhs < right
            }
            // rhs is `.unlimited`
            return true
        }

        public static func >= (lhs: Demand, rhs: Int) -> Bool {
            if let left = lhs.max {
                return left >= rhs
            }
            // lhs is `.unlimited`
            return true
        }

        public static func >= (lhs: Int, rhs: Demand) -> Bool {
            if let right = rhs.max {
                return lhs >= right
            }
            // rhs is `.unlimited`
            return false
        }

        public static func <= (lhs: Demand, rhs: Int) -> Bool {
            if let left = lhs.max {
                return left <= rhs
            }
            // lhs is `.unlimited`
            return false
        }

        public static func <= (lhs: Int, rhs: Demand) -> Bool {
            if let right = rhs.max {
                return lhs <= right
            }
            // rhs is `.unlimited`
            return true
        }
        
        public static func + (lhs: Demand, rhs: Int) -> Demand {
            switch lhs {
            case let .max(value):
                let (next, overflow) = value.addingReportingOverflow(rhs)
                if overflow {
                    return Demand.unlimited
                }
                return reportNegative(next)
            case .unlimited:
                return Demand.unlimited
            }
        }
    
        public static func - (lhs: Demand, rhs: Int) -> Demand {
            switch lhs {
            case let .max(value):
                let (next, overflow) = value.multipliedReportingOverflow(by: rhs)
                if overflow {
                    return Demand.unlimited
                }
                return reportNegative(next)
            case .unlimited:
                return Demand.unlimited
            }
        }
        
        public static func * (lhs: Demand, rhs: Int) -> Demand {
            switch lhs {
            case let .max(value):
                let (next, overflow) = value.multipliedReportingOverflow(by: rhs)
                if overflow {
                    return Demand.unlimited
                }
                return reportNegative(next)
            case .unlimited:
                return Demand.unlimited
            }
        }
        
        public static func / (lhs: Demand, rhs: Int) -> Demand {
            switch lhs {
            case let .max(value):
                let (next, overflow) = value.dividedReportingOverflow(by: rhs)
                if overflow {
                    return Demand.unlimited
                }
                return reportNegative(next)
            case .unlimited:
                return Demand.unlimited
            }
        }
        
        @inline(__always)
        static func reportNegative(_ value: Int) -> Demand {
            assert(value >= 0)
            return Demand.max(value)
        }
    }
}
