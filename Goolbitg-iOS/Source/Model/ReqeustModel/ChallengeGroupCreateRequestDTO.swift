//
//  ChallengeGroupCreateRequestDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/10/25.
//

import Foundation

struct ChallengeGroupCreateRequestDTO: Equatable, Encodable {
    /// 생성할 유저의 아이디
    let ownerId: String
    /// 챌린지 그룹 이름
    let title: String
    /// 해시태그
    let hashTags: [String]
    /// 최대 크기
    let maxSize: Int
    /// imageURL
    let imageURL: String?
    /// 비밀방 여부 true
    let isHidden: Bool?
    /// 비밀번호
    let password: Int?
}
