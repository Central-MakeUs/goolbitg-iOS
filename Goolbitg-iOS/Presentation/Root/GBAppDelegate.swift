//
//  GBAppDelegate.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import UIKit
import ComposableArchitecture
import FirebaseCore
import FirebaseMessaging
import SwiftyBeaver

let Logger = SwiftyBeaver.self

class GBAppDelegate: NSObject, UIApplicationDelegate {
    
    @Dependency(\.pushNotiManager) var pushManager
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        UserDefaultsManager.fcmRegistrationToken = Messaging.messaging().fcmToken
        
        NotificationCenter.default.addObserver(forName: .requestRemoteNotification, object: nil, queue: .main) { _ in
            application.registerForRemoteNotifications()
        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Logger.debug("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushManager.setDeviceToken(token: deviceToken)
        
        Messaging.messaging().token { token, _ in
            Logger.debug("💜😀 \(token ?? "nil")")
        }
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: any Error) {
        pushManager.sendToError()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}


extension GBAppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FireBase registration Token: \(String(describing: fcmToken))")
        guard let fcmToken = fcmToken else { return }
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
