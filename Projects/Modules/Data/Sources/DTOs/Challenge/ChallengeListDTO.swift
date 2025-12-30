//
//  ChallengeListDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Domain

// MARK: - ChallengeListDTO
public struct ChallengeListDTO<D: DTO>: DTO {
    /// 총 아이템 수
    public let totalSize: Int
    /// 총 페이지 수
    public let totalPages: Int
    /// 아이템 수
    public let size: Int
    /// 페이지 번호
    public let page: Int
    /// 챌린지 아이템들
    public let items: [D]
    
    /// 총 챌린지 리워드
    public let totalReward: Int?
}
