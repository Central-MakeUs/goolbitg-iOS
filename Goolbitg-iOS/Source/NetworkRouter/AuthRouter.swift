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
}

extension AuthRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh:
            return .post
        }
    }
    
    var version: String {
        switch self {
        case .register, .login, .refresh:
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
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .register, .login, .refresh:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .register(let authRegisterRequestModel):
            return [
                "type" : authRegisterRequestModel.type,
                "idToken": authRegisterRequestModel.idToken
            ]
        case .login, .refresh:
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
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .register, .login, .refresh:
            return .json
        }
    }
}
