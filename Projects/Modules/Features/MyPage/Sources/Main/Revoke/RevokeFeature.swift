//
//  RevokeFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/6/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct RevokeFeature {
    
    @ObservableState
    public struct State: Equatable {
        var item: RevokeCase? = nil
        
        var content: String = ""
    }
    
    public enum Action {
        case viewAction(ViewAction)
        case delegate(Delegate)
        case featureEvent(FeatureEvent)
        
        public enum Delegate {
            case revokedEvent
            case dismiss
        }
        
        case contentBinding(String)
    }
    
    public enum ViewAction {
        case selected(RevokeCase)
        case revokeButtonTapped
        case dismiss
    }
    
    public enum FeatureEvent {
        case appleRevoke
        case normalRevoke
    }
    
    @Dependency(\.appleLoginManager) var appleLoginManager
    @Dependency(\.networkManager) var networkManager
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension RevokeFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .viewAction(.selected(caseOf)):
                state.item = caseOf
                
            case .viewAction(.revokeButtonTapped):
                if UserDefaultsManager.ifAppleLoginUser {
                    return .send(.featureEvent(.appleRevoke))
                } else {
                    return .send(.featureEvent(.normalRevoke))
                }
                
            case .viewAction(.dismiss):
                return .send(.delegate(.dismiss))
                
            case let .contentBinding(text):
                state.content = text
                
            case .featureEvent(.appleRevoke):
                
                guard let caseOf = state.item else { return .none }
                
                var text = caseOf.title
                if caseOf == .other {
                    text = state.content
                }
                
                return .run { [text] send in
                    let result = try await appleLoginManager.getASAuthorization()
                    let (auth, _) = appleLoginManager.handleAuthorization(result)
                    
                    guard let auth else { return }
                    
                    let requestModel = RevokeRequestDTO(
                        reason: text,
                        authorizationCode: auth
                    )
                    
                    try await networkManager.requestNotDtoNetwork(router: AuthRouter.signOut(requestModel), ifRefreshNeed: true)
                    
                    UserDefaultsManager.resetUser()
                    
                    await send(.delegate(.revokedEvent))
                    
                } catch: { error, send in
                    Logger.error(error)
                }
                
            case .featureEvent(.normalRevoke):
                
                guard let caseOf = state.item else { return .none }
                var text = caseOf.title
                
                if caseOf == .other {
                    text = state.content
                }
                
                return .run { [text] send in
                    let requestModel = RevokeRequestDTO(
                        reason: text,
                        authorizationCode: nil
                    )
                    
                    try await networkManager.requestNotDtoNetwork(router: AuthRouter.signOut(requestModel), ifRefreshNeed: true)
                    
                    UserDefaultsManager.resetUser()
                    
                    await send(.delegate(.revokedEvent))
                } catch: { error, send in
                    Logger.error(error)
                }
                
            default:
                break
            }
            return .none
        }
    }
}
