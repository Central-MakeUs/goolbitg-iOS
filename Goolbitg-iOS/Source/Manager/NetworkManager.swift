//
//  NetworkManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Alamofire
import ComposableArchitecture
import Foundation
@preconcurrency import Combine

final class NetworkManager: Sendable, ThreadCheckable {
    
    private let networkError = PassthroughSubject<String, Never>()
    
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    private let retryActor = AnyValueActor(7)
   
    func requestNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(RouterError) -> T {
        #if DEBUG
        checkedMainThread() // 현재 쓰레드 확인
        #endif
            do {
                let request = try router.asURLRequest()
                
                // MARK: 요청담당
                let response = await getRequest(dto: dto, router: router, request: request)
                
                let result = try await getResponse(dto: dto, router: router, response: response)
                
                return result
            } catch {
                #if DEBUG
                print("emergency")
                #endif
                throw .unknown
            }
    }
    
    func requestNotDtoNetwork<R: Router>(router: R) async throws(RouterError) -> Bool {
#if DEBUG
        checkedMainThread() // 현재 쓰레드 확인
#endif
        do {
            let request = try router.asURLRequest()
            
            // MARK: 요청담당
            let response = await AF.request(request)
                .cacheResponse(using: .cache)
                .validate(statusCode: 200..<300)
                .serializingData()
                .response
            
            switch response.result {
            case .success:
                return true
            case .failure:
                print("\(response.response?.statusCode)")
                if let data = response.data {
                    let data = try? CodableManager.shared.jsonDecoding(model: ErrorDTO.self, from: data)
                    Logger.warning(data)
                }
                guard let status = response.response?.statusCode,
                      let error = APIErrorEntity.getSelf(code: status) else {
                    throw RouterError.unknown
                }
                Logger.warning(error)
                throw RouterError.serverMessage(error)
            }
        } catch {
#if DEBUG
            print("emergency")
#endif
            throw .unknown
        }
    }
    
    func getNetworkError() -> AsyncStream<String> {
        
        return AsyncStream<String> { contin in
            Task {
                let subscribe = networkError
                    .sink { text in
                        contin.yield(text)
                    }
              
                await cancelStoreActor.withValue { value in
                    value.insert(subscribe)
                }
            }
            
            contin.onTermination = { @Sendable [weak self] _ in
                guard let weakSelf = self else { return }
                Task {
                    await weakSelf.cancelStoreActor.resetValue()
                    contin.finish()
                }
            }
        }
    }
}

extension NetworkManager {
    // MARK: 요청담당
    private func getRequest<T: DTO, R: Router>(dto: T.Type, router: R, request: URLRequest) async -> DataResponse<T, AFError> {
        return await AF.request(request)
            .cacheResponse(using: .cache)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .response
    }
    
    // MARK: RE스폰스 담당
    private func getResponse<T:DTO>(
        dto: T.Type,
        router: Router,
        response: DataResponse<T, AFError>
    ) async throws(RouterError) -> T
    {
        switch response.result {
        case let .success(data):
            await retryActor.resetValue()
            
            return data
        case let .failure(guideError):
            #if DEBUG
            print(guideError)
            #endif
            do {
                let retryResult = try await retryNetwork(dto: dto, router: router)
                
                // 성공시 초기화
                await retryActor.resetValue()
                
                return retryResult
            } catch {
                throw checkResponseData(response.data, guideError)
            }
        }
    }

    private func retryNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(RouterError) -> T {
        let ifRetry = await retryActor.withValue { value in
            return value > 0
        }
        
        do {
            if ifRetry {
                let response = try await getRequest(dto: dto, router: router, request: router.asURLRequest())
                
                switch response.result {
                case let .success(data):
                    return data
                case .failure(_):
                    await downRetryCount()
                    
                    return try await retryNetwork(dto: dto, router: router)
                }
            } else {
                throw RouterError.retryFail
            }
        } catch {
            throw RouterError.unknown
        }
    }
    
    private func downRetryCount() async {
        await retryActor.withValue { value in
            value -= 1
        }
    }
    
    private func checkResponseData(
        _ responseData: Data?,
        _ error: AFError
    ) -> RouterError {
        if let data = responseData {
            do {
                let errorResponse = try CodableManager.shared.jsonDecoding(model: APIErrorDTO.self, from: data)
                
                guard let errorModel = APIErrorEntity.getSelf(code: errorResponse.code) else {
                    return RouterError.unknown
                }
                return RouterError.serverMessage(errorModel)
                
            } catch {
                return RouterError.unknown
            }
        } else {
            return catchURLError(error)
        }
    }
    
    private func catchURLError(_ error: AFError) -> RouterError {
        if let afError = error.asAFError, let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .timedOut:
                networkError.send("요청 시간이 초과되었습니다.")
                return .timeOut
                
            default:
                return .unknown
            }
        } else {
            return .unknown
        }
    }
    
}

extension NetworkManager: DependencyKey {
    static let liveValue: NetworkManager = NetworkManager()
}

extension DependencyValues {
    var networkManager: NetworkManager {
        get { self[NetworkManager.self] }
        set { self[NetworkManager.self] = newValue }
    }
}



struct ErrorDTO: DTO {
    let code: Int
    let message: String
}
