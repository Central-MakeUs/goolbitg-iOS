//
//  BuyOtNotAddViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BuyOrNotAddViewFeature: GBReducer {
    
    @ObservableState
    struct State: Equatable {
        var currentImageData: Data? = nil // 무조건 JPEG 로 변환
        var alertComponents: GBAlertViewComponents? = nil
        
        var itemText = ""
        var priceText = ""
        var buyText = ""
        var notBuyText = ""
        
        var currentOkButtonState = false
        var loading = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        
        case delegate(Delegate)
        
        case bindingAlertComponents(GBAlertViewComponents?)
        case bindingItemText(String)
        case bindingPriceText(String)
        case bindingBuyText(String)
        case bindingBuyNotText(String)
        
        enum Delegate {
            case dismiss
            case succressItem
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case imageResults(Data?)
        case alertOkTap(GBAlertViewComponents)
        case okButtonTapped
        case dismiss
    }
    
    enum FeatureEvent {
        case successRegister
        case errorHandling(RouterError)
    }
    
    @Dependency(\.gbNumberForMatter) var numberFormatter
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotAddViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                
                break
            case .viewEvent(.dismiss):
                
                let alertComponents = GBAlertViewComponents(
                    title: "살까말까 글 작성 중단",
                    message: "살깔말까 글 작성을\n정말 중단하시겠어요?",
                    cancelTitle: "취소",
                    okTitle: "중단",
                    alertStyle: .warningWithWarning,
                    ifNeedID: "중단"
                )
                
                state.alertComponents = alertComponents
                
            case let .viewEvent(.imageResults(data)):
                state.currentImageData = data
                
                return checkAll(state: &state)
                
            case .viewEvent(.okButtonTapped):
                if let imgData = state.currentImageData,
                   state.currentOkButtonState,
                   let price = Int(
                    state.priceText
                        .replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: " ", with: "")
                   ) {
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
                        Logger.debug("IMAGE URL : \(imageResult.url)")
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
                let alertComponents = GBAlertViewComponents(
                    title: "살까말까 글 작성 완료",
                    message: "24시간 이후 투표결과를\n확인할 수 있도록 알려드려요!",
                    okTitle: "확인",
                    alertStyle: .checkWithNormal,
                    ifNeedID: "완료"
                )
                
                state.alertComponents = alertComponents
                
            // MARK: Binding
            case let .bindingAlertComponents(components):
                state.alertComponents = components
                
            case let .bindingItemText(text):
                if !(text.count > 20) {
                    state.itemText = text
                }
                
                return checkAll(state: &state)
            case let .bindingPriceText(text):
                if !(text.count > 9) {
                    let text = text.replacingOccurrences(of: ",", with: "")
                    let price = numberFormatter.changeForCommaNumber(text)
                    state.priceText = price
                }
                return checkAll(state: &state)
            case let .bindingBuyText(text):
                if !(text.count > 20) {
                    state.buyText = text
                }
                return checkAll(state: &state)
            case let .bindingBuyNotText(text):
                
                if !(text.count > 20) {
                    state.notBuyText = text
                }
                return checkAll(state: &state)
            default:
                break
            }
            return .none
        }
    }
}

extension BuyOrNotAddViewFeature {
    
    private func checkAll(state: inout State) -> EffectOf<Self> {
        guard let _ = state.currentImageData,
              let _ = (state.itemText.isEmpty ? nil : state.itemText),
              let _ = (state.priceText.isEmpty ? nil : state.priceText),
              let _ = (state.buyText.isEmpty ? nil : state.buyText),
              let _ = (state.notBuyText.isEmpty ? nil : state.notBuyText)
        else {
            state.currentOkButtonState = false
            return .none
        }
        state.currentOkButtonState = true
        return .none
    }
    
}
