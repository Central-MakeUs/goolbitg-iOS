//
//  SplashLoginCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum SplashLoginScreen {
    case splash(SplashFeature)
    case login(LoginViewFeature)
    case authRequestPage(AuthRequestPageFeature)
}

@Reducer
struct SplashLoginCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<SplashLoginScreen.State>>
        var ifNeedDeepLink: String?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SplashLoginScreen>)
        
        case moveToScreen(MoveToScreen)
        
        case checkToRefresh
        case failRefresh
        case sendDeepLink(String)
    }
    
    enum MoveToScreen {
        case authRequest
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.albumAuthManager) var albumAuthManager
    @Dependency(\.pushNotiManager) var pushNotiManager
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension SplashLoginCoordinator {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: .splash, action: .splash(.delegate(.finish)))):
                
                return checkLoginState(&state)
                
            case .checkToRefresh:
                return .run { send in
                    
                    let result = try await networkManager.requestNetwork(dto: AccessTokenDTO.self, router: AuthRouter.refresh(refreshToken: UserDefaultsManager.refreshToken))
                    
                    UserDefaultsManager.accessToken = result.accessToken
                    UserDefaultsManager.refreshToken = result.refreshToken
                    
                    // MARK: 로그인 되면 이동시켜 줘야함
                
                } catch: { error, send in
                    guard let _ = error as? RouterError else {
                        await send(.failRefresh)
                        return
                    }
                    await send(.failRefresh)
                }
                
            case .router(.routeAction(id: .authRequestPage, action: .authRequestPage(.delegate(.nextView)))):
                break
                
            case .failRefresh:
                state.routes.push(.login(LoginViewFeature.State()))
                
            case let .router(.routeAction(id: .login, action: .login(.delegate(.deepLink(deepLink))))):
                state.ifNeedDeepLink = deepLink
                
                // MARK: 앱 권한 확인
                return .run { send in
                    if await checkAuthState() {
                        await send(.moveToScreen(.authRequest))
                    } else {
                        await send(.sendDeepLink(deepLink))
                    }
                }
                
            case let .moveToScreen(screen):
                switch screen {
                case .authRequest:
                    state.routes.push(.authRequestPage(AuthRequestPageFeature.State()))
                }
            default:
                break
            }
            return .none
        }
        .forEachRoute(
            \.routes,
             action: \.router
        )
    }
}

extension SplashLoginCoordinator {
    /// 로그인 체크
    private func checkLoginState(_ state: inout State) -> EffectOf<Self> {
        // MARK: 로그인 여부 확인 하고 어딜갈지 정해야함
        if UserDefaultsManager.accessToken != "" {
            // accessToken 이 존재한다면 재 갱신 시도
            state.routes.push(.login(LoginViewFeature.State()))
        } else {
            state.routes.push(.login(LoginViewFeature.State()))
        }
        return .none
    }
    
    /// 앱 권한 허용 여부 판단
    /// - Returns: true 일때 권한 요청 페이지 false 면 딥링크 따라 바로
    private func checkAuthState() async -> Bool {
        if UserDefaultsManager.firstDevice {
            let album = albumAuthManager.currentAlbumPermission() == .noOnce
            let noti = await pushNotiManager.getNotificationCurrentSetting() == .noOnce
            
            if album || noti {
                return true
            }
        }
        return false
    }
}
