//
//  AnalysisSummaryDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisSummaryDTO: DTO {
    /// 유저 이름
    let username: String
    /// 유저 이미지
    let imageUrl: String
    /// 퍼센테이지
    let percantage: Int
    /// 소비 유형
    let spendingType: String
}
