//
//  GroupChallengeRankDTO.swift
//  Data
//
//  Created by Jae hyung Kim on 7/8/25.
//

import Foundation
import Domain

public struct GroupChallengeRankDTO: DTO {
    /// 이름
    let name: String
    /// 프로필 URL String
    let profileUrl: String?
    /// 절약금액
    let saving: Int
}
