//
//  NoticeRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/2/25.
//

import Foundation
import Alamofire
import Domain

/// 알림 라우터
public enum NoticeRouter {
    /// 내 알림 목록 가져오기
    case getMyNotices(page: Int, size: Int, type: String?)
    
}

extension NoticeRouter: Router {
    public var method: HTTPMethod {
        switch self {
        case .getMyNotices:
            return .get
        }
    }
    
    public var version: String {
        return "/v1"
    }
    
    public var path: String {
        switch self {
        case .getMyNotices:
            return "/notices"
        }
    }
    
    public var optionalHeaders: HTTPHeaders? {
        return ["Content-Type" : "application/json"]
    }
    
    public var parameters: Parameters? {
        switch self {
        case .getMyNotices(let page, let size, let type):
            var defaultValue: [String: any Any & Sendable] = [
                "page" : page,
                "size" : size
            ]
            
            if let type = type {
                defaultValue["type"] = type
            }
            
            return defaultValue
        }
    }
    
    public var body: Data? {
        switch self {
        case .getMyNotices:
            return nil
        }
    }
    
    public var encodingType: EncodingType {
        switch self {
        case .getMyNotices:
            return .url
        }
    }
    
    public var multipartFormData: MultipartFormData? {
        switch self {
        case .getMyNotices:
            return nil
        }
    }
    
}
