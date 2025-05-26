//
//  HomeUserInfoEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import Domain

public struct HomeUserInfoEntity: Entity {
    public let nickName: String
    public let saveMoney: Int
    public let awardText: String
    public let chickenCount: String
    
    public init(
        nickName: String,
        saveMoney: Int,
        awardText: String,
        chickenCount: String
    ) {
        self.nickName = nickName
        self.saveMoney = saveMoney
        self.awardText = awardText
        self.chickenCount = chickenCount
    }
    
    public static var getSelf: Self {
        return HomeUserInfoEntity(
            nickName: UserDefaultsManager.userNickname,
            saveMoney: 0,
            awardText: "0일째 달성중",
            chickenCount: "치킨 0마리만큼 아꼈어요"
        )
    }
}
