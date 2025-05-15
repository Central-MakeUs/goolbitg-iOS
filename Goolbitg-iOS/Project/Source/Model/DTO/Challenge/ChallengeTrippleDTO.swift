//
//  ChallengeTrippleDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation

struct ChallengeTrippleDTO: DTO {
    /// 챌린지 정보
    let challenge: ChallengeListElementDTO
    /// 몇번째 연속 도전 중인지 나타내는 수
    let duration: Int
    
    let check1: ChallengeStatusCaseDTO
    let check2: ChallengeStatusCaseDTO
    let check3: ChallengeStatusCaseDTO
    
    /// 오늘 날짜가 몇 번째인지 나타내는 수
    let location: Int
    /// 취소 여부
    let canceled: Bool?
}
