import Foundation
import Domain

public struct HabitChartsAnalysisEntity: Entity {
    public let userHabitInfo: UserHabitInfoEntity
    public let recentMessage: String
    public let recentMaxCount: Int
    public let recentMonthlyData: [RecentChallengeWeeklyEntity]
    public let categoryInfo: CategoryCompareEntity
    public let individualSuccessRate: Double
    public let groupSuccessRate: Double
    public let individualGroupMessage: String
    public let buyOrNotMessage: String
    public let buyOrNotDatas: [BuyOrNotChartDataEntity]

    public init(
        userHabitInfo: UserHabitInfoEntity,
        recentMessage: String,
        recentMaxCount: Int,
        recentMonthlyData: [RecentChallengeWeeklyEntity],
        categoryInfo: CategoryCompareEntity,
        individualSuccessRate: Double,
        groupSuccessRate: Double,
        individualGroupMessage: String,
        buyOrNotMessage: String,
        buyOrNotDatas: [BuyOrNotChartDataEntity]
    ) {
        self.userHabitInfo = userHabitInfo
        self.recentMessage = recentMessage
        self.recentMaxCount = recentMaxCount
        self.recentMonthlyData = recentMonthlyData
        self.categoryInfo = categoryInfo
        self.individualSuccessRate = individualSuccessRate
        self.groupSuccessRate = groupSuccessRate
        self.individualGroupMessage = individualGroupMessage
        self.buyOrNotMessage = buyOrNotMessage
        self.buyOrNotDatas = buyOrNotDatas
    }
}
