import ComposableArchitecture
import Data
import Domain
import Utils

@Reducer
public struct HabitChartsFeature: GBReducer {

    @ObservableState
    public struct State: Equatable, Hashable {
        var recentMessage: String = ""
        var recentMaxCount: Int = 1
        var isLoading: Bool = false
        
        var userHabitInfo: UserHabitInfoEntity = .init(
            userName: "",
            userType: "",
            upperPercent: 0,
            imageURL: ""
        )
        
        var recentMonthlyData: [RecentChallengeWeeklyEntity] = []

        var categoryInfo: CategoryCompareEntity = .init(
            message: "",
            topCategory: "",
            allCategories: []
        )

        var individualSuccessRate: Double = 0
        var groupSuccessRate: Double = 0
        var individualGroupMessage: String = ""
        var buyOrNotMessage: String = ""

        var buyOrNotDatas: [BuyOrNotChartDataEntity] = []
    }

    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkAction(NetworkAction)
    }

    public enum ViewCycle {
        case onAppear
    }

    public enum ViewEvent {}
    
    public enum NetworkAction {
        case requestAnalytics
        case responseAnalytics(HabitChartsAnalysisEntity)
        case failedAnalytics
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.userMapper) var userMapper

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .send(.networkAction(.requestAnalytics))
                
            case .networkAction(.requestAnalytics):
                state.isLoading = true
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: AnalysisAllDTO.self,
                        router: UserRouter.getAnalysisReport
                    )
                    let mapping = userMapper.habitChartsAnalysisMapping(model: result)
                    await send(.networkAction(.responseAnalytics(mapping)))
                } catch: { error, send in
                    Logger.error(error)
                    await send(.networkAction(.failedAnalytics))
                }

            case let .networkAction(.responseAnalytics(entity)):
                state.isLoading = false
                state.userHabitInfo = entity.userHabitInfo
                state.recentMessage = entity.recentMessage
                state.recentMaxCount = max(entity.recentMaxCount, 1)
                state.recentMonthlyData = entity.recentMonthlyData
                state.categoryInfo = entity.categoryInfo
                state.individualSuccessRate = entity.individualSuccessRate
                state.groupSuccessRate = entity.groupSuccessRate
                state.individualGroupMessage = entity.individualGroupMessage
                state.buyOrNotMessage = entity.buyOrNotMessage
                state.buyOrNotDatas = entity.buyOrNotDatas
                
                return .none

            case .networkAction(.failedAnalytics):
                state.isLoading = false
                return .none
                
            default:
                break
            }
            return .none
        }
    }
}
