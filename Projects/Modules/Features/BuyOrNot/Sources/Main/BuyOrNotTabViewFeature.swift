//
//  BuyOrNotTabViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct BuyOrNotTabViewFeature: GBReducer {
    public init () {}
    @ObservableState
    public struct State: Equatable, Hashable {
        public init () {}
        var tabMode: BuyOrNotTabInMode = .buyOrNot
        var currentList: [BuyOrNotCardViewEntity] = []
        var currentIndex: Int = 0
        var buyOrNotPagingObj = BuyOrNotPagingObj(page: 0, created: false)
        var userCreated = false
        var pagingTrigger = false
        
        var buyOrNotRecordPagingObj = BuyOrNotPagingObj(page: 0, created: true)
        var currentUserList: [BuyOrNotCardViewEntity] = []
        var userListPagingTrigger = false
        
        
        var errorAlert: GBAlertViewComponents?
        var currentAlertModel: CurrentAlertType? = nil
        var loading: Bool = false
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        case bindingCurrentList([BuyOrNotCardViewEntity])
        case bindingCurrentIndex(Int)
        case bindingTabMode(BuyOrNotTabInMode)
        case bindingAlert(GBAlertViewComponents?)
        case parentEvent(ParentEvent)
        
        case loading(Bool)
        
        public enum Delegate {
            case moveToAddView
            case moveToModifierView(BuyOrNotCardViewEntity, idx: Int)
        }
    }
    
    public enum ViewCycle {
        case onAppear
        case recordOnAppear
    }
    
    public enum ViewEvent {
        case likeButtonTapped(BuyOrNotCardViewEntity?, index: Int)
        case disLikeButtonTapped(BuyOrNotCardViewEntity?, index: Int)
        case addButtonTapped
        case moreUserList(index: Int)
        case modifierModel(BuyOrNotCardViewEntity, index: Int)
        case deleteModel(BuyOrNotCardViewEntity, index: Int)
        
        case alertOkTapped(item: GBAlertViewComponents)
        case reportButtonTapped(id: String, reason: ReportCase)
    }
    
    public enum FeatureEvent {
        case requestBuyOrNotList(BuyOrNotPagingObj)
        case requestAppendBuyOrNotList(BuyOrNotPagingObj)
        
        case resultBuyOrNotList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
        case resultAppendBuyOrNotList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
        
        // MARK: 투표
        case resultVote(BuyOrNotVoteDTO, index: Int)
        
        // MARK: 기록
        case requestUserRecordList(BuyOrNotPagingObj)
        case requestMoreRecordList(BuyOrNotPagingObj)
        case requestDeleteRecord(BuyOrNotCardViewEntity, idx: Int)
        
        // MARK: 신고하기
        case requestReport(id: String, reason: ReportCase)
        
        case resultUserRecordList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
        case resultAppendRecordList(paging: BuyOrNotPagingObj, models: [BuyOrNotCardViewEntity])
        case resultDeleteRecord(idx: Int)
    }
    
    public enum ParentEvent {
        case newBuyOrNotItem
        case modifierSuccess(BuyOrNotCardViewEntity, idx: Int)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.buyOrNotMapper) var buyOrNotMapper
    
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotTabViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // MARK: ViewCycle
            case .viewCycle(.onAppear):
                let paging = BuyOrNotPagingObj(page: 0, created: false)
                state.buyOrNotPagingObj = paging
                state.pagingTrigger = false
                state.currentList = []
                state.currentIndex = 0
                return .run { send in
                    await send(.featureEvent(.requestBuyOrNotList(paging)))
                }
                
            case .viewCycle(.recordOnAppear):
                let paging = BuyOrNotPagingObj(page: 0, created: true)
                state.buyOrNotRecordPagingObj = paging
                state.userListPagingTrigger = false
                state.currentUserList = []
                
                return .run { send in
                    await send(.featureEvent(.requestUserRecordList(paging)))
                }
                
            // MARK: ViewEvent
            case let .viewEvent(.likeButtonTapped(entity, index)):
                guard let entity else { return .none }
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: BuyOrNotVoteDTO.self, router: BuyOrNotRouter.buyOrNotVote(
                        postID: entity.id,
                        requestDTO: BuyOrNotVoteRequestDTO(vote: .good) )
                    )
                    
                    await send(.featureEvent(.resultVote(result, index: index)))
                    
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.error(error)
                        return
                    }
                    if case .serverMessage(.postLimitExceeded) = error {
                        let alertComponents = GBAlertViewComponents(
                            title: "투표 불가",
                            message: "본인이 작성한 포스트는 투표할 수 없습니다.",
                            cancelTitle: nil,
                            okTitle: "확인",
                            alertStyle: .warningWithWarning
                        )
                        await send(.bindingAlert(alertComponents))
                    }
                }
                
            case let .viewEvent(.disLikeButtonTapped(entity, index)):
                guard let entity else { return .none }
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(dto: BuyOrNotVoteDTO.self, router: BuyOrNotRouter.buyOrNotVote(
                        postID: entity.id,
                        requestDTO: BuyOrNotVoteRequestDTO(vote: .bad) )
                    )
                    
                    await send(.featureEvent(.resultVote(result, index: index)))
                    
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.error(error)
                        return
                    }
                    if case .serverMessage(.postLimitExceeded) = error {
                        let alertComponents = GBAlertViewComponents(
                            title: "투표 불가",
                            message: "본인이 작성한 포스트는 투표할 수 없습니다.",
                            cancelTitle: nil,
                            okTitle: "확인",
                            alertStyle: .warningWithWarning
                        )
                        await send(.bindingAlert(alertComponents))
                    }
                }
                
            case .viewEvent(.addButtonTapped):
                return .send(.delegate(.moveToAddView))
                
            case let .viewEvent(.moreUserList(index)):
                if (index > state.currentList.count - 2), !state.userListPagingTrigger {
                    state.buyOrNotRecordPagingObj.page += 1
                    state.userListPagingTrigger = true
                    return .send(.featureEvent(.requestMoreRecordList(state.buyOrNotRecordPagingObj)))
                }
                
            case let .viewEvent(.deleteModel(userModel, index)):
                
                state.currentAlertModel = .deleteModel(model: userModel, idx: index)
                
                state.errorAlert = GBAlertViewComponents(
                    title: "삭제하기",
                    message: "정말 살까말까 글을\n삭제하시겠어요?",
                    cancelTitle: "취소",
                    okTitle: "삭제",
                    alertStyle: .warning
                )
                
            case .viewEvent(.alertOkTapped(_)):
                state.errorAlert = nil
                if case let.deleteModel(model, idx) = state.currentAlertModel {
                    return .send(.featureEvent(.requestDeleteRecord(model, idx: idx)))
                }
                
            case let .viewEvent(.modifierModel(model, index)):
                
                return .send(.delegate(.moveToModifierView(model, idx: index)))
                
            case let .viewEvent(.reportButtonTapped(id, item)):
                
                return .send(.featureEvent(.requestReport(id: id, reason: item)))
                
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
                
            case let .featureEvent(.requestUserRecordList(PagingObj)):
                
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: BuyOrNotPagedDTO<BuyOrNotDTO>.self,
                        router: BuyOrNotRouter.buyOtNots(
                            page: PagingObj.page,
                            size: PagingObj.size,
                            created: PagingObj.created
                        )
                    )
                    
                    var obj = PagingObj
                    obj.totalSize = result.page
                    
                    let mapping = await buyOrNotMapper.toEntity(dtos: result.items)
                    
                    await send(.featureEvent(.resultUserRecordList(
                        paging: obj,
                        models: mapping )
                    ))
                    
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        Logger.error("ERRRRRRRRRRROOOOOOOOR")
                        return
                    }
                    Logger.error(error)
                }
                
            case let .featureEvent(.requestMoreRecordList(obj)):
                return .run(priority: .background) { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: BuyOrNotPagedDTO<BuyOrNotDTO>.self,
                        router: BuyOrNotRouter.buyOtNots(
                            page: obj.page,
                            size: obj.size,
                            created: obj.created
                        )
                    )
                    
                    var obj = obj
                    obj.totalSize = result.page
                    
                    let mapping = await buyOrNotMapper.toEntity(dtos: result.items)
                    
                    await send(.featureEvent(.resultAppendRecordList(
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
                
            case let .featureEvent(.requestDeleteRecord(model, idx)):
                guard let item = state.currentUserList[safe: idx],
                     item == model else {
                    return .none
                }
                Logger.debug("삭제할 에쩡!!!!!!!!!!!!!!!")
                state.loading = true
                return .run { send in
                    try await networkManager.requestNotDtoNetwork(
                        router: BuyOrNotRouter.buyOrNotDelete(postID: model.id),
                        ifRefreshNeed: true
                    )
                    
                    await send(.featureEvent(.resultDeleteRecord(idx: idx)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    if case .serverMessage(.postNotFound) = error {
                        await send(.bindingAlert(GBAlertViewComponents(
                            title: "ERROR",
                            message: "포스트가 존재하지 않습니다.",
                            okTitle: "확인",
                            alertStyle: .warningWithWarning
                        )))
                    }
                }
                
            case let .featureEvent(.requestReport(id, reason)):
                state.loading = true
                return .run { send in
                    
                    try await networkManager.requestNotDtoNetwork(router: BuyOrNotRouter.buyOrNotReport(
                        postID: id,
                        reason: reason.reason
                    ), ifRefreshNeed: true
                    )
                    
                    await send(.loading(false))
                    
                    await send(.bindingAlert(GBAlertViewComponents(
                        title: "신고하기 완료",
                        message: "신고하기 완료되었습니다",
                        okTitle: "확인",
                        alertStyle: .checkWithNormal
                    )))
                    
                } catch: { error, send in
                    await send(.loading(false))
                    
                    guard let error = error as? RouterError else {
                        return
                    }
                    if case  .serverMessage(.postNotFound) = error {
                        await send(.bindingAlert(GBAlertViewComponents(
                            title: "ERROR",
                            message: "포스트가 존재하지 않습니다.",
                            okTitle: "확인",
                            alertStyle: .warningWithWarning
                        )))
                    }
                    else if case .serverMessage(.alreadyReportedPost) = error {
                        await send(.bindingAlert(GBAlertViewComponents(
                            title: "ERROR",
                            message: "이미 신고한 게시물입니다.",
                            okTitle: "확인",
                            alertStyle: .warningWithWarning
                        )))
                    }
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
                
            case let .featureEvent(.resultVote(model, index)):
                let copy = state.currentList
                var copyChange = copy[index]
                copyChange.goodVoteCount = String(model.goodVoteCount)
                copyChange.badVoteCount = String(model.badVoteCount)
                
                state.currentList[index] = copyChange
                
            case let .featureEvent(.resultUserRecordList(paging, models)):
                state.buyOrNotRecordPagingObj = paging
                state.currentUserList = models
                state.userListPagingTrigger = models.isEmpty
                
            case let .featureEvent(.resultAppendRecordList(paging, models)):
                state.buyOrNotRecordPagingObj = paging
                state.currentUserList.append(contentsOf: models)
                state.pagingTrigger = models.isEmpty
                
            case let .featureEvent(.resultDeleteRecord(index)):
                state.currentUserList.remove(at: index)
                
                state.loading = false
                
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
                
            case let .bindingAlert(model):
                state.errorAlert = model
                if model == nil {
                    state.currentAlertModel = nil
                }
                
                // MARK: ParentAction
            case .parentEvent(.newBuyOrNotItem):
                var obj = BuyOrNotPagingObj(page: 0, created: false)
                
                if state.tabMode == .buyOrNot {
                    state.buyOrNotPagingObj = obj
                    state.currentList.removeAll()
                    return .send(.featureEvent(.requestBuyOrNotList(obj)))
                } else {
                    obj.created = true
                    state.buyOrNotRecordPagingObj = obj
                    return .send(.featureEvent(.requestUserRecordList(state.buyOrNotPagingObj)))
                }
            case let .parentEvent(.modifierSuccess(model, idx)):
                state.currentUserList[idx] = model
                
            case let .loading(bool):
                state.loading = bool
                
            default:
                break
            }
            return .none
        }
    }
    
    enum CurrentAlertType: Equatable, Hashable {
        case deleteModel(model: BuyOrNotCardViewEntity, idx: Int)
    }
}
    

public struct BuyOrNotPagingObj: Equatable, Hashable {
    var totalSize = 0
    /// 페이지 번호
    var page: Int
    /// 페이지 사이즈
    var size = 10
    /// 내가 작성한 포스트만 가져올지 여부
    var created: Bool
}
