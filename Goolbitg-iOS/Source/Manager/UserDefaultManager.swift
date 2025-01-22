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
        
        /// 디바이스 기준 처음 인지
        case firstDevice
        
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
}
