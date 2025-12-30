//
//  FireBaseManager.swift
//  Utils
//
//  Created by Jae hyung Kim on 6/24/25.
//

import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import Domain

public let FireBaseManager = _FireBaseManager.shared

public final class _FireBaseManager: NSObject, Sendable {
    
    public func config() {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
    }
    
    public func getFCMToken() -> String? {
        return Messaging.messaging().fcmToken
    }
    
    public func regDeviceToken(deviceToken: Data) -> String {
        Messaging.messaging().apnsToken = deviceToken
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        return deviceToken
    }
    
    public func reCheckFCMToken(completion: @escaping (String?) -> Void)  {
        Messaging.messaging().token { [weak self] token, error in
            guard let weakSelf = self else { return }
            guard let token else {
                Logger.error("no TOKEN From FCM")
                completion(nil)
                return
            }
            completion(token)
        }
    }
    
    public func logEvent(log: FireBaseLog) {
        Analytics.setUserID("userID = \(log.userID ?? "NONE")")
        Analytics.setUserProperty("ko", forName: "Country")
        Analytics.logEvent(logType(log.logType), parameters: nil)
        Analytics.logEvent(log.eventName, parameters: log.parameters)
    }
    
    private func logType(_ type: FireBaseLogType) -> String {
        switch type {
        case .login:
            return AnalyticsEventLogin
        }
    }
}

extension _FireBaseManager {
    static let shared = _FireBaseManager()
}


extension _FireBaseManager: MessagingDelegate {
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FireBase registration Token: \(String(describing: fcmToken))")
        guard let fcmToken = fcmToken else { return }
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
