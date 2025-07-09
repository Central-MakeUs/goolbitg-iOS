//
//  GroupChallengeCreateViewFeature.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/28/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct GroupChallengeCreateViewFeature {
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        var challengeName = ""
        var challengePrice = ""
        var challengePriceError: String? = nil
        var hashTagText = ""
        var passwordText = ""
        var hashTagList: [String] = []
        var currentMaxCount = 2
        var maxLeadingButtonState: Bool = false
        var maxTrailingButtonState: Bool = true
        var secretRoomState = false
        var alertViewComponent: GBAlertViewComponents? = nil
        
        var currentState = false
    }
    
    public enum Action {
        case viewAction(ViewAction)
        case featureAction(FeatureAction)
        
        // MARK: Binding
        case inputChallengeNameText(String)
        case inputChallengePriceText(String)
        case inputHashTagText(String)
        case inputSecretRoomState(Bool)
        case inputPasswordText(String)
        case inputSecretRoomStateAnimation(Bool)
        
        // MARK: AlertBinding
        case roomCreateStopAlertComponent(GBAlertViewComponents?)
        
        // MARK: DELEGETE
        case delegate(Delegate)
    }
    
    public enum ViewAction {
        case tappedDismiss
        case hashTagAddTapped
        case deleteHashTagTapped(index: Int)
        case maxLeadingButtonTapped
        case maxTrailingButtonTapped
        case popUpViewAction(PopupViewAction)
        case createButtonTapped
    }
    
    public enum Delegate {
        case dismiss
        case createSuccess
    }
    
    public enum PopupViewAction {
        case ok
        case cancel
    }
    
    public enum AlertID: String, CaseIterable {
        case roomCreateStopAlert
        case createErrorToDuplicateRoomName
    }
    
    public enum FeatureAction {
        case alertShow(alertID: AlertID)
    }
    
    
    public static let currentLowCount = 2 // DEFAULT
    public static let currentMaxCount = 10
    
    @Dependency(\.networkManager) var networkManager
    
    public var body: some ReducerOf<Self> {
        addCore
        alertCore
    }
}

extension GroupChallengeCreateViewFeature {
    private var addCore: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
                
            case let .inputChallengeNameText(text):
                state.challengeName = text
                
                return checkedValid(state: &state)
                
            case let .inputChallengePriceText(text):
                if let price = Int(text) {
                    if price < 1000 || price > 50000 {
                        state.challengePriceError = "1000원에서 50,000원 사이로 입력해주세요."
                    } else {
                        state.challengePriceError = nil
                    }
                } else {
                    state.challengePriceError = "숫자만 입력해주세요."
                }
                state.challengePrice = text
                
                return checkedValid(state: &state)
                
            case let .inputHashTagText(text):
                state.hashTagText = text
                
            case let .inputSecretRoomState(bool):
                return .run { send in
                    await send(.inputSecretRoomStateAnimation(bool))
                }.animation()
                
            case let .inputSecretRoomStateAnimation(bool):
                state.secretRoomState = bool
                if !bool {
                    state.passwordText = ""
                }
                return checkedValid(state: &state)
                
            case let .inputPasswordText(text):
                guard let _ = Int(text),
                      text.count < 5 else  {
                    if text.isEmpty {
                        state.passwordText = ""
                    }
                    return .none
                }
                state.passwordText = text
                return checkedValid(state: &state)
                // MARK: View Action
            case .viewAction(.hashTagAddTapped): // Hash Tag Button 클릭
                if state.hashTagText.replacingOccurrences(of: " ", with: "")
                    .isEmpty {
                    state.hashTagText = ""
                } else {
                    let current = state.hashTagText
                    state.hashTagText = ""
                    state.hashTagList.append( "#"+current )
                }
                
                return checkedValid(state: &state)
                
            case let .viewAction(.deleteHashTagTapped(index)):
                state.hashTagList.remove(at: index)
                
                return checkedValid(state: &state)
                
            case .viewAction(.maxLeadingButtonTapped):
                state.currentMaxCount -= 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
            case .viewAction(.maxTrailingButtonTapped):
                state.currentMaxCount += 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
                // 생성하기 버튼
            case .viewAction(.createButtonTapped):
                guard let requestModel = makeRequestBody(state: state) else {
                    return .none
                }
                return .run { send in
                    let _ = try await networkManager.requestNetworkWithRefresh(
                        dto: GroupChallengeDTO.self,
                        router: ChallengeRouter.groupChallengeCreate(requestDTO: requestModel)
                    )
                    await send(.delegate(.createSuccess))
                } catch: {
                    error,
                    send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    if case .serverMessage(.duplicateChallengeName) = error {
                        await send(.featureAction(.alertShow(alertID: .createErrorToDuplicateRoomName)))
                    }
                }
                // 뒤로가기
            case .viewAction(.tappedDismiss):
                return .send(.featureAction(.alertShow(alertID: .roomCreateStopAlert)))
                
            default:
                break
            }
            return .none
        }
    }

    private func checkLeadingTrailingButtonEnable(state: inout State) -> Effect<Action> {
        state.maxLeadingButtonState = state.currentMaxCount > Self.currentLowCount
        state.maxTrailingButtonState = state.currentMaxCount < Self.currentMaxCount
        return .none
    }
    
    private func checkedValid(state: inout State) -> Effect<Action> {
        var currentState = false
        
        if !state.challengeName.isEmpty,
           !state.challengePrice.isEmpty,
           state.challengePriceError == nil,
           !state.hashTagList.isEmpty {
            currentState = true
        }
        
        if state.secretRoomState {
            currentState = state.passwordText.count == 4
        }
        
        state.currentState = currentState
        return .none
    }
    
    private func makeRequestBody(state: State) -> ChallengeGroupCreateRequestDTO? {
        guard let reward = Int(state.challengePrice) else {
            return nil
        }
        
        let removeSp = state.hashTagList.map { $0.replacingOccurrences(of: "#", with: "") }
        
        return ChallengeGroupCreateRequestDTO(
            title: state.challengeName,
            hashtags: removeSp,
            reward: reward,
            maxSize: state.currentMaxCount,
            isHidden: state.secretRoomState,
            password: state.passwordText.isEmpty ? nil : state.passwordText
        )
    }
}

// MARK: Alert
extension GroupChallengeCreateViewFeature {
    
    private var alertCore: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case let .featureAction(.alertShow(alertID)):
                return  showAlertHandler(state: &state, alertID: alertID)
                
            case let .roomCreateStopAlertComponent(component):
                state.alertViewComponent = component
                
            case let .viewAction(.popUpViewAction(actions)):
                guard let stateComponent = state.alertViewComponent,
                      let caseOf = AlertID.allCases.first(
                        where: {
                            $0.rawValue == stateComponent.ifNeedID
                        }) else {
                    return .none
                }
                switch caseOf {
                case .roomCreateStopAlert:
                    return groupCrateStopAlertAction(state: &state, action: actions)
                case .createErrorToDuplicateRoomName:
                    return .send(.roomCreateStopAlertComponent(nil))
                }
            default:
                break
            }
            return .none
        }
    }
    
    private func showAlertHandler(state: inout State, alertID: AlertID) -> Effect<Action> {
        let component: GBAlertViewComponents
        
        switch alertID {
        case .roomCreateStopAlert:
            component = GBAlertViewComponents(
                title: "작심삼일 생성 중단",
                message: "작심삼일 생성하기를\n정말 중단하시겠어요?",
                cancelTitle: "취소",
                okTitle: "중단",
                alertStyle: .warning,
                ifNeedID: alertID.rawValue
            )
        case .createErrorToDuplicateRoomName:
            component = GBAlertViewComponents(
                title: "생성 실패",
                message: "같은 이름의 챌린지가 이미 존재합니다.",
                okTitle: "확인",
                alertStyle: .warning,
                ifNeedID: alertID.rawValue
            )
        }
        
        state.alertViewComponent = component
        return .none
    }
    
    
    /// 그룹 생성을 정말 포기할건지에 대한 팝업의 뷰 액션에 따른 결과
    /// - Parameters:
    ///   - state: State
    ///   - action: PopupAction
    /// - Returns: Effect
    private func groupCrateStopAlertAction(
        state: inout State,
        action: PopupViewAction
    ) -> Effect<Action> {
        switch action {
        case .ok:
            return .run { send in
                await send(.delegate(.dismiss))
            }
        case .cancel:
            state.alertViewComponent = nil
            return .none
        }
    }
}
