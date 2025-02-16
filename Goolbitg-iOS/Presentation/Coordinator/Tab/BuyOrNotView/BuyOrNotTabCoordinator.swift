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
                state.routes.presentCover(.buyOrNotAdd(BuyOrNotAddViewFeature.State()))
                
            case .router(.routeAction(id: .add, action: .buyOrNotAdd(.delegate(.dismiss)))):
                state.routes.dismiss()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
