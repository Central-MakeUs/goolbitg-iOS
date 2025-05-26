//
//  Router.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation
import Alamofire

public enum EncodingType {
    case url
    case json
    case multipartForm
}

public protocol Router {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var version: String { get }
    var path: String { get }
    var optionalHeaders: HTTPHeaders? { get } // secretHeader 말고도 추가적인 헤더가 필요시
    var headers: HTTPHeaders { get } // 다 합쳐진 헤더
    var parameters: Parameters? { get }
    var body: Data? { get }
    var encodingType: EncodingType { get }
    
    var multipartFormData: MultipartFormData? { get }
}
