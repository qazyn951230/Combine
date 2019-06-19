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

#if canImport(Dispatch)
import Dispatch

extension DispatchTime: Strideable {
    public struct Stride: SchedulerTimeIntervalConvertible, Comparable, SignedNumeric {
        // Numeric
        public typealias Magnitude = Int

        // Numeric nanoseconds
        public let magnitude: Int

        public init(_ value: Int) {
            self.magnitude = value
        }

        // Numeric
        public init?<T>(exactly source: T) where T: BinaryInteger {
            guard let value = Int(exactly: source) else {
                return nil
            }
            self.magnitude = value
        }

        public init(integerLiteral value: Int) {
            self.magnitude = value
        }

        var interval: DispatchTimeInterval {
            return DispatchTimeInterval.nanoseconds(magnitude)
        }

        public static func microseconds(_ us: Int) -> Stride {
            return Stride(Int(us) * 1000_000)
        }

        public static func milliseconds(_ ms: Int) -> Stride {
            return Stride(Int(ms) * 1000)
        }

        public static func nanoseconds(_ ns: Int) -> Stride {
            return Stride(Int(ns))
        }

        public static func seconds(_ s: Double) -> Stride {
            return Stride(Int(s * 1000_000_000))
        }

        public static func seconds(_ s: Int) -> Stride {
            return Stride(Int(s) * 1000_000_000)
        }

        // Equatable
        public static func ==(lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude == rhs.magnitude
        }

        // Comparable
        public static func <(lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude < rhs.magnitude
        }

        public static func >(lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude > rhs.magnitude
        }

        public static func <=(lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude <= rhs.magnitude
        }

        public static func >=(lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude >= rhs.magnitude
        }

        // Numeric
        public static func *(lhs: Stride, rhs: Stride) -> Stride {
            return Stride(lhs.magnitude * rhs.magnitude)
        }

        public static func *=(lhs: inout Stride, rhs: Stride) {
            lhs = Stride(lhs.magnitude * rhs.magnitude)
        }

        // AdditiveArithmetic
        public static func +(lhs: Stride, rhs: Stride) -> Stride {
            return Stride(lhs.magnitude + rhs.magnitude)
        }

        public static func +=(lhs: inout Stride, rhs: Stride) {
            lhs = Stride(lhs.magnitude + rhs.magnitude)
        }

        public static func -(lhs: Stride, rhs: Stride) -> Stride {
            return Stride(lhs.magnitude - rhs.magnitude)
        }

        public static func -=(lhs: inout Stride, rhs: Stride) {
            lhs = Stride(lhs.magnitude - rhs.magnitude)
        }
    }

    public func advanced(by n: Stride) -> DispatchTime {
        return DispatchTime(uptimeNanoseconds: uptimeNanoseconds.advanced(by: n.magnitude))
    }

    public func distance(to other: DispatchTime) -> Stride {
        return Stride(uptimeNanoseconds.distance(to: other.uptimeNanoseconds))
    }
}

extension DispatchQueue: Scheduler {
    public typealias SchedulerTimeType = DispatchTime
    public typealias SchedulerOptions = Never

    /// Returns this scheduler's definition of the current moment in time.
    public var now: SchedulerTimeType {
        return DispatchTime.now()
    }

    /// Returns the minimum tolerance allowed by the scheduler.
    public var minimumTolerance: SchedulerTimeType.Stride {
        return SchedulerTimeType.Stride(0)
    }

    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        async {
            action()
        }
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?, _ action: @escaping () -> Void) {
        asyncAfter(deadline: date) {
            action()
        }
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                         tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
                         _ action: @escaping () -> Void) -> Cancellable {
        let source = DispatchSource.makeTimerSource(queue: self)
        assert(interval.magnitude > 0)
//        assert(tolerance.value >= 0)
        source.schedule(deadline: date, repeating: interval.interval, leeway: tolerance.interval)
        // Is there a retain cycle?
        // source -> eventHandler -> token -> ref -> source
        var ref: DispatchSourceTimer? = source
        let token = AnyCancellable {
            ref?.cancel()
            ref = nil
        }
        source.setEventHandler(handler: {
            if token.canceled {
                return
            }
            action()
        })
        source.resume()
        return token
    }
}

#endif
