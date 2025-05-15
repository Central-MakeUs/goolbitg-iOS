//
//  ChallengeTrippleEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation

struct ChallengeTrippleEntity: Entity {
    let challengeTitle: String
    let imageURL: URL?
    let userName: String
    let dayCountWithStatus: String
    let challengeStatus: [ChallengeStatusCase]
    let currentPeopleChallengeState: String
    let weekAvgText: String
    let fullDays: String
    let cancelBool: Bool
    
    /// 스켈레톤 세팅
    static var getSelf: Self {
        return ChallengeTrippleEntity(
            challengeTitle: "",
            imageURL: nil,
            userName: UserDefaultsManager.userNickname,
            dayCountWithStatus: "XXXXXXXXXXX",
            challengeStatus: [.none, .none, .none],
            currentPeopleChallengeState: "XXXXXXXXXXXXXXXXXX",
            weekAvgText: "XXXXXXXXXXXXXXXXX",
            fullDays: "XXXXXXXXXXXXXX",
            cancelBool: false
        )
    }
}
