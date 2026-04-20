//
//  BuyOrNotTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import ComposableArchitecture
import Data

@Reducer
public struct BuyOrNotTabCoordinator {
    public init () {}

    @ObservableState
    public struct State: Equatable {
        public static let initialState = State()

        var home = BuyOrNotTabViewFeature.State()
    }
    
    public enum Action {
        case home(BuyOrNotTabViewFeature.Action)
        case delegate(Delegate)

        public enum Delegate {
            case moveToAddView
            case moveToModifierView(BuyOrNotCardViewEntity, idx: Int)
            case moveToChatView(String, userName: String, BuyOrNotCardViewEntity)
            case newBuyOrNotItem
            case modifierSuccess(BuyOrNotCardViewEntity, idx: Int)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            BuyOrNotTabViewFeature()
        }
        core
    }
}

extension BuyOrNotTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .home(.delegate(.moveToAddView)):
                return .send(.delegate(.moveToAddView))
                
            case let .home(.delegate(.moveToModifierView(model, idx))):
                return .send(.delegate(.moveToModifierView(model, idx: idx)))

            case let .home(.delegate(.moveToChatView(userID, userName, model))):
                return .send(.delegate(.moveToChatView(userID, userName: userName, model)))

            case .delegate(.newBuyOrNotItem):
                return .send(.home(.parentEvent(.newBuyOrNotItem)))

            case let .delegate(.modifierSuccess(model, idx)):
                return .send(.home(.parentEvent(.modifierSuccess(model, idx: idx))))
                
            default:
                break
            }
            return .none
        }
    }
}
