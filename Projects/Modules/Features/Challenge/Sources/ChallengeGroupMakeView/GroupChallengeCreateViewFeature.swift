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
        var hashTagText = ""
        var passwordText = ""
        var hashTagList: [String] = []
        var currentMaxCount = 2
        var maxLeadingButtonState: Bool = false
        var maxTrailingButtonState: Bool = true
        var secretRoomState = false
        var alertViewComponent: GBAlertViewComponents? = nil
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
    }
    
    public enum Delegate {
        case dismiss
    }
    
    public enum PopupViewAction {
        case ok
        case cancel
    }
    
    public enum AlertID: String, CaseIterable {
        case roomCreateStopAlert
    }
    
    public enum FeatureAction {
        case alertShow(alertID: AlertID)
    }
    
    
    public static let currentLowCount = 2 // DEFAULT
    public static let currentMaxCount = 10
    
    public var body: some ReducerOf<Self> {
        addCore
        alertCore
    }
}

extension GroupChallengeCreateViewFeature {
    private var addCore: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .inputChallengeNameText(text):
                state.challengeName = text
                
            case let .inputChallengePriceText(text):
                state.challengePrice = text
                
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
                
            case let .inputPasswordText(text):
                state.passwordText = text
                
            // MARK: View Action
            case .viewAction(.hashTagAddTapped): // Hash Tag Button 클릭
                let current = state.hashTagText
                state.hashTagText = ""
                state.hashTagList.append( "#"+current )
                
            case let .viewAction(.deleteHashTagTapped(index)):
                state.hashTagList.remove(at: index)
                
            case .viewAction(.maxLeadingButtonTapped):
                state.currentMaxCount -= 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
            case .viewAction(.maxTrailingButtonTapped):
                state.currentMaxCount += 1
                return checkLeadingTrailingButtonEnable(state: &state)
                
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
