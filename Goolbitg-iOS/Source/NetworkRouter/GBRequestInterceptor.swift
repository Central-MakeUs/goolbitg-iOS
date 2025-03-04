//
//  GBRequestInterceptor.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/21/25.
//

import Foundation
import Alamofire

final class GBRequestInterceptor: RequestInterceptor {
    
    private let retryCount = AnyValueActor(3)
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: UserDefaultsManager.accessToken))
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping @Sendable (RetryResult) -> Void) {
        Task {
            guard let statusCode = request.response?.statusCode,
                  let apiResult = APIErrorEntity(rawValue: statusCode) else {
                if let statusCode = request.response?.statusCode,
                   statusCode == 401 {
                    if await requestRefresh() {
                        completion(.retry)
                    } else {
                        completion(.doNotRetry)
                    }
                } else {
                    completion(.doNotRetry)
                }
                return
            }
            if (apiResult == .tokenExpiration || statusCode == 401) && (UserDefaultsManager.refreshToken != "") {
                if await requestRefresh() {
                    completion(.retry)
                } else {
                    completion(.doNotRetry)
                }
            }
            else {
                completion(.doNotRetry)
            }
        }
    }
    
    private func requestRefresh() async -> Bool {
        
        let retryCurrent = await retryCount.withValue {
           return $0 > 0
        }
        
        if !retryCurrent { return false }
        
        let result = try? await NetworkManager.shared.requestNetwork(
            dto: AccessTokenDTO.self,
            router: AuthRouter.refresh(
                refreshToken: UserDefaultsManager.refreshToken
            )
        )
        
        guard let result else { return false }
        
        UserDefaultsManager.accessToken = result.accessToken
        UserDefaultsManager.refreshToken = result.refreshToken
        await retryCount.withValue { num in
            num -= 1
        }
        return true
    }
    
}
