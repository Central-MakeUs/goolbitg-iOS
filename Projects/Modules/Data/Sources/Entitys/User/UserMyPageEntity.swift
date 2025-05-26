//
//  UserMyPageEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/31/25.
//

import Foundation
import Domain

public struct UserMyPageEntity: Entity {
    public let nickname: String
    public let typeDetail: String
    public let spandingScore: String
    public let totalChallengeCount: String
    public let shareImageUrl: URL?
    public let writeCount: String
    public let nextGoolbTitle: String
    public let nextGoolBPercent: Double
    public let userID: String
    public let userTypeImageUrl: String?
    
    public init(
        nickname: String,
        typeDetail: String,
        spandingScore: String,
        totalChallengeCount: String,
        shareImageUrl: URL?,
        writeCount: String,
        nextGoolbTitle: String,
        nextGoolBPercent: Double,
        userID: String,
        userTypeImageUrl: String?
    ) {
        self.nickname = nickname
        self.typeDetail = typeDetail
        self.spandingScore = spandingScore
        self.totalChallengeCount = totalChallengeCount
        self.shareImageUrl = shareImageUrl
        self.writeCount = writeCount
        self.nextGoolbTitle = nextGoolbTitle
        self.nextGoolBPercent = nextGoolBPercent
        self.userID = userID
        self.userTypeImageUrl = userTypeImageUrl
    }
    
    public static var getSelf: Self {
        return UserMyPageEntity(
            nickname: UserDefaultsManager.userNickname,
            typeDetail: "",
            spandingScore: "",
            totalChallengeCount: "",
            shareImageUrl: nil,
            writeCount: "",
            nextGoolbTitle: "",
            nextGoolBPercent: 0,
            userID: "",
            userTypeImageUrl: nil
        )
    }
}
