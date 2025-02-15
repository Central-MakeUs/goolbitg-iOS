//
//  GroupChallengeListElementEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/14/25.
//

import Foundation

struct GroupChallengeListElementEntity: Entity {
    let groupID: String
    let groupTitle: String
    let currentUserCount: String
    let hashTags: [String]
}
