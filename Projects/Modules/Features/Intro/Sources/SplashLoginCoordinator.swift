//
//  SplashLoginCoordinator.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators
import Data
import Utils
import FeatureCommon

@Reducer(state: .hashable)
public enum SplashLoginScreen {
    case splash(SplashFeature)
    case login(LoginViewFeature)
    case authRequestPage(AuthRequestPageFeature)
    case userInfoRequestView(AuthRequestFeature)
    case analysisView(AnalysisFeature)
    case shoppingCheckListView(ShoppingCheckListViewFeature)
    case habitCheckView(ComsumptionHabitsViewFeature)
    case dayTimeCheckView(ExpressExpenditureDateViewFeature)
    case analyzingConsumption(AnalyzingConsumptionFeature)
    case resultHabit(ResultHabitFeature)
    case challengeAdd(ChallengeAddViewFeature)
}

@Reducer
public struct SplashLoginCoordinator {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable, Hashable {
        public static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])
        
        public var routes: IdentifiedArrayOf<Route<SplashLoginScreen.State>>
    }
    
    public enum Action {
        case router(IdentifiedRouterActionOf<SplashLoginScreen>)
        
        case checkUserState
        case checkToMoveScreen(caseOf: RegisterStatusCase)
        case moveToScreen(MoveToScreen)
        
        case checkToRefresh
        case failRefresh
        case delegate(Delegate)
        
        public enum Delegate {
            case moveToHome
        }
    }
    
    public enum MoveToScreen {
        case authRequest
        case userInfoRequest
        case analysis
        case shoppingListView
        case habitView
        case expressExpenditureDateView
        case analyzingConsumption
        case challengeAdd
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.albumAuthManager) var albumAuthManager
    @Dependency(\.pushNotiManager) var pushNotiManager
    
    public var body: some ReducerOf<Self> {
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
                    
                    try await networkManager.tryRefresh()
                    
                    // MARK: 로그인 되면 이동시켜 줘야함
                    await send(.checkUserState)
                
                } catch: { error, send in
                    guard let _ = error as? RouterError else {
                        await send(.failRefresh)
                        return
                    }
                    await send(.failRefresh)
                }
        
            case .checkUserState:
                return checkUserRegistration(state: &state)
                
            case .router(.routeAction(id: .authRequestPage, action: .authRequestPage(.delegate(.nextView)))):
                
                return checkUserRegistration(state: &state)
                
            case .failRefresh:
                state.routes.push(.login(LoginViewFeature.State()))
                
            case let .router(.routeAction(id: .login, action: .login(.delegate(.moveToOnBoarding(caseOf))))):
                Logger.info(caseOf)
                // MARK: 앱 권한 확인
                return .send(.checkToMoveScreen(caseOf: caseOf))
                
                /// 유저 정보 리퀘스트
            case .router(.routeAction(id: .userInfoRequestView, action: .userInfoRequestView(.delegate(.successNextView)))):
                return .send(.moveToScreen(.analysis))
                /// 가짜 분석 뷰
            case .router(.routeAction(id: .analysisView, action: .analysisView(.delegate(.nextView)))):
                return .send(.moveToScreen(.shoppingListView))
                /// 체크리스트 뷰
            case .router(.routeAction(id: .shoppingCheckListView, action: .shoppingCheckListView(.delegate(.nextView)))):
                return .send(.moveToScreen(.habitView))
                /// 소비 습관 점수 뷰
            case .router(.routeAction(id: .habitCheckListView, action: .habitCheckView(.delegate(.nextView)))):
                return .send(.moveToScreen(.expressExpenditureDateView))
                /// 지출 요일/ 시간 선택
            case .router(.routeAction(id: .exDayTimeCheckView, action: .dayTimeCheckView(.delegate(.nextView)))):
                return .send(.moveToScreen(.analyzingConsumption))
                
            case let .router(.routeAction(id: .analyzingConsumption, action: .analyzingConsumption(.delegate(.tossToResult(userModel))))):
                state.routes.push(.resultHabit(ResultHabitFeature.State(userModel: userModel)))
                
            case .router(.routeAction(id: .resultHabit, action: .resultHabit(.delegate(.nextView)))):
                return .send(.moveToScreen(.challengeAdd))
             
            case .router(.routeAction(id: .challengeAdd, action: .challengeAdd(.delegate(.moveToHome)))):
                return .send(.delegate(.moveToHome))
                
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
                case .habitView:
                    state.routes.push(.habitCheckView(ComsumptionHabitsViewFeature.State()))
                case .expressExpenditureDateView:
                    state.routes.push(.dayTimeCheckView(ExpressExpenditureDateViewFeature.State()))
                case .analyzingConsumption:
                    state.routes.push(.analyzingConsumption(AnalyzingConsumptionFeature.State()))
                case .challengeAdd:
                    state.routes.push(.challengeAdd(ChallengeAddViewFeature.State(dismissButtonHidden: true)))
                }
                
            case let .checkToMoveScreen(caseOf):
                return .run { send in
                    if await checkAuthState() {
                        await send(.moveToScreen(.authRequest))
                    } else {
                        switch caseOf {
                        case .onBoarding1:
                            await send(.moveToScreen(.userInfoRequest)) // 1. 약관동의
                        case .onBoarding2:
                            await send(.moveToScreen(.userInfoRequest)) // 2. 사용자 개인정보 등록
                        case .onBoarding3:
                            await send(.moveToScreen(.analysis)) // 3. 소비유형 검사가 있어요 -> 소비중독
                        case .onBoarding4:
                            await send(.moveToScreen(.habitView)) // 4. 소비 슴관
                        case .onBoarding5:
                            await send(.moveToScreen(.expressExpenditureDateView)) // 옵션
                        case .onBoarding6:
                            await send(.moveToScreen(.challengeAdd)) // 5. 챌린지 추가
                        case .registEnd: // 등록완료
                            await send(.delegate(.moveToHome))
                        }
                    }
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
        if AuthTokenStorage.accessToken != nil {
            // accessToken 이 존재한다면 재 갱신 시도
            return .send(.checkToRefresh)
        } else {
            state.routes.push(.login(LoginViewFeature.State()))
        }
        return .none
    }
    
    /// 앱 권한 허용 여부 판단
    /// - Returns: true 일때 권한 요청 페이지 false 면 딥링크 따라 바로
    private func checkAuthState() async -> Bool {
        if UserDefaultsManager.firstDevice {
            let _ = albumAuthManager.currentAlbumPermission() == .noOnce
            let noti = await pushNotiManager.getNotificationCurrentSetting() == .noOnce
            
            if /*album ||*/ noti {
                return true
            }
        }
        return false
    }
    
    private func checkUserRegistration(state: inout State) -> EffectOf<Self> {
        return .run { send in
            let requestRegisterState = try await networkManager.requestNetworkWithRefresh(dto: UserRegisterStatus.self, router: UserRouter.userRegisterStatus)
            
            Logger.info(requestRegisterState)
            
            // 필수 기입사항 안했을시
            if !requestRegisterState.requiredInfoCompleted {
                await send(.checkToMoveScreen(caseOf: requestRegisterState.status))
            } else {
                await send(.checkToMoveScreen(caseOf:.registEnd))
            }
        }
    }
}
