//
//  LoginViewFeature.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture

@Reducer
struct LoginViewFeature {
    
    @ObservableState
    struct State: Equatable {
        let requestAppleLoginList: [ASAuthorization.Scope] = [.fullName, .email]
        
    }
    
    enum Action {
        case getASAuthorization(ASAuthorization)
        case appleLoginError(Error)
        
        case kakaoLoginStart
        
        case sendToServerIdToken(type: String, idToken: String)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            
            case .getASAuthorization(let appleAuth):
                let idToken = handleAuthorization(appleAuth)
                if let idToken {
                    return .send(.sendToServerIdToken(type: "APPLE", idToken: idToken))
                }
            case .appleLoginError(let error):
                let error = error
                
                Logger.debug(error)
            case .kakaoLoginStart:
                return .run { send in
                    guard let idToken = try await kakaoLoginLogic() else {
                        return
                    }
                    
                    await send(.sendToServerIdToken(type: "KAKAO", idToken: idToken))
                    
                } catch: { error, send in
                    guard let error = error as? KakaoLoginErrorCase else {
                        return
                    }
                    
                }
                
            case .sendToServerIdToken(let type, let idToken):
                return .run { send in
                    do {
                        let result = try await networkManager.requestNotDtoNetwork(router: AuthRouter.register(AuthRegisterRequestModel(
                            type: type,
                            idToken: idToken
                        )))
                        
                        print(result)
                        
                    } catch {
                        guard let error = error as? RouterError else {
                            return
                        }
                        print(error)
                    }
                }
                
            }
            
            return .none
        }
    }
}

extension LoginViewFeature {
    
    private func handleAuthorization(
        _ authorization: ASAuthorization
    ) -> String? {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
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
            
            if let identityToken {
                let idToken = String(data: identityToken, encoding: .utf8)
                return idToken
            }
        }
        return nil
    }
    
    
    private func kakaoLoginLogic() async throws(KakaoLoginErrorCase) -> String? {
        
        let result = await KakaoLoginManager.requestKakao()
        switch result {
            
        case .success(let idToken):
            return idToken
        case .failure(let error):
            throw error
        }
    }
}
