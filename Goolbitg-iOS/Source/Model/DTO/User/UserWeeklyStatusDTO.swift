//
//  UserWeeklyStatusDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation

struct UserWeeklyStatusDTO: DTO {
    let nickname: String?
    let saving: Int?
    let continueCount: Int?
    let chickenCount: Int?
    let weekStatus: [ChallengeStatusCaseDTO]
    let todayIndex: Int?
}
