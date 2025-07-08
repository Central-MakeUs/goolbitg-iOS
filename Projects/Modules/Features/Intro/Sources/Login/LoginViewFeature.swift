//
//  LoginViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture
import Utils
import Data

@Reducer
public struct LoginViewFeature {
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        let requestAppleLoginList: [ASAuthorization.Scope] = [.fullName, .email]
        
    }
    
    public enum Action {
        case getASAuthorization(ASAuthorization)
        case appleLoginError(Error)
        
        case kakaoLoginStart
        
        case rootLoginStart
        
        case sendToServerIdToken(type: String, idToken: String, authToken: String? = nil)
        case sendToLoginServerIdToken(type: String, idToken: String)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case loginSuccess
            case moveToOnBoarding(RegisterStatusCase)
        }
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.mainQueue) var mainQueue
    
    enum CancelID: Hashable, Sendable {
        case kakao
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            
            case .getASAuthorization(let appleAuth):
                // apple 1차 토큰
                let auth = handleAuthorization(appleAuth)
                
                guard let authToken = auth.auth,
                      let idToken = auth.id
                else {
                    // MARK: ERROR 처리 해야함.
                    return .none
                }
                LoadingEnvironment.shared.loading(true)
                return .send(.sendToServerIdToken(type: "APPLE", idToken: idToken, authToken: authToken))

            case .appleLoginError(let error):
                let error = error
                
                Logger.debug(error)
            case .kakaoLoginStart:
                LoadingEnvironment.shared.loading(true)
                return .run { send in
                    guard let idToken = try await kakaoLoginLogic() else {
                        return
                    }
                    Logger.info(" ^^^^^^^^^^^ \(idToken)")
                    
                    FireBaseManager.logEvent(log: FireBaseLogModel(
                        eventName: "KAKAO_Login",
                        parameters: [
                            "file": #file,
                            "function" : #function
                        ],
                        logType: .login)
                    )
                    
                    await send(.sendToServerIdToken(type: "KAKAO", idToken: idToken))
                    
                } catch: { error, send in
                    LoadingEnvironment.shared.loading(false)
                    guard error is KakaoLoginErrorCase else {
                        return
                    }
                }
                
//                    .throttle(id: CancelID.kakao, for: 5, scheduler: mainQueue, latest: false)
                    .throttle(id: CancelID.kakao, for: 5, scheduler: DispatchQueue.main.eraseToAnyScheduler(), latest: false)
                
            case .sendToServerIdToken(let type, let idToken, let auth):
                return .run { send in
                    do {
                        Logger.info(" ^^^^^^^^^^^ \(idToken)")
                        let result = try await networkManager.requestNotDtoNetwork(router: AuthRouter.register(AuthRegisterRequestModel(
                            type: type,
                            idToken: idToken,
                            authToken: auth
                        )))
                        
                        if result {
                            await send(.sendToLoginServerIdToken(type: type, idToken: idToken))
                        }
                        LoadingEnvironment.shared.loading(false)
                    } catch {
                        LoadingEnvironment.shared.loading(false)
                        guard let error = error as? RouterError else {
                            return
                        }
                        if case .serverMessage(let server) = error {
                            if case .alreadyMember = server {
                                await send(.sendToLoginServerIdToken(type: type, idToken: idToken))
                            }
                            // 이때의 에러도 분석해서 팝업 준비
                        }
                    }
                }
                
            case .sendToLoginServerIdToken(let type, let idToken):
                return .run { send in
                    let request = try await networkManager.requestNetwork(dto: LoginAccessDTO.self, router: AuthRouter
                        .login(
                        AuthLoginRequestModel(
                            type: type,
                            idToken: idToken )
                        )
                    )
                    saveToken(access: request.accessToken, refresh: request.refreshToken)
                    
                    FireBaseManager.logEvent(log: FireBaseLogModel(
                        eventName: "APPLE_Login",
                        parameters: [
                            "file": #file,
                            "function" : #function
                        ],
                        logType: .login)
                    )
                    
                    UserDefaultsManager.ifAppleLoginUser = type == "APPLE"
                    // MARK: 여기선 이제 로그인 후 필수정보 쓴사람인가 아닌가 분석
                    
                    let requestRegisterState = try await networkManager.requestNetworkWithRefresh(dto: UserRegisterStatus.self, router: UserRouter.userRegisterStatus)
                    
                    Logger.info(requestRegisterState)
                    LoadingEnvironment.shared.loading(false)
                    // 필수 기입사항 안했을시
                    if !requestRegisterState.requiredInfoCompleted {
                        await send(.delegate(.moveToOnBoarding(requestRegisterState.status)))
                    } else {
                        await send(.delegate(.moveToOnBoarding(.registEnd)))
                    }
                    
                } catch: { error, send in
                    LoadingEnvironment.shared.loading(false)
                    guard let error = error as? RouterError else {
                        return
                    }
                    // 토큰 유효 + 등록되지 않았을때 처리 해야함
                    if case .serverMessage(let apiErrorEntity) = error {
                        Logger.warning(apiErrorEntity)
                    }
                }
                
            case .rootLoginStart:
                return .run { send in
                    await RootLoginManager.login()
                    
                    FireBaseManager.logEvent(log: FireBaseLogModel(
                        eventName: "RootLogin",
                        parameters: [
                            "file": #file,
                            "function" : #function
                        ],
                        userID: "ROOT",
                        logType: .login)
                    )
                    
                    await send(.delegate(.moveToOnBoarding(.registEnd)))
                } catch: { error, send in
                    Logger.error(error)
                }
                
            default:
                break
            }
            return .none
        }
    }
}

extension LoginViewFeature {
    /// 회원 가입시 받고
    /// 회원 탈퇴시 받고
    private func handleAuthorization(
        _ authorization: ASAuthorization
    ) -> (auth: String?, id: String?) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var idToken: String? = nil
            var authToken: String? = nil
            
            // 사용자 ID
            let userID = appleIDCredential.user
            print("User ID: \(userID)")

            // 사용자 이메일 (최초 로그인 시만)
            let email = appleIDCredential.email
            print("Email: \(email ?? "No Email")")

            // 사용자 이름 (최초 로그인 시만)
            if let fullName = appleIDCredential.fullName {
                let givenName = fullName.givenName ?? ""
                let familyName = fullName.familyName ?? ""
                print("Full Name: \(givenName) \(familyName)")
            }
            
            // 인증 코드 (서버 검증에 사용)
            let authorizationCode = appleIDCredential.authorizationCode
            print("Authorization Code: \(String(data: authorizationCode ?? Data(), encoding: .utf8) ?? "")")
            
            // ID Token (서버 검증에 사용)
            let identityToken = appleIDCredential.identityToken
            print("Identity Token: \(String(data: identityToken ?? Data(), encoding: .utf8) ?? "")")
            
            if let authorizationCode {
                let auth = String(data: authorizationCode, encoding: .utf8)
                authToken = auth
            }
            if let identityToken {
                let id = String(data: identityToken, encoding: .utf8)
                idToken = id
            }
            return (authToken, idToken)
        }
        return (nil, nil)
    }
    
    
    private func kakaoLoginLogic() async throws(KakaoLoginErrorCase) -> String? {
        
        let result = await KakaoLoginManager.requestKakao()
        switch result {
            
        case .success(let idToken):
            Logger.info(" ^^^^^^^^^^^ \(idToken)")
            return idToken
        case .failure(let error):
            throw error
        }
    }
    
    private func saveToken(access: String, refresh: String) {
        UserDefaultsManager.accessToken = access
        UserDefaultsManager.refreshToken = refresh
    }
}
