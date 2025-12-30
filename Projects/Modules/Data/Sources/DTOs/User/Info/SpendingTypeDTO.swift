//
//  SpendingTypeDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation
import Domain

// MARK: - SpendingType
public struct SpendingTypeDTO: DTO, Equatable, Hashable {
    /// 소비 유형 ID
    public let id: Int
    /// 소비 유형 이름 (예: "자린고비 굴비")
    public let title: String
    /// 소비 유형 관련 이미지 URL
    public let imageURL: String?
    /// 프로필 이미지
    public let profileUrl: String?
    /// 소비유형 분석결과 이미지
    public let onboardingResultUrl: String?
    /// 다음단계까지 남은 금액
    public let goal: Int?
    /// 같은 유형 사람 수
    public let peopleCount: Int?
    
    public init(
        id: Int,
        title: String,
        imageURL: String?,
        profileUrl: String?,
        onboardingResultUrl: String?,
        goal: Int?,
        peopleCount: Int?
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.profileUrl = profileUrl
        self.onboardingResultUrl = onboardingResultUrl
        self.goal = goal
        self.peopleCount = peopleCount
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "imageUrl"
        case profileUrl
        case onboardingResultUrl
        case goal
        case peopleCount
    }
}
