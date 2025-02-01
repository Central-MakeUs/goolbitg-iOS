//
//  MyPageTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case home(MyPageViewFeature)
}

@Reducer
struct MyPageTabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.home(MyPageViewFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<MyPageScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MyPageScreen>)
    }
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension MyPageTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
