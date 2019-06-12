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

/// A scheduler for performing synchronous actions.
/// - SeeAlso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/immediatescheduler)
///
/// You can only use this scheduler for immediate actions.
///     If you attempt to schedule actions after a specific date, the scheduler produces a fatal error.
public struct ImmediateScheduler: Scheduler {

    /// The time type used by the immediate scheduler.
    public struct SchedulerTimeType: Strideable {
        init() {
            // Do nothing.
        }

        /// Returns the distance to another immediate scheduler time;
        ///     this distance is always `0` in the context of an immediate scheduler.
        ///
        /// - Parameter other: The other scheduler time.
        /// - Returns: `0`, as a `Stride`.
        public func distance(to other: SchedulerTimeType) -> Stride {
            return Stride(0)
        }

        /// Advances the time by the specified amount;
        ///     this is meaningless in the context of an immediate scheduler.
        ///
        /// - Parameter n: The amount to advance by. The `ImmediateScheduler` ignores this value.
        /// - Returns: An empty `SchedulerTimeType`.
        public func advanced(by n: Stride) -> SchedulerTimeType {
            return SchedulerTimeType()
        }

        /// The increment by which the immediate scheduler counts time.
        public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable,
            SchedulerTimeIntervalConvertible {
            public typealias FloatLiteralType = Double
            public typealias IntegerLiteralType = Int
            public typealias Magnitude = Int

            public var magnitude: Int {
                return Int(value.magnitude)
            }

            internal let value: Int

            public init(_ value: Int) {
                self.value = value
            }

            public init(integerLiteral value: Int) {
                self.init(value)
            }

            public init(floatLiteral value: Double) {
                self.init(Int(value))
            }

            public init?<T>(exactly source: T) where T: BinaryInteger {
                guard let value = Int(exactly: source) else {
                    return nil
                }
                self.init(value)
            }

            public static func <(lhs: Stride, rhs: Stride) -> Bool {
                return lhs.value < rhs.value
            }

            public static func *(lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.value * rhs.value)
            }

            public static func +(lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.value + rhs.value)
            }

            public static func -(lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.value - rhs.value)
            }

            public static func -=(lhs: inout Stride, rhs: Stride) {
                lhs = Stride(lhs.value - rhs.value)
            }

            public static func *=(lhs: inout Stride, rhs: Stride) {
                lhs = Stride(lhs.value * rhs.value)
            }

            public static func +=(lhs: inout Stride, rhs: Stride) {
                lhs = Stride(lhs.value + rhs.value)
            }

            public static func seconds(_ s: Int) -> Stride {
                return Stride(0)
            }

            public static func seconds(_ s: Double) -> Stride {
                return Stride(0)
            }

            public static func milliseconds(_ ms: Int) -> Stride {
                return Stride(0)
            }

            public static func microseconds(_ us: Int) -> Stride {
                return Stride(0)
            }

            public static func nanoseconds(_ ns: Int) -> Stride {
                return Stride(0)
            }

//            public init(from decoder: Decoder) throws {
//                let container = try decoder.singleValueContainer()
//                value = try container.decode(Int.self)
//            }
//
//            public func encode(to encoder: Encoder) throws {
//                var container = encoder.singleValueContainer()
//                try container.encode(value)
//            }
//
//            public static func ==(a: Stride, b: Stride) -> Bool {
//                return a.value == b.value
//            }
        }
    }

    public typealias SchedulerOptions = Never

    /// The shared instance of the immediate scheduler.
    ///
    /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
    public static let shared = ImmediateScheduler()

    /// Returns this scheduler's definition of the current moment in time.
    public var now: SchedulerTimeType {
        return SchedulerTimeType()
    }

    /// Returns the minimum tolerance allowed by the scheduler.
    public var minimumTolerance: SchedulerTimeType.Stride {
        return SchedulerTimeType.Stride(0)
    }

    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?, _ action: @escaping () -> Void) {
        fatalError()
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                         tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
                         _ action: @escaping () -> Void) -> Cancellable {
        fatalError()
    }
}
