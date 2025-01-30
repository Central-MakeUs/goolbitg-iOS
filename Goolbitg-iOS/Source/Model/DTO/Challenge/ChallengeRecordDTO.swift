//
//  ChallengeRecordDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation

struct ChallengeRecordDTO: DTO {
    /// 챌린지 ID
    let challengeId: Int
    /// 유저 ID
    let userId: String
    /// 기록일
    let date: String
    /// [ WAIT, SUCCESS, FAIL ]
    let status: String
    /// 오늘 날짜가 몇 번째인지 나타내는 수 (0~2)
    let location: Int
}
