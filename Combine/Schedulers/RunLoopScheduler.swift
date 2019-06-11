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

//#if canImport(Foundation)
//import Foundation
//
//extension RunLoop: Scheduler {
//    public struct SchedulerTimeType: Strideable {
//        public struct Stride: Comparable, SignedNumeric, SchedulerTimeIntervalConvertible {
//            public typealias Magnitude = Double
//
//            public static func <(lhs: Stride, rhs: Stride) -> Bool {
//                fatalError("< has not been implemented")
//            }
//
//            public static func ==(lhs: Stride, rhs: Stride) -> Bool {
//                fatalError("== has not been implemented")
//            }
//
//            public init?<T>(exactly source: T) where T: BinaryInteger {
//            }
//
//            public private(set) var magnitude: Magnitude = 0
//
//            public static func *(lhs: Stride, rhs: Stride) -> Stride {
//                fatalError("* has not been implemented")
//            }
//
//            public static func *=(lhs: inout Stride, rhs: Stride) {
//            }
//
//            public static func +(lhs: Stride, rhs: Stride) -> Stride {
//                fatalError("+ has not been implemented")
//            }
//
//            public static func +=(lhs: inout Stride, rhs: Stride) {
//            }
//
//            public static func -(lhs: Stride, rhs: Stride) -> Stride {
//                fatalError("- has not been implemented")
//            }
//
//            public static func -=(lhs: inout Stride, rhs: Stride) {
//            }
//
//            public init(integerLiteral value: IntegerLiteralType) {
//            }
//
//            public static func microseconds(_ us: Int) -> Stride {
//                fatalError("microseconds(_:) has not been implemented")
//            }
//
//            public static func milliseconds(_ ms: Int) -> Stride {
//                fatalError("milliseconds(_:) has not been implemented")
//            }
//
//            public static func nanoseconds(_ ns: Int) -> Stride {
//                fatalError("nanoseconds(_:) has not been implemented")
//            }
//
//            public static func seconds(_ s: Double) -> Stride {
//                fatalError("seconds(_:) has not been implemented")
//            }
//
//            public static func seconds(_ s: Int) -> Stride {
//                fatalError("seconds(_:) has not been implemented")
//            }
//        }
//
//        public func distance(to other: SchedulerTimeType) -> Stride {
//            fatalError("distance(to:) has not been implemented")
//        }
//
//        public func advanced(by n: Stride) -> SchedulerTimeType {
//            fatalError("advanced(by:) has not been implemented")
//        }
//    }
//
//    /// Returns this scheduler's definition of the current moment in time.
//    var now: SchedulerTimeType {
//
//    }
//
//    /// Returns the minimum tolerance allowed by the scheduler.
//    var minimumTolerance: SchedulerTimeType.Stride {
//
//    }
//
//    /// Performs the action at the next possible opportunity.
//    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void)
//
//    /// Performs the action at some time after the specified date.
//    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
//                  options: SchedulerOptions?, _ action: @escaping () -> Void)
//
//    /// Performs the action at some time after the specified date, at the specified
//    /// frequency, optionally taking into account tolerance if possible.
//    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
//                  tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
//                  _ action: @escaping () -> Void) -> Cancellable
//}
//
//#endif
