//
//  ChallengeGroupDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/25/25.
//

import Foundation

/// 챌린지 그룹 DTO
///
/// 챌린지 그룹 아이디, 생성자, 제목, 해시태그, 최대 인원, 참여 인구수, 이미지 URL String
struct ChallengeGroupDTO: DTO {
    
    /// 챌린지 그룹 아이디
    let id: Int
    
    /// 챌린지 생성자 ID
    let ownerId: String
    
    /// 챌린지 제목
    let title: String
    
    /// 해시태그들
    let hashtags: [String]
    
    /// 최대 인원
    let maxSize: Int
    
    /// 참여 인원수
    let peopleCount: Int
    
    /// 그룹 대표 이미지
    let imageUrl: String
    
    /// 비밀방 여부
    let isHidden: Bool
    
    /// 비밀번호
    ///
    /// minimum: 4, maximum: 4
    let password: String?
    
}
