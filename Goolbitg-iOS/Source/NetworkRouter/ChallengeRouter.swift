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
    case challengeEnroll(challengeID: String)
    case challengeRecords(page: Int = 0, size: Int = 10, date: String, state: String? = nil)
}

extension ChallengeRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .challengeList, .challengeRecords:
            return .get
        case .challengeEnroll:
            return .post
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .challengeList:
            return "/challenges"
        case let .challengeEnroll(challengeID):
            return "/challenges/\(challengeID)/enroll"
        case .challengeRecords:
            return "/challengeRecords"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .challengeList, .challengeEnroll, .challengeRecords:
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
            
        case let .challengeRecords(page, size, date, state):
            var defaultValue: [String : Any] = [
                "page" : page,
                "size" : size,
                "date" : date
            ]
            if let state {
                defaultValue["state"] = state
            }
            return defaultValue
            
        case .challengeEnroll:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .challengeList ,.challengeEnroll, .challengeRecords:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .challengeList , .challengeEnroll, .challengeRecords:
            return .url
        }
    }
    
}
