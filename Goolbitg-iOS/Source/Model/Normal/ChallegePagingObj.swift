//
//  ChallegePagingObj.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation

struct PagingObj: Equatable {
    var totalCount: Int? = nil
    var totalPages: Int? = nil
    var pageNum = 0
    var size = 10
    var date = Date()
    var status: ChallengeStatusCase = .wait
}

/// 챌린지 그룹 
struct ChallegeGroupPagingObj: Equatable {
    var pageNum = 0
    var size = 10
    var searchText: String?
    var created: Bool = false
}
