//
//  PushListViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct PushListViewFeature: GBReducer {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        public init() {}
        
        var items: [PushListItemEntity] = []
        
        var currentFilterCase: PushListFilterCase = .all
        var dataEmptyCase: DataLoadCase = .loading
        
        @ObservationStateIgnored
        var loadingTrigger = false
        
        @ObservationStateIgnored
        var pagingObj = PagingObj(pageNum: 0)
        
        @ObservationStateIgnored
        var ifOnAppear: Bool = false
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case delegate(Delegate)
        case cancel(TCACoordinatorCancelID)
        
        public enum Delegate {
            case dismiss
        }
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case selectedFilterCase(PushListFilterCase)
        case postListIndex(Int)
        case selectedItem(PushListItemEntity)
        case dismissTap
    }
    
    public enum FeatureEvent {
        case requestPushListItems
        case requestPushListItemsNextPage
        
        case updatePagingObj(PagingObj)
        case updateCurrentMode(DataLoadCase)
        case resultPushListItems([PushListItemEntity], append: Bool)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.noticeMapper) var noticeMapper
    @Dependency(\.pushNotiManager) var pushManager
    
    
    public var body: some ReducerOf<Self> {
        core
    }
    
    // MARK: TCA Coordinator 성능 문제로 인한 작업
    public enum TCACoordinatorCancelID: Hashable, Equatable {
        case onAppear
        case requestCancel
    }
    
}

extension PushListViewFeature {
    
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                if state.ifOnAppear { return .none }
                state.ifOnAppear = true
                state.pagingObj = PagingObj()
                state.dataEmptyCase = .loading
                return .run { /*[state]*/ send in
                    await send(.cancel(.requestCancel))
                    await pushManager.resetBadgeCount()
                    await send(.featureEvent(.requestPushListItems))
                }
                .debounce(id: TCACoordinatorCancelID.onAppear, for: 1, scheduler: DispatchQueue.immediate)
                
            case .cancel(let type):
                return .cancel(id: type)
                
            // MARK: ViewEvent
            case let .viewEvent(.postListIndex(index)):
                if index > state.items.count - 3 {
                    return .send(.featureEvent(.requestPushListItemsNextPage))
                }
                
            case let .viewEvent(.selectedFilterCase(caseOf)):
                state.currentFilterCase = caseOf
                state.pagingObj = PagingObj(pageNum: 0)
                state.loadingTrigger = true
                return .send(.featureEvent(.requestPushListItems))
                
            case .viewEvent(.dismissTap):
                return .send(.delegate(.dismiss))
                
            // MARK: Request
            case .featureEvent(.requestPushListItems):
                state.loadingTrigger = true
                
                let paging = state.pagingObj
                let currentFilterCase = state.currentFilterCase
                
                return .run { send in
                    if Task.isCancelled {
                       return
                    }
                    
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: ChallengeListDTO<NoticeDTO>.self,
                        router: NoticeRouter.getMyNotices(
                            page: paging.pageNum,
                            size: paging.size,
                            type: currentFilterCase.requestMode
                        )
                    )
                    
                    if !result.items.isEmpty {
                        var updatePaging = paging
                        updatePaging.pageNum += 1
                        
                        await send(.featureEvent(.updatePagingObj(updatePaging)))
                    }
                    
                    let mappaing = await noticeMapper.toEntity(result.items)
                    
                    await send(.featureEvent(.resultPushListItems(mappaing, append: false)))
                    
                } catch: { error, send in
                    Logger.error("error: \(error)")
                }
                .animation(.easeInOut)
                .throttle(id: TCACoordinatorCancelID.requestCancel, for: 0.12, scheduler: DispatchQueue.main.eraseToAnyScheduler(), latest: false)
                .cancellable(id: TCACoordinatorCancelID.requestCancel)
                
            case .featureEvent(.requestPushListItemsNextPage):
                state.loadingTrigger = true
                let paging = state.pagingObj
                let currentFilterCase = state.currentFilterCase
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: ChallengeListDTO<NoticeDTO>.self,
                        router: NoticeRouter.getMyNotices(
                            page: paging.pageNum,
                            size: paging.size,
                            type: currentFilterCase.requestMode
                        )
                    )
                    
                    if !result.items.isEmpty {
                        var updatePaging = paging
                        updatePaging.pageNum += 1
                        
                        await send(.featureEvent(.updatePagingObj(updatePaging)))
                    }
                    
                    let mappaing = await noticeMapper.toEntity(result.items)
                    
                    await send(.featureEvent(.resultPushListItems(mappaing, append: true)))
                    
                } catch: { error, send in
                    Logger.error("error: \(error)")
                }
                
            // MARK: RESULT
            case let .featureEvent(.updatePagingObj(obj)):
                state.pagingObj = obj
                
            case let .featureEvent(.resultPushListItems(datas, append)):
                if append {
                    state.items.append(contentsOf: datas)
                }
                else {
                    state.items = datas
                    if datas.isEmpty {
                        print("append : -> ",append)
                        state.dataEmptyCase = .empty
                    }
                    else {
                        state.dataEmptyCase = .loaded
                    }
                }
                
                state.loadingTrigger = false
                
            case let .featureEvent(.updateCurrentMode(mode)):
                state.dataEmptyCase = mode
                
            default:
                break
            }
            return .none
        }
    }

}
