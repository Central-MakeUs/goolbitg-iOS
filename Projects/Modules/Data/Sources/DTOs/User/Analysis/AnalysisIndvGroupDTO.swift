//
//  AnalysisIndvGroupDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisIndvGroupDTO: DTO {
    /// 메시지
    let message: String
    /// 개인 점수
    let indvScore: Double
    /// 그룹 점수
    let groupScore: Double
}
