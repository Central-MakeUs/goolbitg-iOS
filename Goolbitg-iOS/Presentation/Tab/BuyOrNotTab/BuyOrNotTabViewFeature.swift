//
//  BuyOrNotTabViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BuyOrNotTabViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var tabMode: BuyOrNotTabInMode = .buyOrNot
        var currentList: [BuyOrNotCardViewEntity] = []
        var currentIndex: Int = 0
        var buyOrNotPagingObj = BuyOrNotPagingObj(page: 0, created: false)
        var pagingTrigger = false
        var userCreated = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case bindingCurrentList([BuyOrNotCardViewEntity])
        case bindingCurrentIndex(Int)
        case bindingTabMode(BuyOrNotTabInMode)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case likeButtonTapped(BuyOrNotCardViewEntity?, index: Int)
        case disLikeButtonTapped(BuyOrNotCardViewEntity?, index: Int)
    }
    
    enum FeatureEvent {
        case requestBuyOrNotList(BuyOrNotPagingObj)
        case requestAppendBuyOrNotList(BuyOrNotPagingObj)
        case resultBuyOrNotList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
        case resultAppendBuyOrNotList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.buyOrNotMapper) var buyOrNotMapper
    
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotTabViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                let paging = BuyOrNotPagingObj(page: 0, created: state.userCreated)
                state.buyOrNotPagingObj = paging
                state.pagingTrigger = false
                state.currentList = []
                state.currentIndex = 0
                return .run { send in
                    await send(.featureEvent(.requestBuyOrNotList(paging)))
                }
                
            case let .viewEvent(.likeButtonTapped(entity, index)):
                guard let entity else { return .none }
                
            case let .viewEvent(.disLikeButtonTapped(entity, index)):
                guard let entity else { return .none }
                
                
            // MARK: REQUEST
            case let .featureEvent(.requestBuyOrNotList(obj)):
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: BuyOrNotPagedDTO<BuyOrNotDTO>.self,
                        router: BuyOrNotRouter.buyOtNots(
                            page: obj.page,
                            size: obj.size,
                            created: obj.created
                        )
                    )
                    
                    var obj = obj
                    obj.onLoad = true
                    obj.totalSize = result.page
                    
                    let mapping = await buyOrNotMapper.toEntity(dtos: result.items)
                    
                    await send(.featureEvent(.resultBuyOrNotList(
                        paging: obj,
                        models: mapping)
                    ))
                    
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.error("ERRRRRRRRRRROOOOOOOOR")
                        return
                    }
                    Logger.error(error)
                }
                
            case let .featureEvent(.requestAppendBuyOrNotList(obj)):
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: BuyOrNotPagedDTO<BuyOrNotDTO>.self,
                        router: BuyOrNotRouter.buyOtNots(
                            page: obj.page,
                            size: obj.size,
                            created: obj.created
                        )
                    )
                    
                    var obj = obj
                    obj.onLoad = true
                    obj.totalSize = result.page
                    
                    let mapping = await buyOrNotMapper.toEntity(dtos: result.items)
                    
                    await send(.featureEvent(.resultAppendBuyOrNotList(
                        paging: obj,
                        models: mapping)
                    ))
                    
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.error("ERRRRRRRRRRROOOOOOOOR")
                        return
                    }
                    Logger.error(error)
                }
                
            // MARK: RESULT
            case let .featureEvent(.resultBuyOrNotList(paging, models)):
                state.buyOrNotPagingObj = paging
                state.currentList = models
                state.pagingTrigger = models.isEmpty
                
            case let .featureEvent(.resultAppendBuyOrNotList(paging, models)):
                state.buyOrNotPagingObj = paging
                state.currentList.append(contentsOf: models)
                
                state.pagingTrigger = models.isEmpty
                
                
                
            // MARK: BINDING
            case .bindingCurrentList(let currentList):
                state.currentList = currentList
                
            case .bindingCurrentIndex(let currentIndex):
                state.currentIndex = currentIndex
                if state.currentList.isEmpty || currentIndex <= 0 { return .none }
                
                if (currentIndex > state.currentList.count - 2), !state.pagingTrigger {
                    state.buyOrNotPagingObj.page += 1
                    state.pagingTrigger = true
                    return .send(.featureEvent(.requestAppendBuyOrNotList(state.buyOrNotPagingObj)))
                }
                
            case .bindingTabMode(let tabMode):
                state.tabMode = tabMode
                
            default:
                break
            }
            return .none
        }
    }
}
    

struct BuyOrNotPagingObj: Equatable {
    var totalSize = 0
    var onLoad = false
    var page: Int
    let size = 10
    let created: Bool
}
