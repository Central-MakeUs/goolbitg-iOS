//
//  UserMyPageEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/31/25.
//

import Foundation

struct UserMyPageEntity: Entity {
    let nickname: String
    let typeDetail: String
    let spandingScore: String
    let totalChallengeCount: String
    let writeCount: String
    let nextGoolbTitle: String
    let nextGoolBPercent: Double
    let userID: String
    let userTypeImageUrl: String?
    
    static var getSelf: Self {
        return UserMyPageEntity(
            nickname: UserDefaultsManager.userNickname,
            typeDetail: "",
            spandingScore: "",
            totalChallengeCount: "",
            writeCount: "",
            nextGoolbTitle: "",
            nextGoolBPercent: 0,
            userID: "",
            userTypeImageUrl: nil
        )
    }
}
