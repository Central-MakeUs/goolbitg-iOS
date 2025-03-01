//
//  GroupChallengeListElementEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/14/25.
//

import Foundation

@available(*, deprecated, message: "새로 만든 관계로 제거되었습니다.")
struct GroupChallengeListElementEntity: Entity {
    let groupID: String
    let groupTitle: String
    let currentUserCount: String
    let hashTags: [String]
}
