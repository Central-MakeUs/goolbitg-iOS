//
//  AuthRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Alamofire

enum AuthRouter {
    /// 회원등록
    case register(AuthRegisterRequestModel)
    /// 로그인
    case login(AuthRegisterRequestModel)
    /// 엑세스 토큰 재발급
    case refresh(refreshToken: String)
    /// 로그아웃
    case logOut
    /// 회원 탈퇴
    case signOut
}

extension AuthRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh, .logOut, .signOut:
            return .post
        }
    }
    
    var version: String {
        switch self {
        case .register, .login, .refresh, .logOut, .signOut:
            return "/v1"
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .refresh:
            return "/auth/refresh"
        case .logOut:
            return "/auth/logout"
        case .signOut:
            return "/auth/unregister"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .register, .login, .refresh:
            return nil
        case .logOut, .signOut:
            return [ "application/json" : "Content-Type" ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .register(let authRegisterRequestModel):
            return [
                "type" : authRegisterRequestModel.type,
                "idToken": authRegisterRequestModel.idToken
            ]
        case .login, .refresh, .logOut, .signOut:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .register(let authRegisterRequestModel):
            let data = try? CodableManager.shared.jsonEncodingStrategy(authRegisterRequestModel)
            return data
        case .login(let loginModel):
            let data = try? CodableManager.shared.jsonEncodingStrategy(loginModel)
            return data
        case let .refresh(refreshToken):
            let data = try? CodableManager.shared.jsonEncodingStrategy(RefreshTokenReqeustModel(refreshToken: refreshToken))
            return data
        case .logOut, .signOut:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .logOut, .signOut:
            return .url
            
        case .register, .login, .refresh:
            return .json
        }
    }
}
