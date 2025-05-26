//
//  TCA+Extension.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/22/25.
//

import Foundation
import ComposableArchitecture

/// TCA Sendable 대처 안되있음으로 해당 방법으로 처리
extension DispatchQueue.SchedulerTimeType.Stride: @retroactive @unchecked Sendable {}
