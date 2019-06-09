//
//  Scheduler.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public protocol SchedulerTimeIntervalConvertible {
    static func microseconds(_ us: Int) -> Self
    static func milliseconds(_ ms: Int) -> Self
    static func nanoseconds(_ ns: Int) -> Self
    static func seconds(_ s: Double) -> Self
    static func seconds(_ s: Int) -> Self
}

public protocol Scheduler {
    associatedtype SchedulerTimeType : Strideable where SchedulerTimeType.Stride : SchedulerTimeIntervalConvertible
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
