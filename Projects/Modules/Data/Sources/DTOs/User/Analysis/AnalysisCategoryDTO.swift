//
//  AnalysisCategoryDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisCategoryDTO: DTO {
    /// 메시지
    let message: String
    /// 카테고리 점수
    let scores: [CategoryScoreDTO]
}

public struct CategoryScoreDTO: DTO {
   /// 카테고리 이름
   let catName: String
   /// 총 점수
   let total: Int
   /// 성공 점수
   let success: Int
} 