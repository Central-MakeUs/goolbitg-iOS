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
import TipKit

@main
struct Goolbitg_iOSApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: GBAppDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: SecretKeys.kakaoNative)
    }
    
    var body: some Scene {
        WindowGroup {
//            SelectExpenditureDateView(store: Store(initialState: ExpressExpenditureDateViewFeature.State(), reducer: {
//                ExpressExpenditureDateViewFeature()
//            }))
//            ComsumptionHabitsView(store: Store(initialState: ComsumptionHabitsViewFeature.State(), reducer: {
//                ComsumptionHabitsViewFeature()
//            }))
//            ShoppingCheckListView(store: Store(initialState: ShoppingCheckListViewFeature.State(), reducer: {
//                ShoppingCheckListViewFeature()
//            }))
//            AuthRequestView(store: Store(initialState: AuthRequestFeature.State(), reducer: {
//                AuthRequestFeature()
//            }))
//            AuthPageView()
            GBLoginView(store: Store(initialState: LoginViewFeature.State(), reducer: {
                LoginViewFeature()
            }))
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
