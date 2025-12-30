//
//  UserWeeklyStatusElementDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation
import Domain

public struct UserWeeklyStatusElementDTO: DTO {
    /// 달성해야 할 총 챌린지 개수
    let totalChallenges: Int?
    /// 달성한 총 챌린지 개수
    let achievedChallenges: Int?
}
