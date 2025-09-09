//
//  GroupChallengePagingObj.swift
//  Data
//
//  Created by Jae hyung Kim on 6/17/25.
//

import Foundation

public struct GroupChallengePagingObj: Equatable, Hashable {
    
    public var totalCount: Int?
    public var totalPages: Int?
    
    public var pageNum: Int
    public let size: Int
    public var searchText: String?
    public var created: Bool
    public var participating: Bool
    
    public init(
        totalCount: Int? = nil,
        totalPages: Int? = nil,
        pageNum: Int = 0,
        size: Int = 10,
        searchText: String? = nil,
        created: Bool = false,
        participating: Bool = false
    ) {
        self.totalCount = totalCount
        self.totalPages = totalPages
        self.pageNum = pageNum
        self.size = size
        self.searchText = searchText
        self.created = created
        self.participating = participating
    }
}
