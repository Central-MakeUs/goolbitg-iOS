//
//  Goolbitg_iOSApp.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth
import Utils
import SwiftyBeaver
import Data

@main
struct Goolbitg_iOSApp: App {
    
    @UIApplicationDelegateAdaptor(GBAppDelegate.self) var delegate
    
    init() {
        KakaoSDK.initSDK(appKey: SecretKeys.kakaoNative)
        let console = ConsoleDestination()
        Logger.addDestination(console)
#if DEV
        Logger.debug("Dev")
#elseif STAGE
        Logger.debug("Stage")
#else
        Logger.debug("Live")
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(store: Store(
                initialState: RootCoordinator.State(),
                reducer: {
                    RootCoordinator()
                }))
            .onOpenURL { url in
                DispatchQueue.main.async {
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
            }
        }
    }
}
