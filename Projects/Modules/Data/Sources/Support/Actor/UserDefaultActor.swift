//
//  UserDefaultActor.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation

public final actor UserDefaultsManager {
    
    public enum Key: String {
        case deviceToken
        
        case accessToken
        case refreshToken
        case userNickname
        case userHabitType
        
        /// 디바이스 기준 처음 인지
        case firstDevice
        case appleLoginAccess
        case appleLoginRefresh
        
        /// 애플 로그인 유저인지 구분합니다.
        case ifAppleLoginUser
        
        /// FCM  registrationToken
        case fcmRegistrationToken
        case fcmReciveCount
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.deviceToken.value, placeValue: "")
    public static var deviceToken: String
    
    @UserDefaultsWrapper(key: Key.accessToken.value, placeValue: "")
    public static var accessToken: String
    
    @UserDefaultsWrapper(key: Key.refreshToken.value, placeValue: "")
    public static var refreshToken: String
    
    @UserDefaultsWrapper(key: Key.firstDevice.value, placeValue: true)
    public static var firstDevice: Bool
    
    @UserDefaultsWrapper(key: Key.userNickname.value, placeValue: "")
    public static var userNickname: String
    
    @UserDefaultsWrapper(key: Key.userHabitType.value, placeValue: nil)
    public static var userHabitType: Int?
    
    @UserDefaultsWrapper(key: Key.appleLoginAccess.value, placeValue: nil)
    public static var appleAccessToken: String?
    
    @UserDefaultsWrapper(key: Key.appleLoginRefresh.value, placeValue: nil)
    public static var appleRefreshToken: String?
    
    @UserDefaultsWrapper(key: Key.ifAppleLoginUser.value, placeValue: false)
    public static var ifAppleLoginUser: Bool
    
    @UserDefaultsWrapper(key: Key.fcmRegistrationToken.value, placeValue: nil)
    public static var fcmRegistrationToken: String?
    
    @UserDefaultsWrapper(key: Key.fcmReciveCount.value, placeValue: 0)
    public static var fcmReciveCount: Int
}

extension UserDefaultsManager {
    
    public static func resetUser() {
        UserDefaultsManager.userNickname = ""
        UserDefaultsManager.accessToken = ""
        UserDefaultsManager.refreshToken = ""
        UserDefaultsManager.ifAppleLoginUser = false
    }
}

@propertyWrapper
public struct UserDefaultsWrapper<T: Codable> {
    public let key: String
    public let placeValue: T
    
    private let userDefaults = UserDefaults.standard
    
    public var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? CodableManager.shared.jsonDecoding(model: T.self, from: data) else {
                return placeValue
            }
            return value
        } set {
            guard let data = try? CodableManager.shared.jsonEncoding(from: newValue)
            else {
                return
            }
            userDefaults.setValue(data, forKey: key)
        }
    }
}
