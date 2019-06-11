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

//#if canImport(Dispatch)
//import Dispatch
//
//extension DispatchTime: Strideable {
//    public struct Stride: Comparable, SignedNumeric {
//        internal var value: UInt64
//    }
//
//    public func advanced(by n: Stride) -> DispatchTime {
//
//    }
//
//    public func distance(to other: DispatchTime) -> Stride {
//
//    }
//}

//extension DispatchQueue: Scheduler {
//    public typealias SchedulerTimeType = DispatchTime
//    public typealias SchedulerOptions = Never
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

//#endif
