//
//  MyPageViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/31/25.
//

import Foundation
import ComposableArchitecture
import Utils
import Domain
import Data

@Reducer
public struct MyPageViewFeature: GBReducer {
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var userEntity: UserMyPageEntity = UserMyPageEntity.getSelf
        let version = MyPageViewFeature.getVersion
        var logoutAlert: GBAlertViewComponents? = nil
    }
    
    public enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        public enum Delegate {
            case logOutEvent
            case revokedEvent
            case pushButtonTapped
        }
        
        case alertState(GBAlertViewComponents?)
    }
    
    public enum ViewCycle {
        case onAppear
    }
    
    public enum ViewEvent {
        case alertButtonTapped
        case accountSectionItemTapped(item: AccountSectionType)
        case serviceSectionItemTapped(item: ServiceInfoSectionType)
        case logOutButtonTapped
        case acceptLogoutButtonTapped
        case revokeButtonTapped
    }
    
    public enum FeatureEvent {
        case requestUserInfo
        case resultUserInfo(result: UserMyPageEntity)
        case requestLogOut
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.userMapper) var userMapper
    @Dependency(\.moveURLManager) var moveURLManager
    @Dependency(\.appleLoginManager) var appleLoginManager
    
    public var body: some ReducerOf<Self> {
        viewCore
        core
    }
}

extension MyPageViewFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .featureEvent(.requestUserInfo):
                return .run { send in
                    let result = try await networkManager.requestNetworkWithRefresh(
                        dto: UserInfoDTO.self,
                        router: UserRouter.currentUserInfos
                    )
                    UserDefaultsManager.userNickname = result.nickname
                    UserDefaultsManager.userID = result.id
                    let mapping = userMapper.myPageUserMapping(model: result)
                    
                    await send(.featureEvent(.resultUserInfo(result: mapping)))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
            case let .featureEvent(.resultUserInfo(model)):
                state.userEntity = model
                
            case .featureEvent(.requestLogOut):
                return .run { send in
                    try await networkManager.requestNotDtoNetwork(router: AuthRouter.logOut, ifRefreshNeed: true)
                    UserDefaultsManager.accessToken = ""
                    UserDefaultsManager.refreshToken = ""
                    await send(.delegate(.logOutEvent))
                } catch: { error, send in
                    guard let error = error as? RouterError else {
                        return
                    }
                    Logger.error(error)
                }
                /// Binding
            case let .alertState(component):
                state.logoutAlert = component
                
            default:
                break
            }
            return .none
        }
    }
    
    private static var getVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary,
        let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        
        return version
    }
}

// MARK: View Core
extension MyPageViewFeature {
    
    private var viewCore: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.featureEvent(.requestUserInfo))
                    
                }
            // MARK: ViewEvent
            case .viewEvent(.logOutButtonTapped):
                state.logoutAlert = GBAlertViewComponents(
                    title: "로그아웃",
                    message: "정말 로그아웃을 하시겠어요?",
                    cancelTitle: "취소",
                    okTitle: "로그아웃",
                    alertStyle: .warning
                )
                
            case .viewEvent(.acceptLogoutButtonTapped):
                return .send(.featureEvent(.requestLogOut))
                
            case let .viewEvent(.serviceSectionItemTapped(item)):
                return .run { _ in
                    switch item {
                    case .appVersion:
                        break
                    case .request:
                        await moveURLManager.moveURL(caseOf: .inquiry)
                    case .serviceInfo:
                        await moveURLManager.moveURL(caseOf: .service)
                    case .privacyPolicy:
                        await moveURLManager.moveURL(caseOf: .privacy)
                    }
                }
                
            case .viewEvent(.revokeButtonTapped):
                return .send(.delegate(.revokedEvent))
                
            case .viewEvent(.alertButtonTapped):
                return .send(.delegate(.pushButtonTapped))
                
            default:
                break
            }
            return .none
        }
    }
}
