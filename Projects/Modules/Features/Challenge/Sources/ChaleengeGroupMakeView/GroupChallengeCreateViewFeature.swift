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
    }
    
    public enum Action {
        case viewAction(ViewAction)
        
        // MARK: Binding
        case inputChallengeNameText(String)
        case inputChallengePriceText(String)
        case inputHashTagText(String)
        case inputSecretRoomState(Bool)
        case inputPasswordText(String)
        case inputSecretRoomStateAnimation(Bool)
        
        // MARK: DELEGETE
        case delegate(Delegate)
    }
    
    public enum ViewAction {
        case tappedDismiss
        case hashTagAddTapped
        case deleteHashTagTapped(index: Int)
        case maxLeadingButtonTapped
        case maxTrailingButtonTapped
    }
    
    public enum Delegate {
        case dismiss
    }
    
    public static let currentLowCount = 2 // DEFAULT
    public static let currentMaxCount = 10
    
    public var body: some ReducerOf<Self> {
        addCore
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
                return .send(.delegate(.dismiss))
                
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
