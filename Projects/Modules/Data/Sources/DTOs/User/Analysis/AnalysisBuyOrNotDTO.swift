//
//  AnalysisBuyOrNotDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisBuyOrNotDTO: DTO {
    /// 메시지
    let message: String
    /// 구매 점수
    let buyScore: Double
    /// 비구매 점수
    let notScore: Double
}
