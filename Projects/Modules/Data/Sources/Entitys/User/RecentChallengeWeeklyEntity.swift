//
//  RecentChallengeWeeklyEntity.swift
//  Data
//
//  Created by Jae hyung Kim on 11/19/25.
//

import Foundation
import Domain

public struct RecentChallengeWeeklyEntity: Entity, MyPageWeeklyGraphProtocol {
    public var title: String
    public var count: Int
    public var isRecommend: Bool
    public var barStyle: GraphBarStyle
    
    public init(
        title: String,
        count: Int,
        isRecommend: Bool,
        barStyle: GraphBarStyle
    ) {
        self.title = title
        self.count = count
        self.isRecommend = isRecommend
        self.barStyle = barStyle
    }
}

#if DEBUG
extension RecentChallengeWeeklyEntity {
    public static var mocks: [RecentChallengeWeeklyEntity] {
        [
            .init(
                title: "지난주",
                count: 7,
                isRecommend: false,
                barStyle: .grey
            ),
            .init(
                title: "이번주",
                count: 5,
                isRecommend: false,
                barStyle: .mainColor
            ),
            .init(
                title: "다음주",
                count: 6,
                isRecommend: true,
                barStyle: .dotStyleForRecommend
            )
        ]
    }
}
#endif
