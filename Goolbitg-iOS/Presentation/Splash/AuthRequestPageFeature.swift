//
//  AuthRequestPageFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AuthRequestPageFeature {
    
    @ObservableState
    struct State: Equatable {
        var alertAlertState: String?
    }
    
    enum Action {
        case startButtonTapped
        case alertAlertOKTapped
        case featureEvent(FeatureEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case nextView
        }
        
        case alertAlertState(String?)
    }
    
    enum FeatureEvent {
        case alertAuthState(Bool)
        case showPopUpAlert(String)
    }
    
    @Dependency(\.pushNotiManager) var pushManager
    @Dependency(\.cameraManager) var cameraManager
    @Dependency(\.albumAuthManager) var albumAuthManager
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        core
    }
}

extension AuthRequestPageFeature {
    private var core: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
                
            case .startButtonTapped:
                return .run { send in
                    // 허용 가정하고 푸시 테스트
                   let result = try await pushManager.requestNotificationPermission()
                    if result {
                        pushManager.getDeviceToken()
                    }
                    
                    await cameraManager.requestAuth()
                    
                    await albumAuthManager.requestAlbumPermission()
                    
                    let requestResult = try? await networkManager.requestNotDtoNetwork(router: UserRouter.currentUserInfos, ifRefreshNeed: true)
                    
                    await send(.featureEvent(.alertAuthState(requestResult ?? false)))
                }
            case let .featureEvent(.alertAuthState(result)):
                let date = Date()
                let today = DateManager.shared.format(format: .dicToDateForYYYYMMDD, date: date)
                
                if result {
                    // 알림 허용 하셨습니다. 팝업
                    // 서버 관련 API 여부 대기중
                    return .send(.featureEvent(.showPopUpAlert("PUSH 수신동의 처리가 완료되었습니다. (\(today))")))
                } else {
                    // 알림 거부 하였습니다. 팝업
                    return .send(.featureEvent(.showPopUpAlert("PUSH 수신거부 처리가 완료되었습니다. (\(today))")))
                }
                
            case let .featureEvent(.showPopUpAlert(text)):
                state.alertAlertState = text
            case let .alertAlertState(text):
                state.alertAlertState = text
                
            case .alertAlertOKTapped:
                state.alertAlertState = nil
                return .send(.delegate(.nextView))
                
            default:
                break
            }
            return .none
        }
    }
}
