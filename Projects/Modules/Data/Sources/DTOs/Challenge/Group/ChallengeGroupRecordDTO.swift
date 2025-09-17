//
//  ChallengeGroupRecordDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 9/17/25.
//

import Foundation
import Domain

/// 3일치 그룹 챌린지 상태를 표현하는 DTO
public struct ChallengeGroupRecordDTO: DTO {
    /// 챌린지 그룹 ID
    let challengeGroupId: Int
    /// 유저 아이디
    let userId: String
    /// 기록 날짜
    let date: String
    /// 상태들
    let status: ChallengeStatusCaseDTO
}
