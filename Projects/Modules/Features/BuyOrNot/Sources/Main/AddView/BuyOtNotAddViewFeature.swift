//
//  BuyOtNotAddViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data


public enum BuyOrNotAddOrModify: Equatable, Hashable {
    case add
    case modifier(BuyOrNotCardViewEntity, idx: Int)
    
    public var navigationTitle: String {
        switch self {
        case .add:
            return TextHelper.buyOrNotAddTitle
        case .modifier:
            return "살까말까 글 수정하기"
        }
    }
    
    public var endTitle: String {
        switch self {
        case .add:
            return "작성하기"
        case .modifier:
            return "수정하기"
        }
    }
}

@Reducer
public struct BuyOrNotAddViewFeature: GBReducer {
    public init () {}
    
    @ObservableState
    public struct State: Equatable, Hashable {
        let stateMode: BuyOrNotAddOrModify
        var currentImageData: Data? = nil // 무조건 JPEG 로 변환
        var alertComponents: GBAlertViewComponents? = nil
        
        var ifImageURL: URL? = nil
        var itemText = ""
        var priceText = ""
        var buyText = ""
        var notBuyText = ""
        
        var currentOkButtonState = false
        var loading = false
        var modiferModel: BuyOrNotCardViewEntity? = nil
        
        public init(stateMode: BuyOrNotAddOrModify) {
            self.stateMode = stateMode
        }
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case delegate(Delegate)
        
        case bindingAlertComponents(GBAlertViewComponents?)
        case bindingItemText(String)
        case bindingPriceText(String)
        case bindingBuyText(String)
        case bindingBuyNotText(String)
        case debouncedCheckAll
        
        public enum Delegate {
            case dismiss
            case succressItem
            case successModifer(BuyOrNotCardViewEntity, idx: Int)
        }
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case imageResults(Data?)
        case alertOkTap(GBAlertViewComponents)
        case okButtonTapped
        case dismiss
    }
    
    public enum FeatureEvent {
        case successRegister
        case errorHandling(RouterError)
        case successModifier(BuyOrNotCardViewEntity)
    }
    
    @Dependency(\.gbNumberForMatter) var numberFormatter
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.buyOrNotMapper) var buyOrNotMapper
    
    private enum CancelID { static let checkAll = "BuyOrNotAddViewFeature.checkAll" }
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotAddViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                if case let .modifier(entity, _) = state.stateMode {
                    state.itemText = entity.itemName
                    state.priceText = entity.priceString
                    state.buyText = entity.goodReason
                    state.notBuyText = entity.badReason
                    state.ifImageURL = entity.imageUrl
                }
            case .viewEvent(.dismiss):
                
                let text = state.stateMode == .add ? "글 작성" : "글 수정"
                
                let alertComponents = GBAlertViewComponents(
                    title: "살까말까 \(text) 중단",
                    message: "살깔말까 \(text)을\n정말 중단하시겠어요?",
                    cancelTitle: "취소",
                    okTitle: "중단",
                    alertStyle: .warningWithWarning,
                    ifNeedID: "중단"
                )
                
                state.alertComponents = alertComponents
                
            case let .viewEvent(.imageResults(data)):
                state.ifImageURL = nil
                state.currentImageData = data
                
                return checkAll(state: &state)
                
            case .viewEvent(.okButtonTapped):
                
                let price = Int(
                    state.priceText
                        .replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: " ", with: "")
                )
                
                if let imgData = state.currentImageData,
                   state.currentOkButtonState,
                   let price {
                    state.loading = true
                    return .run { [state] send in
                        
                        /// ImageUpload
                        let imageResult = try await networkManager.uplaodMultipartRequest(
                            type: ImageDTO.self,
                            router: ImageRouter.imageUpload(
                                imageData: imgData,
                                fileName: "GoolB_\(UUID().uuidString)"
                            )
                        )
                        
                        let requestDTO = BuyOrNotRequestModel(
                            productName: state.itemText,
                            productPrice: price,
                            productImageUrl: imageResult.url,
                            goodReason: state.buyText,
                            badReason: state.notBuyText
                        )
                        
                        let _ = try await networkManager.requestNetworkWithRefresh(
                            dto: BuyOrNotDTO.self,
                            router: BuyOrNotRouter.butOrNotsReg(requestDTO: requestDTO)
                        )
                        
                        await send(.featureEvent(.successRegister))
                        
                    } catch: { error, send in
                        guard let error = error as? RouterError else {
                            return
                        }
                        await send(.featureEvent(.errorHandling(error)))
                    }
                }
                else if let imageURLString = state.ifImageURL?.absoluteString,
                        let price,
                        case let .modifier(model, _) = state.stateMode
                {
                    state.loading = true
                    return .run { [state] send in
                        let requestDTO = BuyOrNotRequestModel(
                            productName: state.itemText,
                            productPrice: price,
                            productImageUrl: imageURLString,
                            goodReason: state.buyText,
                            badReason: state.notBuyText
                        )
                        
                        let modify = try await networkManager.requestNetworkWithRefresh(dto: BuyOrNotDTO.self, router: BuyOrNotRouter.buyOtNotsModify(
                            postID: model.id,
                            requestDTO: requestDTO)
                        )
                        
                        let entity = buyOrNotMapper.toEntity(dto: modify)
                        await send(.featureEvent(.successModifier(entity)))
                    }
                }
                
            case let .viewEvent(.alertOkTap(item)):
                if item.ifNeedID == "중단" {
                    state.alertComponents = nil
                    return .run { send in
                        await send(.delegate(.dismiss))
                    }
                }
                else if item.ifNeedID == "완료" {
                    state.alertComponents = nil
                    return .run { send in
                        await send(.delegate(.succressItem))
                    }
                }
                else if item.ifNeedID == "수정완료",
                        let model = state.modiferModel,
                        case let .modifier(_, idx)  = state.stateMode {
                    
                    state.alertComponents = nil
                    return .run { send in
                        await send(.delegate(.successModifer(model, idx: idx)))
                    }
                }
                else {
                    state.alertComponents = nil
                }
                
                // MARK: FeatureEVENT
            case let .featureEvent(.errorHandling(error)):
                state.loading = false
                guard case let .serverMessage(message) = error else {
                    return .none
                }
                
                if case .postLimitExceeded = message {
                    let alertComponents = GBAlertViewComponents(
                        title: "등록 한도 초과",
                        message: "살깔말까 글 작성 한도 초과하였습니다.",
                        okTitle: "확인",
                        alertStyle: .warningWithWarning
                    )
                    
                    state.alertComponents = alertComponents
                }
                
            case .featureEvent(.successRegister):
                state.loading = false
                let text = "글 작성"
                let alertComponents = GBAlertViewComponents(
                    title: "살까말까 \(text) 완료",
                    message: "24시간 이후 투표결과를\n확인할 수 있도록 알려드려요!",
                    okTitle: "확인",
                    alertStyle: .checkWithNormal,
                    ifNeedID: "완료"
                )
                
                state.alertComponents = alertComponents
                
            case let .featureEvent(.successModifier(model)):
                state.loading = false
                state.modiferModel = model
                let text = "글 수정"
                let alertComponents = GBAlertViewComponents(
                    title: "살까말까 \(text) 완료",
                    message: "24시간 이후 투표결과를\n확인할 수 있도록 알려드려요!",
                    okTitle: "확인",
                    alertStyle: .checkWithNormal,
                    ifNeedID: "수정완료"
                )
                
                state.alertComponents = alertComponents
                
                // MARK: Binding
            case let .bindingAlertComponents(components):
                state.alertComponents = components
                
            case let .bindingItemText(text):
                if !(text.count > 20) {
                    state.itemText = text
                }
                
                return .send(.debouncedCheckAll)
                
            case let .bindingPriceText(text):
                if !(text.count > 9) {
                    let text = text.replacingOccurrences(of: ",", with: "")
                    let price = numberFormatter.changeForCommaNumber(text)
                    state.priceText = price
                }
                return .send(.debouncedCheckAll)
                
            case let .bindingBuyText(text):
                if !(text.count > 20) {
                    state.buyText = text
                }
                return .send(.debouncedCheckAll)
            case let .bindingBuyNotText(text):
                
                if !(text.count > 20) {
                    state.notBuyText = text
                }
                return .send(.debouncedCheckAll)
                
            case .debouncedCheckAll:
                let bool = checkAll(state: state)
                state.currentOkButtonState = bool
                return .none
            default:
                break
            }
            return .none
        }
    }
}

extension BuyOrNotAddViewFeature {
    
    private func checkAll(state: inout State) -> EffectOf<Self> {
        let newValue: Bool = {
            guard
                let _ = (state.itemText.isEmpty ? nil : state.itemText),
                let _ = (state.priceText.isEmpty ? nil : state.priceText),
                let _ = (state.buyText.isEmpty ? nil : state.buyText),
                let _ = (state.notBuyText.isEmpty ? nil : state.notBuyText),
                (state.currentImageData != nil || state.ifImageURL != nil)
            else {
                return false
            }
            return true
        }()
        
        if state.currentOkButtonState != newValue {
            state.currentOkButtonState = newValue
        }
        return .none
    }
    
    private func checkAll(state: State) -> Bool {
        let newValue: Bool = {
            guard
                let _ = (state.itemText.isEmpty ? nil : state.itemText),
                let _ = (state.priceText.isEmpty ? nil : state.priceText),
                let _ = (state.buyText.isEmpty ? nil : state.buyText),
                let _ = (state.notBuyText.isEmpty ? nil : state.notBuyText),
                (state.currentImageData != nil || state.ifImageURL != nil)
            else {
                return false
            }
            return true
        }()
        
        return newValue
    }
    
}

