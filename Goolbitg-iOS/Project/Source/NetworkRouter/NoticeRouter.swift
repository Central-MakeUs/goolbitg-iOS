//
//  NoticeRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation
import Alamofire

/// 알림 라우터
enum NoticeRouter {
    /// 내 알림 목록 가져오기
    case getMyNotices(page: Int, size: Int, type: PushListFilterCase)
    
}

extension NoticeRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .getMyNotices:
            return .get
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .getMyNotices:
            return "/notices"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        return [ "application/json" : "Content-Type" ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .getMyNotices(let page, let size, let type):
            var defaultValue: [String: any Any & Sendable] = [
                "page" : page,
                "size" : size
            ]
            
            if let type = type.requestMode {
                defaultValue["type"] = type
            }
            
            return defaultValue
        }
    }
    
    var body: Data? {
        switch self {
        case .getMyNotices:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .getMyNotices:
            return .url
        }
    }
    
    var multipartFormData: MultipartFormData? {
        switch self {
        case .getMyNotices:
            return nil
        }
    }
    
}
