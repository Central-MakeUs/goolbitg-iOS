//
//  AuthRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Alamofire

enum AuthRouter {
    case register(AuthRegisterRequestModel)
}

extension AuthRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .register:
            return .post
        }
    }
    
    var version: String {
        switch self {
        case .register:
            return "/v1"
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/auth/register"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .register:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .register:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .register(let authRegisterRequestModel):
            return try? CodableManager.shared.jsonEncoding(from: authRegisterRequestModel)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .register:
            return .url
        }
    }
}
