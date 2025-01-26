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
    case userInfoRequestView(AuthRequestFeature)
    case analysisView(AnalysisFeature)
    case shoppingCheckListView(ShoppingCheckListViewFeature)
}

@Reducer
struct SplashLoginCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])
        
        var routes: IdentifiedArrayOf<Route<SplashLoginScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SplashLoginScreen>)
        
        case moveToScreen(MoveToScreen)
        
        case checkToRefresh
        case failRefresh
    }
    
    enum MoveToScreen {
        case authRequest
        case userInfoRequest
        case analysis
        case shoppingListView
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
                state.routes.push(.userInfoRequestView(AuthRequestFeature.State()))
                
            case .failRefresh:
                state.routes.push(.login(LoginViewFeature.State()))
                
            case let .router(.routeAction(id: .login, action: .login(.delegate(.moveToOnBoarding(caseOf))))):
                Logger.info(caseOf)
                // MARK: 앱 권한 확인
                return .run { send in
                    if await checkAuthState() {
                        await send(.moveToScreen(.authRequest))
                    } else {
                        switch caseOf {
                        case .onBoarding1:
                            await send(.moveToScreen(.userInfoRequest))
                        case .onBoarding2:
                            await send(.moveToScreen(.analysis))
                        case .onBoarding3:
                            break
                        case .onBoarding4:
                            break
                        case .registEnd:
                            break
                        }
                    }
                }
                
                /// 유저 정보 리퀘스트
            case .router(.routeAction(id: .userInfoRequestView, action: .userInfoRequestView(.delegate(.successNextView)))):
                return .send(.moveToScreen(.analysis))
                /// 가짜 분석 뷰
            case .router(.routeAction(id: .analysisView, action: .analysisView(.delegate(.nextView)))):
                return .send(.moveToScreen(.shoppingListView))
                
            case let .moveToScreen(screen):
                switch screen {
                case .authRequest:
                    state.routes.push(.authRequestPage(AuthRequestPageFeature.State()))
                case .userInfoRequest:
                    state.routes.push(.userInfoRequestView(AuthRequestFeature.State()))
                case .analysis:
                    state.routes.push(.analysisView(AnalysisFeature.State()))
                case .shoppingListView:
                    state.routes.push(.shoppingCheckListView(ShoppingCheckListViewFeature.State()))
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
