//
//  SpendingTypeDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import Foundation

// MARK: - SpendingType
struct SpendingTypeDTO: DTO, Equatable {
    /// 소비 유형 ID
    let id: Int
    /// 소비 유형 이름 (예: "자린고비 굴비")
    let title: String
    /// 소비 유형 관련 이미지 URL
    let imageURL: String?
    /// 프로필 이미지
    let profileUrl: String?
    /// 소비유형 분석결과 이미지
    let onboardingResultUrl: String?
    /// 다음단계까지 남은 금액
    let goal: Int?
    /// 같은 유형 사람 수
    let peopleCount: Int?

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
