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
    
    enum CodingKeys: String, CodingKey {
        case ownerId
        case title
        case hashTags
        case maxSize
        case imageURL
        case isHidden
        case password
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(title, forKey: .title)
        try container.encode(hashTags, forKey: .hashTags)
        try container.encode(maxSize, forKey: .maxSize)
        
        if let imageURL = imageURL {
            try container.encode(imageURL, forKey: .imageURL)
        }
        
        if let isHidden = isHidden {
            try container.encode(isHidden, forKey: .isHidden)
        }
        
        if let password = password {
            try container.encode(password, forKey: .password)
        }
    }
}
