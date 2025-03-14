//
//  BuyOrNotTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum BuyOrNotTabCoordinatorScreen {
    case home(BuyOrNotTabViewFeature)
    case buyOrNotAdd(BuyOrNotAddViewFeature)
}

@Reducer
struct BuyOrNotTabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.home(BuyOrNotTabViewFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<BuyOrNotTabCoordinatorScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<BuyOrNotTabCoordinatorScreen>)
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension BuyOrNotTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.moveToAddView)))):
                state.routes.presentCover(.buyOrNotAdd(BuyOrNotAddViewFeature.State(stateMode: .add)))
                
            case .router(.routeAction(id: .add, action: .buyOrNotAdd(.delegate(.dismiss)))):
                state.routes.dismiss()
                
            case .router(.routeAction(id: .add, action: .buyOrNotAdd(.delegate(.succressItem)))):
                state.routes.dismiss()
                
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.newBuyOrNotItem)))))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.moveToModifierView(model, idx))))):
                
                state.routes.presentCover(.buyOrNotAdd(BuyOrNotAddViewFeature.State(stateMode: .modifier(model, idx: idx))))
                
            case let .router(.routeAction(id: .add, action: .buyOrNotAdd(.delegate(.successModifer(model, idx))))):
                
                state.routes.dismiss()
                return .send(.router(.routeAction(id: .home, action: .home(.parentEvent(.modifierSuccess(model, idx: idx))))))
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
