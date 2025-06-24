//
//  GBAppDelegate.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import UIKit
import ComposableArchitecture
import Firebase
import Utils
import Data

@MainActor
class GBAppDelegate: NSObject, UIApplicationDelegate {
    
    @Dependency(\.pushNotiManager) var pushManager
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FireBaseManager.config()
        
        let token = FireBaseManager.getFCMToken()
        UserDefaultsManager.fcmRegistrationToken = token
        
        NotificationCenter.default.addObserver(
            forName: .requestRemoteNotification,
            object: nil,
            queue: .main
        ) { [weak application] _ in
            DispatchQueue.main.async {
                application?.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Logger.debug("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
        
        let deviceToken = FireBaseManager.regDeviceToken(deviceToken: deviceToken)
        pushManager.setDeviceToken(token: deviceToken)
        
        FireBaseManager.reCheckFCMToken { [weak self] token in
            guard let self else { return }
            guard let _ = token else { return }
            if let reCheckToken = FireBaseManager.getFCMToken() {
                pushManager.setServerToToken(token: reCheckToken)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: any Error) {
        pushManager.sendToError()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Logger.debug("🔔 푸시 알림 수신 (포그라운드) 혹은 백그라운드 🔔")
        UserDefaultsManager.fcmReciveCount += 1
        pushManager.setBadgeCount()
        completionHandler(.newData)
    }
}
