//
//  ChallengeTrippleEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/2/25.
//

import Foundation
import Domain

public struct ChallengeTrippleEntity: Entity {
    public let challengeTitle: String
    public let imageURL: URL?
    public let userName: String
    public let dayCountWithStatus: String
    public let challengeStatus: [ChallengeStatusCase]
    public let currentPeopleChallengeState: String
    public let weekAvgText: String
    public let fullDays: String
    public let cancelBool: Bool
    
    /// 스켈레톤 세팅
    public static var getSelf: Self {
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
