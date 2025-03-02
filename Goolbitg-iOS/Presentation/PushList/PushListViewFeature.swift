//
//  PushListViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PushListViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        
        var items: [PushListItemEntity] = []
        
        var currentFilterCase: PushListFilterCase = .all
        var dataEmptyCase: DataLoadCase = .loading
        
        var loadingTrigger = false
        var pagingObj = PagingObj(pageNum: 0)
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case delegate(Delegate)
        
        enum Delegate {
            case dismiss
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case selectedFilterCase(PushListFilterCase)
        case postListIndex(Int)
        case selectedItem(PushListItemEntity)
        case dismissTap
    }
    
    enum FeatureEvent {
        case requestPushListItems
        case requestPushListItemsNextPage
        
        case updatePagingObj(PagingObj)
        case updateCurrentMode(DataLoadCase)
        case resultPushListItems([PushListItemEntity], append: Bool)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.noticeMapper) var noticeMapper
    
    
    var body: some ReducerOf<Self> {
        core
    }
    
}

extension PushListViewFeature {
    
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewCycle(.onAppear):
                state.dataEmptyCase = .loading
                return .send(.featureEvent(.requestPushListItems))
                
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
                
            case let .viewEvent(.dismissTap):
                return .send(.delegate(.dismiss))
                
            // MARK: Request
            case .featureEvent(.requestPushListItems):
                
                let paging = state.pagingObj
                let currentFilterCase = state.currentFilterCase
                state.loadingTrigger = true
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: ChallengeListDTO<NoticeDTO>.self,
                        router: NoticeRouter.getMyNotices(
                            page: paging.pageNum,
                            size: paging.size,
                            type: currentFilterCase
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
                
            case .featureEvent(.requestPushListItemsNextPage):
                let paging = state.pagingObj
                let currentFilterCase = state.currentFilterCase
                state.loadingTrigger = true
                
                return .run(priority: .medium) { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: ChallengeListDTO<NoticeDTO>.self,
                        router: NoticeRouter.getMyNotices(
                            page: paging.pageNum,
                            size: paging.size,
                            type: currentFilterCase
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
