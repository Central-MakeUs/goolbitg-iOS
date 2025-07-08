//
//  AuthRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Domain
import Alamofire

public enum AuthRouter {
    /// 회원등록
    case register(AuthRegisterRequestModel)
    /// 로그인
    case login(AuthLoginRequestModel)
    /// 엑세스 토큰 재발급
    case refresh(refreshToken: String)
    /// 로그아웃
    case logOut
    /// 회원 탈퇴
    case signOut(RevokeRequestDTO)
    
    // MARK: ROOT LOGIN
    case rootLogin
}

extension AuthRouter: Router {
    
    public var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh, .logOut, .signOut:
            return .post
        case .rootLogin:
            return .get
        }
    }
    
    public var version: String {
        switch self {
        case .register, .login, .refresh, .logOut, .signOut, .rootLogin:
            return "/v1"
        }
    }
    
    public var path: String {
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
        case .rootLogin:
            return "/token"
        }
    }
    
    public var optionalHeaders: HTTPHeaders? {
        if case .rootLogin = self {
            return ["accept" : "application/json"]
        }
        return [ "application/json" : "Content-Type" ]
    }
    
    public var parameters: Parameters? {
        switch self {
        case .register, .login, .refresh, .logOut, .signOut, .rootLogin:
            return nil
        }
    }
    
    public var body: Data? {
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
            
        case let .signOut(revokeModel):
            let data = try? CodableManager.shared.jsonEncodingStrategy(revokeModel)
            return data
        case .logOut, .rootLogin:
            return nil
            
        }
    }
    
    public var encodingType: EncodingType {
        switch self {
        case .logOut:
            return .url
            
        case .register, .login, .refresh, .signOut, .rootLogin:
            return .json
        }
    }
    
    public var multipartFormData: MultipartFormData? {
        return nil
    }
}
