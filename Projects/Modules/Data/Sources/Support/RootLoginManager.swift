//
//  RootLoginManager.swift
//  Data
//
//  Created by Jae hyung Kim on 6/20/25.
//

import Foundation

public struct RootLoginManager: Sendable {
    
    public static func login() async {
        let result = try? await NetworkManager
            .shared
            .requestNetwork(
                dto: LoginAccessDTO.self ,
                router: AuthRouter.rootLogin
            )
        
        guard let result else {
            print("RootLogin Fail")
            return
        }
#if DEV
        print("ROOT :\(result.accessToken) ")
#endif
        UserDefaultsManager.accessToken = result.accessToken
        UserDefaultsManager.refreshToken = result.refreshToken
    }
    
}
