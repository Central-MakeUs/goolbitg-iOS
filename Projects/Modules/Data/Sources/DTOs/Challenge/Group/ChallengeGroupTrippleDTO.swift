//
//  ChallengeGroupTrippleDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 7/19/25.
//

import Foundation
import Domain

public struct ChallengeGroupTrippleDTO: DTO {
    /// 몇번째 연속 도전 중인지 나타내는 수
    let duration: Int
    
    let check1: ChallengeStatusCaseDTO
    let check2: ChallengeStatusCaseDTO
    let check3: ChallengeStatusCaseDTO
    
    /// 오늘 날짜가 몇 번째인지 나타내는 수
    let location: Int
    /// 취소 여부
    let canceled: Bool? // Null 로 올떄가 존재
}
