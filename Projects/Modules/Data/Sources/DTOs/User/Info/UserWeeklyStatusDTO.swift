//
//  UserWeeklyStatusDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import Domain

public struct UserWeeklyStatusDTO: DTO {
    let nickname: String?
    let saving: Int?
    let continueCount: Int?
    let weeklyStatus: [UserWeeklyStatusElementDTO]
    let todayIndex: Int?
}
