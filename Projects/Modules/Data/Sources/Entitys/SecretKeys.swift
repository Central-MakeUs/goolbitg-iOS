//
//  SecretKeys.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import Foundation

public enum SecretKeys {
    public static let kakaoNative = "9f47d4c50199643ade77d5647a39d3ea"
    
//    public static let kakaoNative: String = {
//        #if DEV
//        return "88a840178a913de8783f723faaf41658"
//        #else
//        return "9f47d4c50199643ade77d5647a39d3ea"
//        #endif
//    }()
    
    /// Main URL
    public static let baseURL = "https://api.goolbitg.site"
    /// DEV URL
    public static let devBaseURL = "https://dev.goolbitg.site"
    
    public static let appleKeyID = "K3LA6DDWSY"
    public static let bundleID = "com.Goolbitg-iOS"
    public static let teamID = "H25F4B7J4U"
    public static let p8Path = "AuthKey_K3LA6DDWSY.p8"
}
