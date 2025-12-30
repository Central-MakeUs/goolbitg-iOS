//
//  Router+Extension.swift
//  Utils
//
//  Created by Jae hyung Kim on 5/22/25.
//

import Foundation
import Alamofire
import Domain
import Utils

extension Router {
    
    public var baseURL: String {
        #if DEV
        return SecretKeys.devBaseURL + version
        #else
        return SecretKeys.baseURL + version
        #endif
    }
    
    public var headers: HTTPHeaders {
        var combine = HTTPHeaders()
        if let optionalHeaders {
            optionalHeaders.forEach { header in
                combine.add(header)
            }
        }
        return combine
    }
    
    public func asURLRequest() throws(RouterError) -> URLRequest {
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
                    if urlRequest.allHTTPHeaderFields?["Content-Type"] == nil {
                        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
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

    public func requestToBody(_ request: Encodable) -> Data? {
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
