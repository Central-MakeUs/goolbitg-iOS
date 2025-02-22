//
//  UserDefaultManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import Foundation

final actor UserDefaultsManager {
    
    enum Key: String {
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
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.deviceToken.value, placeValue: "")
    static var deviceToken: String
    
    @UserDefaultsWrapper(key: Key.accessToken.value, placeValue: "")
    static var accessToken: String
    
    @UserDefaultsWrapper(key: Key.refreshToken.value, placeValue: "")
    static var refreshToken: String
    
    @UserDefaultsWrapper(key: Key.firstDevice.value, placeValue: true)
    static var firstDevice: Bool
    
    @UserDefaultsWrapper(key: Key.userNickname.value, placeValue: "")
    static var userNickname: String
    
    @UserDefaultsWrapper(key: Key.userHabitType.value, placeValue: nil)
    static var userHabitType: Int?
    
    @UserDefaultsWrapper(key: Key.appleLoginAccess.value, placeValue: nil)
    static var appleAccessToken: String?
    
    @UserDefaultsWrapper(key: Key.appleLoginRefresh.value, placeValue: nil)
    static var appleRefreshToken: String?
    
    @UserDefaultsWrapper(key: Key.ifAppleLoginUser.value, placeValue: false)
    static var ifAppleLoginUser: Bool
    
    @UserDefaultsWrapper(key: Key.fcmRegistrationToken.value, placeValue: nil)
    static var fcmRegistrationToken: String?
    
}

extension UserDefaultsManager {
    
    static func resetUser() {
        UserDefaultsManager.userNickname = ""
        UserDefaultsManager.accessToken = ""
        UserDefaultsManager.refreshToken = ""
        UserDefaultsManager.ifAppleLoginUser = false
    }
}
