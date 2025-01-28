//
//  ChallengeRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Alamofire

enum ChallengeRouter {
    case challengeList(page: Int = 0, size: Int = 10, spendingTypeID: Int? = nil)
}

extension ChallengeRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .challengeList:
            return .get
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .challengeList:
            return "/challenges"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .challengeList:
            return [ "application/json" : "Content-Type" ]
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .challengeList(let page, let size, let spendingTypeID):
            var defaultValue = [
                "page" : page,
                "size" : size
            ]
            if let spendingTypeID {
                defaultValue["spendingTypeId"] = spendingTypeID
            }
            return defaultValue
            
        }
    }
    
    var body: Data? {
        switch self {
        case .challengeList:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .challengeList:
            return .url
        }
    }
    
}
