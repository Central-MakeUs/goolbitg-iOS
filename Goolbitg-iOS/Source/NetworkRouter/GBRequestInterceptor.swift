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
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        Task {
            let retry = await retryCount.withValue { $0 > 0 }
            if !retry { completion(.doNotRetry); return }
            
            guard let statusCode = request.response?.statusCode,
                  let apiResult = APIErrorEntity(rawValue: statusCode) else {
                completion(.doNotRetry)
                return
            }
            if case .tokenExpiration = apiResult, UserDefaultsManager.refreshToken != "" {
                let result = try? await NetworkManager.shared.requestNetwork(
                    dto: AccessTokenDTO.self,
                    router: AuthRouter.refresh(
                        refreshToken: UserDefaultsManager.refreshToken
                    )
                )
                guard let result else { completion(.doNotRetry); return }
                
                UserDefaultsManager.accessToken = result.accessToken
                UserDefaultsManager.refreshToken = result.refreshToken
                
                await retryCount.withValue { $0 -= 1 }
                
                completion(.retry)
            }
            else {
                completion(.doNotRetry)
            }
        }
    }
    
}
