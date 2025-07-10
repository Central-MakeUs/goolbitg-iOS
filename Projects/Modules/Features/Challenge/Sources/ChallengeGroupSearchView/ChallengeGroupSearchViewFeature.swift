//
//  ChallengeGroupSearchViewFeature.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 7/10/25.
//

import Foundation
import ComposableArchitecture
import Domain
import Data
import Utils

@Reducer
public struct ChallengeGroupSearchViewFeature: GBReducer {
    
    @ObservableState
    public struct State: Equatable, Hashable {
        public init() {}
        var onAppearTrigger = false
        var searchText: String = ""
        var searchItemCount: Int = 0
        var apiLoadTrigger = false
        
        var listItems: [ParticipatingGroupChallengeListEntity] = []
        
        var groupChallengePagingObj = GroupChallengePagingObj()
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)

        case searchTextBinding(String)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case moreItem
        case tappedItem(ParticipatingGroupChallengeListEntity)
    }
    
    public enum FeatureEvent {
        case resetSearchItem
        case requestSearchItem(text: String, append: Bool)
        case updateSearchItem([ParticipatingGroupChallengeListEntity], append: Bool)
        case updateGroupChallengePagingObj(totalSize: Int, totalPages: Int, page: Int, size: Int)
    }
    
    public enum CancelID: String, Hashable {
        case searchItem
        case paging
        case onAppear
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.challengeMapper) var challengeMapper
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension ChallengeGroupSearchViewFeature {
    private var core: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
                
            case .viewCycle(.onAppear):
                if state.onAppearTrigger {
                    return .none
                }
                state.onAppearTrigger = true
                
                return .run { send in
                    await send(.featureEvent(.requestSearchItem(text: "", append: false)))
                }.debounce(id: CancelID.onAppear, for: 0.5, scheduler: GBUISchedulerInstance)
                
            case .viewEvent(.moreItem):
                if state.apiLoadTrigger { return .none }
                
                let current = state.groupChallengePagingObj.pageNum
                let totalPage = state.groupChallengePagingObj.totalPages ?? 100
                
                if totalPage >= current {
                    state.groupChallengePagingObj.pageNum += 1
                    return .run { send in
                        let text = ""
                        await send(.featureEvent(.requestSearchItem(text: text, append: true)))
                    }
                    .debounce(id: CancelID.paging, for: 0.5, scheduler: GBUISchedulerInstance)
                }
            case let .searchTextBinding(text):
                state.searchText = text
                
                return .run { send in
                    await send(.featureEvent(.requestSearchItem(text: text, append: false)))
                }
                .debounce(id: CancelID.searchItem, for: 0.6, scheduler: GBUISchedulerInstance)
                
            case .featureEvent(.resetSearchItem):
                state.groupChallengePagingObj = GroupChallengePagingObj()
                
            case let .featureEvent(.requestSearchItem(text, append)):
                state.groupChallengePagingObj.searchText = text
                state.apiLoadTrigger = true
                
                let pagingObj = state.groupChallengePagingObj
                
                return .run { send in
                    let result = try await networkManager
                        .requestNetworkWithRefresh(
                            dto: ChallengeListDTO<GroupChallengeDTO>.self,
                            router: ChallengeRouter
                                .groupChallengeList(
                                    page: pagingObj.pageNum,
                                    size: pagingObj.size,
                                    searchText: pagingObj.searchText,
                                    created: pagingObj.created,
                                    participating: pagingObj.participating
                                )
                        )
                    
                    let mapping = await challengeMapper.toMappingGroupChallengeList(dtos: result.items)
                    
                    await send(
                        .featureEvent(
                            .updateGroupChallengePagingObj(
                                totalSize: result.totalSize,
                                totalPages: result.totalPages,
                                page: result.page,
                                size: result.size
                            )
                        )
                    )
                    
                    await send(
                        .featureEvent(.updateSearchItem(mapping, append: append))
                    )
                }
                
            case let.featureEvent(.updateSearchItem(datas, append)):
                if append {
                    state.listItems.append(contentsOf: datas)
                } else {
                    state.listItems = []
                    state.listItems = datas
                }
                state.apiLoadTrigger = false
                
            case let .featureEvent(.updateGroupChallengePagingObj(totalSize, totalPages, page, size)):
                var copy = state.groupChallengePagingObj
                copy.totalCount = totalSize
                copy.totalPages = totalPages
                copy.size = size
                copy.pageNum = page
                state.groupChallengePagingObj = copy
                
                state.searchItemCount = totalSize
            default:
                break
            }
            return .none
        }
    }
}
