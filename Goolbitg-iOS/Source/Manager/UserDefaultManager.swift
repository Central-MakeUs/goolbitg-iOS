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
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.deviceToken.value, placeValue: "")
    static var deviceToken: String
}
