//
//  ChallengeListDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation

// MARK: - ChallengeListDTO
struct ChallengeListDTO<D: DTO>: DTO {
    /// 총 아이템 수
    let totalSize: Int
    /// 총 페이지 수
    let totalPages: Int
    /// 아이템 수
    let size: Int
    /// 페이지 번호
    let page: Int
    /// 챌린지 아이템들
    let items: [D]
    
    /// 총 챌린지 리워드
    let totalReward: Int?
}
