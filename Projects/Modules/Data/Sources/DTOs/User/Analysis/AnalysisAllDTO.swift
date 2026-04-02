//
//  AnalysisAllDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct AnalysisAllDTO: DTO {
    let summary: AnalysisSummaryDTO
    let completionAnalysis: AnalysisCompletionDTO
    let categoryAnalysis: AnalysisCategoryDTO
    let indvGroupAnalysis: AnalysisIndvGroupDTO
    let buyOrNotAnalysis: AnalysisBuyOrNotDTO
}
