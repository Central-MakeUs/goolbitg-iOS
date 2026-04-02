//
//  AnalysisCompletionDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisCompletionDTO: DTO {
    /// 메시지
    let message: String
    /// 이전 챌린지 수
    let prev: Int
    /// 현재 챌린지 수
    let current: Int
    /// 추천 챌린지 수
    let recommandation: Int
}
