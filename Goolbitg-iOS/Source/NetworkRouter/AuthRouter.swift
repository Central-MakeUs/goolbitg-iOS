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
        case .register(let authRegisterRequestModel):
            return [
                "type" : authRegisterRequestModel.type,
                "idToken": authRegisterRequestModel.idToken
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .register(let authRegisterRequestModel):
            let data = try? CodableManager.shared.jsonEncodingStrategy(authRegisterRequestModel)
            return data
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .register:
            return .json
        }
    }
}
