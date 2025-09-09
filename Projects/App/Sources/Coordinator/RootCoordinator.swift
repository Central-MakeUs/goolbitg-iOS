//
//  RootCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators
@preconcurrency import Data
import Utils
import FeatureTab
import FeatureIntro


@Reducer
struct RootCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        var currentView: ChangeRootView = .splashLogin
        
        var alertItem: GBAlertViewComponents? = nil
        
        var splashLogin = SplashLoginCoordinator.State.initialState
        
        var tabState = TabNavigationCoordinator.State.initialState
        
        var onAppear = true
        
        var showAppStorePopup: Bool = false
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
        
        case showMoveToAppStore
        case bindingAppStore(Bool)
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
    @Dependency(\.appVersionUpdateManager) var appVersionManager
    
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
                        if let appResult = await appVersionManager.checkBuildVersionUpdate() {
                            if appResult {
                                await send(.showMoveToAppStore)
                                return
                            }
                        }
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
                
                switch error {
                case .decodingFail, .encodingFail, .cancel, .errorModelDecodingFail:
                    return .none
                    
                case .refreshFailGoRoot:
                    UserDefaultsManager.resetUser()
                    state.splashLogin.routes.popToRoot()
                    state.currentView = .splashLogin
                    return .none
                    
                case .serverMessage(let entity):
                    if entity == .tokenExpiration || entity == .noCredentials || entity == .notRegisteredMember {
                        state.currentView = .splashLogin
                        state.splashLogin.routes.push(.login(LoginViewFeature.State()))
                    }
                    
                default:
                    UserDefaultsManager.resetUser()
                    state.splashLogin.routes.popToRoot()
                    state.currentView = .splashLogin
                }
                
            case .onAppearFromBackground:
                if !UserDefaultsManager.accessToken.isEmpty && !UserDefaultsManager.refreshToken.isEmpty {

                    return .run { send in
#if DEV
                        if UserDefaultsManager.rootLoginUser {
                            await RootLoginManager.login()
                        }
#else
                        let result = try await networkManager.requestNetworkWithRefresh(
                            dto: AccessTokenDTO.self,
                            router: AuthRouter.refresh(
                                refreshToken: UserDefaultsManager.refreshToken
                            )
                        )
                        UserDefaultsManager.accessToken = result.accessToken
                        UserDefaultsManager.refreshToken = result.refreshToken
#endif
                    } catch: { error, send in
                        guard let error = error as? RouterError else {
                            await send(.getRouterError(.unknown(errorCode: "9999")))
                            return
                        }
                        await send(.getRouterError(error))
                    }
                }
                
            case .showMoveToAppStore:
                state.showAppStorePopup = true
                
            /// 앱스토어 강제화 하기 위함
            case .bindingAppStore(_):
                state.showAppStorePopup = false
                return .run { send in
                    try? await Task.sleep(for: .seconds(1))
                    await send(.showMoveToAppStore)
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
