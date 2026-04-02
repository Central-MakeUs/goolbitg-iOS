//
//  UserHabitInfoEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 4/2/26.
//

import Foundation
import Domain

public struct UserHabitInfoEntity: Entity {
    /// 유저 이름
    public let userName: String
    /// 유저 유형
    public let userType: String
    /// 상위 퍼센트
    public let upperPercent: Int
    /// 이미지 주소
    public let imageURL: String
    
    public init(userName: String, userType: String, upperPercent: Int, imageURL: String) {
        self.userName = userName
        self.userType = userType
        self.upperPercent = upperPercent
        self.imageURL = imageURL
    }
}
