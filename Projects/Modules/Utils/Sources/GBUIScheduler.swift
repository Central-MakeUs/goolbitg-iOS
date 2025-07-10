//
//  GBUIScheduler.swift
//  Utils
//
//  Created by Jae hyung Kim on 7/10/25.
//

import Foundation
import Combine
import Dispatch

public let GBUISchedulerInstance = GBUIScheduler()

public struct GBUIScheduler: Scheduler, Sendable {
    // option X
    public typealias SchedulerOptions = Never
    // DispatchQueue 시간을 사용
    public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    
    // MARK: Public Member
    /// 현재 시각을 반환
    public var now: SchedulerTimeType { return DispatchQueue.main.now }
    /// 지연 허용 오차
    public var minimumTolerance: SchedulerTimeType.Stride { return DispatchQueue.main.minimumTolerance }
    
    // MARK: Private Member
    /// 현재 큐가 main큐인지 판단합니다.
    private let key = DispatchSpecificKey<UInt8>()
    /// 식별값
    private let value: UInt8 = 0
    
    public init () {
        DispatchQueue.main.setSpecific(key: key, value: value)
    }
    
    /// 즉시 실행용 스케줄 함수
    /// - Parameters:
    ///   - options: options description
    ///   - action: action 을 스케줄링
    public func schedule(
        options: SchedulerOptions? = nil,
        _ action: @escaping () -> Void
    ) {
        if DispatchQueue.getSpecific(key: key) == value { // 실행중 큐가 Main일시 바로
            action()
        } else {
            DispatchQueue.main.schedule(action)
        }
    }
    
    /// 반복 실행용 스케줄링 함수
    ///
    /// 특정 시간 이후 일정 간격으로 Action 실행합니다.
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: Never?,
        _ action: @escaping () -> Void
    ) -> any Cancellable {
        DispatchQueue.main
            .schedule(
                after: date,
                interval: interval,
                tolerance: tolerance,
                options: nil,
                action
            )
    }
    
    /// 한번만 지연 실행시 스케줄링 함수
    public func schedule(
        after date: DispatchQueue.SchedulerTimeType,
        tolerance: DispatchQueue.SchedulerTimeType.Stride,
        options: Never?,
        _ action: @escaping () -> Void
    ) {
        DispatchQueue.main
            .schedule(
                after: date,
                tolerance: tolerance,
                options: nil,
                action
            )
    }
}
