//
//  GroupChallengeDetailDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 7/8/25.
//

import Foundation
import Domain

public struct GroupChallengeDetailDTO: DTO {
    public let group: GroupChallengeDTO
    public let rank: [GroupChallengeRankDTO]
}
