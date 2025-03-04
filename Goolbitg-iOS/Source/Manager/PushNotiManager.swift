//
//  PushNotiManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import UIKit
import ComposableArchitecture
import UserNotifications
import FirebaseMessaging
import Combine

final class PushNotiManager: NSObject, @unchecked Sendable {
    
    private let center = UNUserNotificationCenter.current()
    private var deviceToken = UserDefaultsManager.deviceToken
    private let publishPushError = PassthroughSubject<Void, Never>()
    
    let publishNewMessageCount = PassthroughSubject<Int, Never>()
    
    @Dependency(\.networkManager) var networkManager
    
    override init() {
        super.init()
        center.delegate = self
        
        center.getDeliveredNotifications { [weak self] notifications in
            guard let weakSelf = self else { return }
            Task {
                let result = await weakSelf.getNotificationCurrentSetting()
                guard result == .authorized else { return }
                await weakSelf.setBadgeCount()
            }
        }
    }
}

extension PushNotiManager {
    /// 푸시 알림 권한 요청 함수
    /// - Returns: 사용자 선택에 따른 결과
    @MainActor
    func requestNotificationPermission() async throws -> Bool {
        let result = try await center.requestAuthorization(options: [.alert, .badge, .sound] )
        if result {
            NotificationCenter.default.post(name: .requestRemoteNotification, object: nil)
        }
        return result
    }
    
    /// 사용자 푸시 권한 상태 확인 함수
    /// - Returns: PushAuthCase - 성공 실패 미확인
    func getNotificationCurrentSetting() async -> PushAuthCase {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: // 알림 권한 요청 한번도 X
            return .noOnce
        case .denied: // 거부
            return .denied
        case .authorized: // 알림 권한 요청 허용
            return .authorized
        case .provisional: // 조용한 알림 ( 베너 혹은 알림 센터 )
            return .authorized
        case .ephemeral: // 일시적 알림
            return .authorized
        @unknown default:
            return .noOnce
        }
    }

    /// 푸시알림 권한을 받은 경우 해당 함수를 통해 토큰을 저장
    /// - Parameter token: 저장할 디바이스 토큰
    func setDeviceToken(token: String) {
        UserDefaultsManager.deviceToken = token
        self.deviceToken = token
        print("deviceToken : \(token)")
    }
    
    /// 푸시 등록중 문제가 발생 할 경우 해당 함수가 실행됩니다.
    func sendToError() {
        self.publishPushError.send(())
    }

    /// 푸시 등록중 문제가 발생 할 경우 해당 Publsher가 이를 감지합니다.
    /// - Returns: AnyPublisher<Void>
    func getCurrentError() -> AnyPublisher<Void, Never> {
        return self.publishPushError.eraseToAnyPublisher()
    }
    
    func setServerToToken(token: String) {
        Task.detached { [weak self] in
            guard let self else { return }
            
            let _ = try? await networkManager.requestNotDtoNetwork(
                router: UserRouter.registrationFCMToken(
                    registrationToken: token
                ), ifRefreshNeed: true
            )
        }
    }
}

extension PushNotiManager: @preconcurrency UNUserNotificationCenterDelegate {
    
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions
    {
        Logger.debug("🔔 푸시 알림 수신 (포그라운드) 🔔")
        UserDefaultsManager.fcmReciveCount += 1
        setBadgeCount()
        publishNewMessageCount.send(UserDefaultsManager.fcmReciveCount)
        return [.list, .banner, .badge, .sound]
    }

    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if UserDefaultsManager.fcmReciveCount > 0 {
            UserDefaultsManager.fcmReciveCount -= 1
            setBadgeCount()
        }
        Logger.debug("✅ 푸시 클릭 감지 ✅")
    }
    
    @MainActor
    func setBadgeCount() {
        if #available(iOS 16.0, *) {
            center.setBadgeCount(UserDefaultsManager.fcmReciveCount)
        }
        else {
            UIApplication.shared.applicationIconBadgeNumber = UserDefaultsManager.fcmReciveCount
        }
    }
    
    @MainActor
    func resetBadgeCount() {
        UserDefaultsManager.fcmReciveCount = 0
        if #available(iOS 16.0, *) {
            center.setBadgeCount(0)
        }
        else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

extension PushNotiManager: DependencyKey {
    static let liveValue: PushNotiManager = PushNotiManager()
}

extension DependencyValues {
    var pushNotiManager: PushNotiManager {
        get {self[PushNotiManager.self]}
        set {self[PushNotiManager.self] = newValue}
    }
}

