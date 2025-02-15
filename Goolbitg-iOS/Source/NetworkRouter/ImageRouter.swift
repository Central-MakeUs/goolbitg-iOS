//
//  ImageRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import Alamofire

enum ImageRouter {
    case imageUpload(imageData: Data, fileName: String)
}

extension ImageRouter: Router {
    
    var method: HTTPMethod {
        switch self {
        case .imageUpload:
            return .post
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        return "/images"
    }
    
    var optionalHeaders: HTTPHeaders? {
        return [ "application/json" : "Content-Type" ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .imageUpload:
            return nil
        }
    }
    /// 멀티파트 작업 AF 에게 위임
    var body: Data? {
        switch self {
        case .imageUpload:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        return .multipartForm
    }
    
    var multipartFormData: MultipartFormData? {
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
