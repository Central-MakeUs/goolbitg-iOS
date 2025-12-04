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
import FeatureMyPage
import FeatureIntro

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


/*
 ResultHabitView(
     store: Store(
         initialState: ResultHabitFeature.State(
             userModel: UserInfoDTO(
                 id: "lvepndrzdj",
                 nickname: "ㅎㅎㅎ",
                 birthday: nil,
                 gender: "MALE",
                 check1: false,
                 check2: true,
                 check3: false,
                 check4: false,
                 check5: false,
                 check6: false,
                 avgIncomePerMonth: 5000000,
                 avgSpendingPerMonth: 55555,
                 primeUseDay: "THURSDAY",
                 primeUseTime: "20:10:05",
                 spendingHabitScore: 1,
                 spendingType: SpendingTypeDTO(
                     id: 3,
                     title: "룰루굴비",
                     imageURL: "https://goolbitg-bucket.s3.ap-northeast-2.amazonaws.com/spending_type/03.png",
                     profileUrl: "https://goolbitg-bucket.s3.ap-northeast-2.amazonaws.com/profile/03.png",
                     onboardingResultUrl: "https://goolbitg.s3.ap-northeast-2.amazonaws.com/onboardingResult_type/03.png",
                     goal: 100000,
                     peopleCount: 2
                 ),
                 challengeCount: 0,
                 postCount: 0,
                 achievementGuage: 0
             )
         ),
         reducer: {
     ResultHabitFeature()
 }
                             )
 )
 */
