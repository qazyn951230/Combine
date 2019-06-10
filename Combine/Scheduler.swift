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

public protocol SchedulerTimeIntervalConvertible {
    static func microseconds(_ us: Int) -> Self
    static func milliseconds(_ ms: Int) -> Self
    static func nanoseconds(_ ns: Int) -> Self
    static func seconds(_ s: Double) -> Self
    static func seconds(_ s: Int) -> Self
}

public protocol Scheduler {
    associatedtype SchedulerTimeType: Strideable where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible
    associatedtype SchedulerOptions

    var minimumTolerance: SchedulerTimeType.Stride { get }
    var now: SchedulerTimeType { get }

    func schedule(_ action: @escaping () -> Void)
    func schedule(after date: SchedulerTimeType, _ action: @escaping () -> Void)
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  _ action: @escaping () -> Void) -> Cancellable
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  tolerance: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride,
                  tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?,
                  _ action: @escaping () -> Void) -> Cancellable
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride,
                  _ action: @escaping () -> Void)
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void)
}
