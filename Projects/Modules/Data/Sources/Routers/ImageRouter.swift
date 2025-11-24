//
//  ImageRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import Alamofire
import Domain

public enum ImageRouter {
    case imageUpload(imageData: Data, fileName: String)
}

extension ImageRouter: Router {
    
    public var method: HTTPMethod {
        switch self {
        case .imageUpload:
            return .post
        }
    }
    
    public var version: String {
        return "/v1"
    }
    
    public var path: String {
        return "/images"
    }
    
    public var optionalHeaders: HTTPHeaders? {
        return ["Content-Type" : "application/json"]
    }
    
    public var parameters: Parameters? {
        switch self {
        case .imageUpload:
            return nil
        }
    }
    /// 멀티파트 작업 AF 에게 위임
    public var body: Data? {
        switch self {
        case .imageUpload:
            return nil
        }
    }
    
    public var encodingType: EncodingType {
        return .multipartForm
    }
    
    public var multipartFormData: MultipartFormData? {
        switch self {
        case .imageUpload(let imageData, let fileName):
            let model = MultipartFormData()
            model.append(
                imageData,
                withName: "image",
                fileName: fileName,
                mimeType: "image/jpeg"
            )
            return model
        }
    }
    
}
