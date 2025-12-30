//
//  PagingObj.swift
//  Data
//
//  Created by Jae hyung Kim on 5/23/25.
//

import Foundation

public struct PagingObj: Equatable, Hashable {
    
    public var totalCount: Int? = nil
    public var totalPages: Int? = nil
    public var pageNum = 0
    public var size = 10
    public var date = Date()
    public var status: ChallengeStatusCase = .wait
    
    public init(
        totalCount: Int? = nil,
        totalPages: Int? = nil,
        pageNum: Int = 0,
        size: Int = 10,
        date: Date = Date(),
        status: ChallengeStatusCase = .wait
    ) {
        self.totalCount = totalCount
        self.totalPages = totalPages
        self.pageNum = pageNum
        self.size = size
        self.date = date
        self.status = status
    }
}
