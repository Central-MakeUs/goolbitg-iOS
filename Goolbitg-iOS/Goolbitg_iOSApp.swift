//
//  Goolbitg_iOSApp.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct Goolbitg_iOSApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: GBAppDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: SecretKeys.kakaoNative)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthPageView()
//            GBLoginView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
