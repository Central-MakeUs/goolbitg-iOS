//
//  GBHomeTabViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct GBHomeTabViewFeature: GBReducer {
    
    @ObservableState
    public struct State: Equatable, Hashable {
        public init () {}
        
        var currentMoney: Double = 0
        
        var currentWeekState: [OneWeekDay] = []
        
        var challengeTotalReward = ""
        var challengeList: [CommonCheckListConfiguration] = []
        
        var onAppearTrigger = false
        var currentUser = HomeUserInfoEntity.getSelf
        var pagingObj = PagingObj()
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        public enum Delegate {
            case moveToDetail(itemID: String)
            case moveToPushListView
        }
        case moneyBinding(Double)
    }
    
    public enum ViewCycle {
        case onAppear
        case onDisappear
    }
    
    public enum ViewEvent {
        case selectedItem(item: CommonCheckListConfiguration)
        case pushAlertButtonTapped
    }
    
    public enum FeatureEvent {
        case requestMockWeekState
        case requestWeekState
        case requestChallengeList
        case resultWeekState([OneWeekDay])
        case resultUserInfo(HomeUserInfoEntity)
        case resultChallengeList([CommonCheckListConfiguration])
        case settingPagingObj(totalSize: Int, totalPage: Int)
        
        case resultTotalReward(String)
        case animationMoney(Double)
        
        case userInfoSave
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.dateManager) var dateManager
    @Dependency(\.userMapper) var userMapper
    @Dependency(\.challengeMapper) var challengeMapper
    
    enum CancelID: Hashable {
        case onAppearTaskCancel
        case selectedItem
    }
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension GBHomeTabViewFeature {
    private var core: some ReducerOf<Self>{
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.featureEvent(.requestMockWeekState))
                    await send(.featureEvent(.requestWeekState))
                    await send(.featureEvent(.requestChallengeList))
                    await send(.featureEvent(.userInfoSave))
                }
                .cancellable(id: CancelID.onAppearTaskCancel)
                
            case .viewCycle(.onDisappear):
                return .cancel(id: CancelID.onAppearTaskCancel)
                
            case let .viewEvent(.selectedItem(item)):
                return .send(.delegate(.moveToDetail(itemID: item.id)))
//                .throttle(
//                    id: CancelID.selectedItem,
//                    for: 0.7,
//                    scheduler: DispatchQueue.main.eraseToAnyScheduler(),
//                    latest: false
//                )
                
            case .featureEvent(.requestMockWeekState):
                if !state.onAppearTrigger {
                    let result = dateManager.fetchWeekDate()
                    let mapping = result.map {
                        return OneWeekDay(date: $0, weekState: false)
                    }
                    state.currentWeekState = mapping
                }
                    
            case .featureEvent(.requestWeekState):
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: UserWeeklyStatusDTO.self, router: UserRouter.weeklyStatus(dateString: nil))
                    
                    
                    let mappingTop = userMapper.homeTopViewMapping(dto: result)
                    let mapping = await userMapper.weeklyHomeMapping(dto: result)
                    
                    await send(.featureEvent(.resultUserInfo(mappingTop)))
                    await send(.featureEvent(.resultWeekState(mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.warning(error)
                }
                .cancellable(id: CancelID.onAppearTaskCancel)
                
            case .featureEvent(.requestChallengeList):
                var obj = state.pagingObj
                obj.date = Date()
                state.pagingObj = obj
                let pagingObj = obj
                
                let dateFormat = dateManager.format(format: .infoBirthDay, date: pagingObj.date)
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: ChallengeListDTO<ChallengeRecordDTO>.self, router: ChallengeRouter.challengeRecords(
                        page: pagingObj.pageNum,
                        size: pagingObj.size,
                        date: dateFormat,
                        state: nil )
                    )
                    await send(.featureEvent(.settingPagingObj(totalSize: result.totalSize, totalPage: result.totalPages)))
                    let mapping = await challengeMapper.toEntityConfigurationForHome(dtos: result.items)
                    
                    let currentTotal = result.totalReward ?? 0
                    let totalString =  GBNumberForMatter.shared.changeForCommaNumber(String(currentTotal))
                    await send(.featureEvent(.resultChallengeList(mapping)))
                    await send(.featureEvent(.resultTotalReward(totalString)))
                } catch: { error, send in
                    Logger.error(error)
                }
                .cancellable(id: CancelID.onAppearTaskCancel)
                
            case let .featureEvent(.settingPagingObj(totalSize, totalPage)):
                state.pagingObj.totalCount = totalSize
                state.pagingObj.totalPages = totalPage
                
            case let .featureEvent(.resultChallengeList(datas)):
                state.challengeList = datas
                
            case let .featureEvent(.resultUserInfo(model)):
                state.currentUser = model
                return .send(.featureEvent(.animationMoney(Double(model.saveMoney))))
                
            case let .featureEvent(.resultWeekState(models)):
                state.currentWeekState = models
                
            case let .featureEvent(.resultTotalReward(text)):
                state.challengeTotalReward = text
                
            case let .moneyBinding(money):
                state.currentMoney = money
                
            case let .featureEvent(.animationMoney(money)):
                state.currentMoney = money
                
            case .featureEvent(.userInfoSave):
                return .run { send in
                    guard let result = try? await networkManager.requestNetworkWithRefresh(
                        dto: UserInfoDTO.self,
                        router: UserRouter.currentUserInfos
                    ) else {
                        return
                    }
                    UserDefaultsManager.userNickname = result.nickname
                    UserDefaultsManager.userID = result.id
                } catch: { error, send in
                    Logger.error(error)
                }
                
                // MARK: 푸시 알림
            case .viewEvent(.pushAlertButtonTapped):
                return .send(.delegate(.moveToPushListView))
                
            default:
                break
            }
            return .none
        }
    }
}
