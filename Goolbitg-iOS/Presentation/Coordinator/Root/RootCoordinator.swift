//
//  RootCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators


@Reducer
struct RootCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        var currentView: ChangeRootView = .splashLogin
        
        var alertItem: GBAlertViewComponents? = nil
        
        var splashLogin = SplashLoginCoordinator.State.initialState
        
        var tabState = TabNavigationCoordinator.State.initialState
        
        var onAppear = false
    }
    
    enum Action {
        case splashLoginAction(SplashLoginCoordinator.Action)
        case tabAction(TabNavigationCoordinator.Action)
        case onAppear
        
        case changeView(ChangeRootView)
        case deepLink(DeepLinkCase)
        
        case alertItem(GBAlertViewComponents?)
        case confirmCase(GBAlertViewComponents)
        
        case getRouterError(RouterError)
        
        case subscribeToBackground
        case onAppearFromBackground
        case resetTab
    }
    
    enum ChangeRootView {
        case splashLogin
        case mainTab
    }
    
    enum CancelID: Hashable {
        case networkError
        case onActive
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.splashLogin, action: \.splashLoginAction) {
            SplashLoginCoordinator()
        }
        Scope(state: \.tabState, action: \.tabAction) {
            TabNavigationCoordinator()
        }
        
        core
    }
}

extension RootCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                if state.onAppear {
                    state.onAppear = false
                    
                    return .run { send in
                        for await error in networkManager.getNetworkError() {
                            await send(.getRouterError(error))
                        }
                        await send(.subscribeToBackground)
                    }
                    .debounce(id: CancelID.networkError, for: 1, scheduler: DispatchQueue.main.eraseToAnyScheduler())
                    
                }
                
            case .splashLoginAction(.delegate(.moveToHome)):
                state.currentView = .mainTab
                return .send(.tabAction(.router(.routeAction(id: .tabView, action: .tabView(.currentTab(.homeTab))))))
                
            case .tabAction(.router(.routeAction(id: .tabView, action: .tabView(.myPageTabAction(.router(.routeAction(id: .home, action: .home(.delegate(.logOutEvent))))))))):
                state.splashLogin.routes.popToRoot()
                state.currentView = .splashLogin
                
            case .tabAction(.router(.routeAction(id: .tabView, action: .tabView(.myPageTabAction(.router(.routeAction(id: .revokePage, action: .revokePage(.delegate(.revokedEvent))))))))):
                
                state.currentView = .splashLogin
                state.splashLogin.routes.popToRoot()
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.resetTab)
                }
                
            case .resetTab:
                state.tabState = .initialState
                
            case .alertItem(let item):
                state.alertItem = item
                
            case .getRouterError(let error):
                
                guard case .serverMessage(let entity) = error else {
                    UserDefaultsManager.resetUser()
                    state.splashLogin.routes.popToRoot()
                    state.currentView = .splashLogin
                    return .none
                }
                
                if entity == .tokenExpiration || entity == .noCredentials || entity == .notRegisteredMember {
                    state.currentView = .splashLogin
                    state.splashLogin.routes.push(.login(LoginViewFeature.State()))
                }
                
            case .onAppearFromBackground:
                if !UserDefaultsManager.accessToken.isEmpty && !UserDefaultsManager.refreshToken.isEmpty {

                    return .run { send in
                        let result = try await networkManager.requestNetworkWithRefresh(
                            dto: AccessTokenDTO.self,
                            router: AuthRouter.refresh(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        
                        UserDefaultsManager.accessToken = result.accessToken
                        UserDefaultsManager.refreshToken = result.refreshToken
                    } catch: { error, send in
                        guard let error = error as? RouterError else {
                            await send(.getRouterError(.unknown(errorCode: "9999")))
                            return
                        }
                        await send(.getRouterError(error))
                    }
                }
                
            default:
                break
            }
            return .none
        }
    }
}

extension RootCoordinator {
    private func deepLinkAction(_ deepLink: DeepLinkCase, state: inout State) {
        switch deepLink {
        case .userInfo:
            state.splashLogin.routes.push(.userInfoRequestView(AuthRequestFeature.State()))
        }
    }
}
