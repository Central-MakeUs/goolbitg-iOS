//
//  MyPageTabCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import FeatureCommon

// (state: .hashable) 최신 버전에서 없어짐.
@Reducer
public enum MyPageScreen {
    case home(MyPageViewFeature)
    case revokePage(RevokeFeature)
    case pushList(PushListViewFeature)
    
}

extension MyPageScreen.State: Hashable {}

@Reducer
public struct MyPageTabCoordinator {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable, Hashable {
        public static let initialState = State(routes: [.root(.home(MyPageViewFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<MyPageScreen.State>>
    }
    
    public enum Action {
        case router(IdentifiedRouterActionOf<MyPageScreen>)
        case delegate(Delegate)
        
        public enum Delegate {
            case tabViewHidden
            case tabViewShow
        }
    }
    
    public var body: some ReducerOf<Self> {
        core
    }
}

extension MyPageTabCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .revokePage, action: .revokePage(.delegate(.dismiss)))):
                state.routes.dismiss()
                
            case .router(.routeAction(id: .pushList, action: .pushList(.delegate(.dismiss)))):
                state.routes.dismiss()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
    
    private var myPageCore: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .home, action: .home(.delegate(.revokedEvent)))):
//                state.routes.push(.revokePage(RevokeFeature.State()))
                state.routes.presentCover(.revokePage(RevokeFeature.State()))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.pushButtonTapped)))):
                state.routes.presentCover(.pushList(PushListViewFeature.State()))
                
//            case .router(.routeAction(id: .home, action: .home(.delegate(.habitChartMoveTapped)))):
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
