//
//  NetworkManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import Alamofire
import ComposableArchitecture
import Domain
import Utils

@preconcurrency import Combine

public final class NetworkManager: Sendable, ThreadCheckable {
    
    private let networkError = PassthroughSubject<RouterError, Never>()
    
    private let cancelStoreActor = AnyValueActor(Set<AnyCancellable>())
    private let retryActor = AnyValueActor(3)
    
    public func requestNetwork<T: DTO, R: Router>(dto: T.Type, router: R) async throws(RouterError) -> T {
#if DEBUG
        checkedMainThread() // 현재 쓰레드 확인
#endif
        let request = try router.asURLRequest()
        Logger.debug(request)
        Logger.debug(request.url)
        // MARK: 요청담당
        let response = await getRequest(dto: dto, router: router, request: request)
        
//        CodableManager.shared.toJSONSerialization(data: request.httpBody?)
        let result = try await getResponse(dto: dto, router: router, response: response)
        
        return result
    }
    
    public func requestNetworkWithRefresh<T:DTO, R: Router>(dto: T.Type, router: R) async throws(RouterError) -> T {
#if DEBUG
        checkedMainThread() // 현재 쓰레드 확인
#endif
        let request = try router.asURLRequest()
        Logger.info(request)
        // MARK: 요청담당
        let response = await getRequest(dto: dto, router: router, request: request, ifRefreshMode: true)

        let result = try await getResponse(dto: dto, router: router, response: response, ifRefreshMode: true)
        
        return result
    }
    
    @discardableResult
    public func requestNotDtoNetwork<R: Router>(router: R, ifRefreshNeed: Bool = false) async throws(RouterError) -> Bool {
#if DEBUG
        checkedMainThread() // 현재 쓰레드 확인
#endif
        let request = try router.asURLRequest()
        let accessCode: Set<Int> = Set(Array(200..<300))
       
        
        // MARK: 요청담당
        let response: DataResponse<String, AFError>
        if ifRefreshNeed {
            response = await AF.request(request, interceptor: GBRequestInterceptor())
                .validate(statusCode: 200..<300)
                .serializingString(emptyResponseCodes: accessCode)
                .response
        } else {
            response = await AF.request(request)
                .validate(statusCode: 200..<300)
                .serializingString(emptyResponseCodes: accessCode)
                .response
        }
        Logger.info(request)
        
        switch response.result {
        case .success:
            return true
        case .failure:
            if accessCode.contains(response.response?.statusCode ?? 0) {
                return true
            }
            if let data = response.data {
                let data = try? CodableManager.shared.jsonDecoding(model: ErrorDTO.self, from: data)
                Logger.warning(data ?? "")
                guard let code = data?.code,
                      let errorEntity = APIErrorEntity.getSelf(code: code) else {
                    Logger.error(response.response?.statusCode ?? -999999)
                    throw RouterError.unknown(errorCode: String(response.response?.statusCode ?? -999999))
                }
                networkError.send(RouterError.serverMessage(errorEntity))
                throw RouterError.serverMessage(errorEntity)
            }
            guard let status = response.response?.statusCode,
                  let error = APIErrorEntity.getSelf(code: status) else {
                Logger.error(response.response?.statusCode ?? -999999)
                networkError.send(RouterError.unknown(errorCode: String(response.response?.statusCode ?? -999999)))
                throw RouterError.unknown(errorCode: String(response.response?.statusCode ?? -999999))
            }
            Logger.error(error)
            throw RouterError.serverMessage(error)
        }
    }
    
    public func getNetworkError() -> AsyncStream<RouterError> {
        
        return AsyncStream<RouterError> { contin in
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
    private func getRequest<T: DTO, R: Router>(dto: T.Type, router: R, request: URLRequest, ifRefreshMode: Bool = false) async -> DataResponse<T, AFError> {
        
        if ifRefreshMode {
            let requestResponse = await AF.request(request, interceptor: GBRequestInterceptor())
                .validate(statusCode: 200..<300)
                .cURLDescription {
                    Logger.info($0)
                }
                .serializingDecodable(T.self)
                .response
            Logger.debug(requestResponse.debugDescription)
            return requestResponse
        }
        else {
            let requestResponse = await AF.request(request)
                .validate(statusCode: 200..<300)
                .serializingDecodable(T.self)
                .response
            Logger.debug(requestResponse.debugDescription)
            return requestResponse
        }
    }
    
    // MARK: RE스폰스 담당
    private func getResponse<T:DTO>(
        dto: T.Type,
        router: Router,
        response: DataResponse<T, AFError>,
        ifRefreshMode: Bool = false
    ) async throws(RouterError) -> T
    {
        Logger.info(response.response ?? "")
        
        switch response.result {
        case let .success(data):
            Logger.info(data)
            await retryActor.resetValue()
            
            return data
        case let .failure(GBError):
            Logger.error(response.data?.base64EncodedString() ?? "")
            Logger.error(GBError)
            if GBError.isExplicitlyCancelledError {
                throw .cancel
            }
            
            if response.error?.responseCode == 500 {
                await DiscordMessageManager.shared.sendMessage500(message: "500 -\(GBError)")
                CrashlyticsManager.sendMessage(message: "SERVER_ERROR")
                CrashlyticsManager.record(error: GBError)
            }
            
            do {
                let retryResult = try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefreshMode)
                
                // 성공시 초기화
                await retryActor.resetValue()
                
                return retryResult
            } catch {
                
                let check = checkResponseData(response.data, GBError)
                networkError.send(check)
                throw check
            }
        }
    }
    
    private func retryNetwork<T: DTO, R: Router>(dto: T.Type, router: R, ifRefresh: Bool) async throws(RouterError) -> T {
        let ifRetry = await retryActor.withValue { value in
            Logger.info("retry Count : \(value)")
            return value > 0
        }
        
        do {
            if ifRetry {
                let response = try await getRequest(dto: dto, router: router, request: router.asURLRequest())
                
                switch response.result {
                case let .success(data):
                    return data
                case .failure(let error):
                    await downRetryCount()
                    

                    return try await retryNetwork(dto: dto, router: router, ifRefresh: ifRefresh)
                }
            } else {
                throw RouterError.retryFail
            }
        } catch {
            throw RouterError.unknown(errorCode: String(-999999))
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
                    return RouterError.unknown(errorCode: "ERROR MODEL DECODING FAIL")
                }
                
                let errorMessage = RouterError.serverMessage(errorModel)
                Logger.warning(errorMessage)
                return errorMessage
                
            } catch {
                return RouterError.unknown(errorCode: "ERROR MODEL DECODING FAIL")
            }
        } else {
            return catchURLError(error)
        }
    }
    
    private func catchURLError(_ error: AFError) -> RouterError {
        if let afError = error.asAFError, let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .timedOut:
                networkError.send(.timeOut)
                return .timeOut
                
            default:
                return .unknown(errorCode: "TIME OUT")
            }
        } else {
            return .unknown(errorCode: "TIME OUT")
        }
    }
    
}

// MARK: 이미지 업로드
extension NetworkManager {
    
    public func uplaodMultipartRequest<D: DTO>(
        type: D.Type,
        router: Router
    ) async throws(RouterError) -> D {
        
        guard let url = try router.asURLRequest().url else {
            throw .urlFail(url: "uplaodMultipartRequest \(router)")
        }
        guard let multipartFormData = router.multipartFormData else {
            throw .urlFail(url: "NOT FOUND multipartFormData \(router)")
        }
        
        let request = await AF.upload(
            multipartFormData: multipartFormData,
            to: url,
            interceptor: GBRequestInterceptor()
        )
            .validate(statusCode: 200..<300)
            .cURLDescription {
                Logger.info($0)
            }
            .serializingDecodable(D.self)
            .response
        
        let response = try await getResponse(
            dto: type,
            router: router,
            response: request,
            ifRefreshMode: true
        )
        
        return response
    }
    
}

extension NetworkManager {
    
    public func ifNeedEscapingRequest<T: DTO, R: Router>(dto: T.Type, router: R, completion: @escaping @Sendable (Result<T, RouterError>) -> Void) {
        do {
            let urlRequest = try router.asURLRequest()
            AF.request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: dto.self) { response in
                    switch response.result {
                        
                    case let .success(success):
                        completion(.success(success))
                        
                    case .failure(let error):
                        guard let status = error.responseCode else {
                            completion(.failure( RouterError.unknown(errorCode: "999")))
                            return
                        }
                        guard let serverMessage = APIErrorEntity(rawValue: status) else {
                            completion(.failure( RouterError.unknown(errorCode: "999")))
                            return
                        }
                        completion(.failure( RouterError.serverMessage(serverMessage)))
                        
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
}


extension NetworkManager {
    public static let shared = NetworkManager()
}

extension NetworkManager: DependencyKey {
    public static let liveValue: NetworkManager = NetworkManager()
}

extension DependencyValues {
    public var networkManager: NetworkManager {
        get { self[NetworkManager.self] }
        set { self[NetworkManager.self] = newValue }
    }
}



public struct ErrorDTO: DTO {
    let code: Int
    let message: String
}
