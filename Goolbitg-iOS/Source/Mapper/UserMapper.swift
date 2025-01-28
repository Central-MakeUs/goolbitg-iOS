//
//  UserMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import ComposableArchitecture

final class UserMapper: Sendable {
    
    /// 유형 결과 Mapping
    /// - Parameter model: 유저 전체 모델
    /// - Returns: 결과 뷰에 쓸 모델
    func resultHabitMapping(model: UserInfoDTO) -> UserHabitResultEntity {
        var url: URL? = nil
        if let imageURLString = model.spendingType.imageURL{
            url = URL(string: imageURLString)
        }
        
        return UserHabitResultEntity(
            topTitle: model.nickname + "님은\n" + model.spendingType.title + " 유형입니다",
            stepTitle: String(model.spendingType.id) + "단계 굴비",
            nameTitle: model.spendingType.title,
            imageUrl: url,
            spendingScore: String(model.spendingHabitScore) + "점",
            sameCount: String(model.spendingType.peopleCount ?? 0) + "명"
        )
    }
    
}

extension UserMapper: DependencyKey {
    static let liveValue: UserMapper = UserMapper()
}

extension DependencyValues {
    var userMapper: UserMapper {
        get { self[UserMapper.self] }
        set { self[UserMapper.self] = newValue }
    }
}

