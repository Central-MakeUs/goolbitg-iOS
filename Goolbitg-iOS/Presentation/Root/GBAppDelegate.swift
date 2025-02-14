//
//  GBAppDelegate.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import UIKit
import ComposableArchitecture
import SwiftyBeaver

let Logger = SwiftyBeaver.self

class GBAppDelegate: NSObject, UIApplicationDelegate {
    
    @Dependency(\.pushNotiManager) var pushManager
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        pushManager.setDeviceToken(token: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: any Error) {
        pushManager.sendToError()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

