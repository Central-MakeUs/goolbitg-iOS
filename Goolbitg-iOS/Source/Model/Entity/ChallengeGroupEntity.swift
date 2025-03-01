//
//  ChallengeGroupEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/26/25.
//

import Foundation

struct ChallengeGroupEntity: Entity {
    /// 현재 아이디
    let id: String
    /// 제목
    let title: String
    /// 현재 인원
    let currentPersonCount: String
    /// 전체 인원:
    let totalPersonCount: String
    /// 해쉬태그
    let hashTags: [String]
    
}
