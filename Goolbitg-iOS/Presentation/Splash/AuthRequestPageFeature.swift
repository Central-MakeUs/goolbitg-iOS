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
    struct State: Equatable {}
    
    enum Action {
        case startButtonTapped
        
        case delegate(Delegate)
        
        enum Delegate {
            case nextView
        }
    }
    
    @Dependency(\.pushNotiManager) var pushManager
    @Dependency(\.cameraManager) var cameraManager
    @Dependency(\.albumAuthManager) var albumAuthManager
    
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
                    
                    if result {
                        // 알림 허용 하셨습니다. 팝업
                        // 서버 관련 API 여부 대기중

                    } else {
                        // 알림 거부 하였습니다. 팝업
                        
                    }
                    await send(.delegate(.nextView))
                }
                
            default:
                break
            }
            return .none
        }
    }
}
