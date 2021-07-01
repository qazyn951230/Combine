// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension Subscribers {
    /// A requested number of items, sent to a publisher from a subscriber through the subscription.
    @frozen
    public struct Demand: Equatable, Comparable, Hashable, Codable, CustomStringConvertible {
        @usableFromInline
        let rawValue: UInt

        @inline(__always)
        @inlinable
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        @inline(__always)
        private init(_ value: UInt) {
            rawValue = min(UInt(Int.max) + 1, value)
        }

        /// A request for as many values as the publisher can produce.
        public static let unlimited = Demand(rawValue: UInt(Int.max) + 1)

        /// A request for no elements from the publisher.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static let none = Demand.max(0)

        /// Creates a demand for the given maximum number of elements.
        ///
        /// The publisher is free to send fewer than the requested maximum number of elements.
        ///
        /// - Parameter value: The maximum number of elements.
        ///   Providing a negative value for this parameter results in a fatal error.
        @inlinable
        public static func max(_ value: Int) -> Demand {
            precondition(value >= 0, "demand cannot be negative")
            return Demand(value: UInt(value))
        }

        public var description: String {
            self == .unlimited ? "unlimited" : "max(\(rawValue))"
        }

        /// Returns the result of adding two demands.
        /// When adding any value to `.unlimited`, the result is `.unlimited`.
        @inlinable
        public static func +(lhs: Demand, rhs: Demand) -> Demand

        /// Adds two demands, and assigns the result to the first demand.
        ///
        /// When adding any value to `.unlimited`, the result is `.unlimited`.
        @inlinable
        public static func +=(lhs: inout Demand, rhs: Demand)

        /// Returns the result of adding an integer to a demand.
        ///
        /// When adding any value to `.unlimited`, the result is `.unlimited`.
        @inlinable
        public static func +(lhs: Demand, rhs: Int) -> Demand

        /// Adds an integer to a demand, and assigns the result to the demand.
        ///
        /// When adding any value to `.unlimited`, the result is `.unlimited`.
        @inlinable
        public static func +=(lhs: inout Demand, rhs: Int)

        /// Returns the result of multiplying a demand by an integer.
        ///
        /// When multiplying any value by `.unlimited`, the result is `.unlimited`. If
        /// the multiplication operation overflows, the result is `.unlimited`.
        public static func *(lhs: Demand, rhs: Int) -> Demand

        /// Multiplies a demand by an integer, and assigns the result to the demand.
        ///
        /// When multiplying any value by `.unlimited`, the result is `.unlimited`. If
        /// the multiplication operation overflows, the result is `.unlimited`.
        @inlinable
        public static func *=(lhs: inout Demand, rhs: Int)

        /// Returns the result of subtracting one demand from another.
        ///
        /// When subtracting any value (including `.unlimited`) from `.unlimited`, the result is still `.unlimited`. Subtracting `.unlimited` from any value (except `.unlimited`) results in `.max(0)`. A negative demand is impossible; when an operation would result in a negative value, Combine adjusts the value to `.max(0)`.
        @inlinable
        public static func -(lhs: Demand, rhs: Demand) -> Demand

        /// Subtracts one demand from another, and assigns the result to the first demand.
        ///
        /// When subtracting any value (including `.unlimited`) from `.unlimited`, the result is still `.unlimited`. Subtracting `.unlimited` from any value (except `.unlimited`) results in `.max(0)`. A negative demand is impossible; when an operation would result in a negative value, Combine adjusts the value to `.max(0)`.
        @inlinable
        public static func -=(lhs: inout Demand, rhs: Demand)

        /// Returns the result of subtracting an integer from a demand.
        ///
        /// When subtracting any value from `.unlimited`, the result is still `.unlimited`. A negative demand is possible, but be aware that it isn't usable when requesting values in a subscription.
        @inlinable
        public static func -(lhs: Demand, rhs: Int) -> Demand

        /// Subtracts an integer from a demand, and assigns the result to the demand.
        ///
        /// When subtracting any value from `.unlimited`, the result is still `.unlimited`. A negative demand is impossible; when an operation would result in a negative value, Combine adjusts the value to `.max(0)`.
        @inlinable
        public static func -=(lhs: inout Demand, rhs: Int)

        /// Returns a Boolean that indicates whether the demand requests more than the given number of elements.
        ///
        /// If `lhs` is `.unlimited`, then the result is always `true`. Otherwise, the operator compares the demand’s `max` value to `rhs`.
        @inlinable
        public static func >(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean that indicates whether the first demand requests more or the same number of elements as the second.
        ///
        /// If `lhs` is `.unlimited`, then the result is always `true`. Otherwise, the operator compares the demand’s `max` value to `rhs`.
        @inlinable
        public static func >=(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean that indicates a given number of elements is greater than the maximum specified by the demand.
        ///
        /// If `rhs` is `.unlimited`, then the result is always `false`. Otherwise, the operator compares the demand’s `max` value to `lhs`.
        @inlinable
        public static func >(lhs: Int, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates a given number of elements is greater than or equal to the maximum specified by the demand.
        ///
        /// If `rhs` is `.unlimited`, then the result is always `false`. Otherwise, the operator compares the demand’s `max` value to `lhs`.
        @inlinable
        public static func >=(lhs: Int, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates whether the demand requests fewer than the given number of elements.
        ///
        /// If `lhs` is `.unlimited`, then the result is always `false`. Otherwise, the operator compares the demand’s `max` value to `rhs`.
        @inlinable
        public static func <(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean that indicates a given number of elements is less than the maximum specified by the demand.
        ///
        /// If `rhs` is `.unlimited`, then the result is always `true`. Otherwise, the operator compares the demand’s `max` value to `lhs`.
        @inlinable
        public static func <(lhs: Int, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates whether the demand requests fewer or the same number of elements as the given integer.
        ///
        /// If `lhs` is `.unlimited`, then the result is always `false`. Otherwise, the operator compares the demand’s `max` value to `rhs`.
        @inlinable
        public static func <=(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean value that indicates a given number of elements is less than or equal the maximum specified by the demand.
        ///
        /// If `rhs` is `.unlimited`, then the result is always `true`. Otherwise, the operator compares the demand’s `max` value to `lhs`.
        @inlinable
        public static func <=(lhs: Int, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates whether the first demand requests fewer elements than the second.
        ///
        /// If both sides are `.unlimited`, the result is always `false`. If `lhs` is `.unlimited`, then the result is always `false`. If `rhs` is `.unlimited` then the result is always `true`. Otherwise, this operator compares the demands’ `max` values.
        @inlinable
        public static func <(lhs: Demand, rhs: Demand) -> Bool

        /// Returns a Boolean value that indicates whether the first demand requests fewer or the same number of elements as the second.
        ///
        /// If both sides are `.unlimited`, the result is always `true`. If `lhs` is `.unlimited`, then the result is always `false`. If `rhs` is unlimited then the result is always `true`. Otherwise, this operator compares the demands’ `max` values.
        @inlinable
        public static func <=(lhs: Demand, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates whether the first demand requests more or the same number of elements as the second.
        ///
        /// If both sides are `.unlimited`, the result is always `true`. If `lhs` is `.unlimited`, then the result is always `true`. If `rhs` is `.unlimited` then the result is always `false`. Otherwise, this operator compares the demands’ `max` values.
        @inlinable
        public static func >=(lhs: Demand, rhs: Demand) -> Bool

        /// Returns a Boolean that indicates whether the first demand requests more elements than the second.
        ///
        /// If both sides are `.unlimited`, the result is always `false`. If `lhs` is `.unlimited`, then the result is always `true`. If `rhs` is `.unlimited` then the result is always `false`. Otherwise, this operator compares the demands’ `max` values.
        @inlinable
        public static func >(lhs: Demand, rhs: Demand) -> Bool

        /// Returns a Boolean value that indicates whether a demand requests the given number of elements.
        ///
        /// An `.unlimited` demand doesn’t match any integer.
        @inlinable
        public static func ==(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean value that indicates whether a demand isn't equal to an integer.
        ///
        /// The `.unlimited` value isn’t equal to any integer.
        @inlinable
        public static func !=(lhs: Demand, rhs: Int) -> Bool

        /// Returns a Boolean value that indicates whether a given number of elements matches the request of a given demand.
        ///
        /// An `.unlimited` demand doesn’t match any integer.
        @inlinable
        public static func ==(lhs: Int, rhs: Demand) -> Bool

        /// Returns a Boolean value that indicates whether an integer is unequal to a demand.
        ///
        /// The `.unlimited` value isn’t equal to any integer.
        @inlinable
        public static func !=(lhs: Int, rhs: Demand) -> Bool

        @inlinable
        public static func == (lhs: Demand, rhs: Demand) -> Bool {
            lhs.rawValue == rhs.rawValue
        }

        /// The number of requested values.
        ///
        /// The value is `nil` if the demand is ``Subscribers/Demand/unlimited``.
        @inlinable
        public var max: Int? {
            self == .unlimited ? nil : Int(rawValue)
        }

        public init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer().decode(UInt.self)
            self.init(value)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}
