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

/// A protocol that defines when and how to execute a closure.
///
/// A scheduler used to execute code as soon as possible, or after a future date.
///     Individual scheduler implementations use whatever time-keeping system makes sense for them.
///     Schdedulers express this as their `SchedulerTimeType`.
///     Since this type conforms to `SchedulerTimeIntervalConvertible`,
///     you can always express these times with the convenience functions like `.milliseconds(500)`.
///     Schedulers can accept options to control how they execute the actions passed to them.
///     These options may control factors like which threads or dispatch queues execute the actions.
public protocol Scheduler {
    /// Describes an instant in time for this scheduler.
    associatedtype SchedulerTimeType: Strideable where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible

    /// A type that defines options accepted by the scheduler.
    ///
    /// This type is freely definable by each `Scheduler`. Typically, operations that
    ///     take a `Scheduler` parameter will also take `SchedulerOptions`.
    associatedtype SchedulerOptions

    /// Returns this scheduler's definition of the current moment in time.
    var now: SchedulerTimeType { get }

    /// Returns the minimum tolerance allowed by the scheduler.
    var minimumTolerance: SchedulerTimeType.Stride { get }

    /// Performs the action at the next possible opportunity.
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date.
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
                  options: SchedulerOptions?, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date, at the specified
    ///     frequency, optionally taking into account tolerance if possible.
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
                  _ action: @escaping () -> Void) -> Cancellable
}

public extension Scheduler {
    /// Performs the action at some time after the specified date, using the scheduler’s minimum tolerance.
    @inline(__always)
    func schedule(after date: SchedulerTimeType, _ action: @escaping () -> Void) {
        self.schedule(after: date, tolerance: minimumTolerance, options: nil, action)
    }

    /// Performs the action at the next possible opportunity, without options.
    @inline(__always)
    func schedule(_ action: @escaping () -> Void) {
        self.schedule(after: now, tolerance: minimumTolerance, options: nil, action)
    }

    /// Performs the action at some time after the specified date.
    @inline(__always)
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
                  _ action: @escaping () -> Void) {
        self.schedule(after: date, tolerance: tolerance, options: nil, action)
    }

    /// Performs the action at some time after the specified date, at the specified
    ///     frequency, taking into account tolerance if possible.
    @inline(__always)
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  tolerance: SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable {
        return self.schedule(after: date, interval: interval, tolerance: tolerance, options: nil, action)
    }

    /// Performs the action at some time after the specified date, at the specified
    ///     frequency, using minimum tolerance possible for this Scheduler.
    @inline(__always)
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  _ action: @escaping () -> Void) -> Cancellable {
        return self.schedule(after: date, interval: interval, tolerance: minimumTolerance,
            options: nil, action)
    }
}