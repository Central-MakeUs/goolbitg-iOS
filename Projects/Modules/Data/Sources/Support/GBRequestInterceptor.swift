//
//  GBRequestInterceptor.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation
import Alamofire

final class GBRequestInterceptor: RequestInterceptor {

    private let maxRetryCountPerRequest = 2

    private let isRefreshing = LockIsRefreshing()

    func adapt(_ urlRequest: URLRequest, for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        req.headers.add(.authorization(bearerToken: UserDefaultsManager.accessToken))
        completion(.success(req))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        // refresh 엔드포인트는 재시도 금지
        if let path = request.request?.url?.path,
           path.contains("/auth/refresh") {
            completion(.doNotRetry); return
        }

        // 요청 단위 상한
        if request.retryCount >= maxRetryCountPerRequest {
            completion(.doNotRetry); return
        }

        // HTTP 상태 확인
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry); return
        }

        // 401 --> 만료 처리
        if statusCode == 401 || APIErrorEntity(rawValue: statusCode) == .tokenExpiration {
            // 리프레시 토큰 없으면 재시도 X
            guard !UserDefaultsManager.refreshToken.isEmpty else {
                completion(.doNotRetry); return
            }

            // DEBUG 특수 케이스
            if UserDefaultsManager.refreshToken == "root_user_refresh_token" {
                Task {
                    await RootLoginManager.login()
                    completion(.retry) // 새 토큰으로 재시도
                }
                return
            }

            Task {
                let refreshed = await refreshIfNeeded()

                if refreshed {
                    completion(.retry); return
                } else {
                    completion(.doNotRetry); return
                }
            }
            return
        }

        // 그 외 상태코드: 재시도 안 함
        completion(.doNotRetry); return
    }

    // MARK: - Refresh
    private func refreshIfNeeded() async -> Bool {
        if await isRefreshing.startIfNotRunning() == false {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            return !UserDefaultsManager.accessToken.isEmpty
        }
        
        defer { Task { await isRefreshing.finish() } }

        // 실제 리프레시
        if UserDefaultsManager.refreshToken == "root_user_refresh_token" {
            return true
        }

        let result = try? await NetworkManager.shared.requestNetwork(
            dto: AccessTokenDTO.self,
            router: AuthRouter.refresh(refreshToken: UserDefaultsManager.refreshToken)
        )

        guard let dto = result else { return false }
        UserDefaultsManager.accessToken = dto.accessToken
        UserDefaultsManager.refreshToken = dto.refreshToken
        return true
    }
}

/// 단순 동기화 유틸
actor LockIsRefreshing {
    
    private var running = false
    
    func startIfNotRunning() -> Bool {
        if running { return false }
        running = true
        return true
    }
    
    func finish() { running = false }
}
