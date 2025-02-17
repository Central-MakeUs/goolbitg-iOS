//
//  Router.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Alamofire

protocol Router {
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

enum EncodingType {
    case url
    case json
    case multipartForm
}

extension Router {
    
    var baseURL: String {
        return SecretKeys.baseURL + version
    }
    
    var headers: HTTPHeaders {
        var combine = HTTPHeaders()
        if let optionalHeaders {
            optionalHeaders.forEach { header in
                combine.add(header)
            }
        }
        return combine
    }
    
    func asURLRequest() throws(RouterError) -> URLRequest {
        let url = try baseURLToURL()
        
        var urlRequest = try urlToURLRequest(url: url)
        
        switch encodingType {
        case .url, .multipartForm:
            do {
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
                return urlRequest
            } catch {
                throw .encodingFail
            }
        case .json:
            do {
                if let body {
                    urlRequest.httpBody = body
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } else {
                    let request = try JSONEncoding.default.encode(urlRequest, withJSONObject: parameters)
                    Logger.debug(parameters ?? "")
                    urlRequest = request
                }
                return urlRequest
            } catch {
                throw .decodingFail
            }
        }
    }
    
    private func baseURLToURL() throws(RouterError) -> URL {
        do {
            let url = try baseURL.asURL()
            return url
        } catch let error as AFError {
            if case .invalidURL = error {
                throw .urlFail(url: baseURL)
            } else {
                throw .unknown(errorCode: "baseURLToURL")
            }
        }catch {
            throw .unknown(errorCode: "baseURLToURL")
        }
    }
    
    private func urlToURLRequest(url: URL) throws(RouterError) -> URLRequest {
        do {
            let urlRequest = try URLRequest(url: url.appending(path: path), method: method, headers: headers)
            
            return urlRequest
        } catch let error as AFError {
            if case .invalidURL = error {
                throw .urlFail(url: baseURL)
            } else {
                throw .unknown(errorCode: "urlToURLRequest")
            }
        }catch {
            throw .unknown(errorCode: "urlToURLRequest")
        }
    }

    func requestToBody(_ request: Encodable) -> Data? {
        do {
            return try CodableManager.shared.jsonEncoding(from: request)
        } catch {
            #if DEBUG
            print("requestToBody Error")
            #endif
            return nil
        }
    }
}

