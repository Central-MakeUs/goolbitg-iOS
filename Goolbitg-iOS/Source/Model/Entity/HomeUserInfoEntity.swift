//
//  HomeUserInfoEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation

struct HomeUserInfoEntity: Entity {
    let nickName: String
    let saveMoney: Int
    let awardText: String
    let chickenCount: String
    
    static var getSelf: Self {
        return HomeUserInfoEntity(
            nickName: UserDefaultsManager.userNickname,
            saveMoney: 0,
            awardText: "0일째 달성중",
            chickenCount: "치킨 0마리만큼 아꼈어요"
        )
    }
}
