//
//  AppleLoginManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/5/25.
//

import Foundation
import ComposableArchitecture
import AuthenticationServices


final class AppleLoginManager: Sendable {
    
    @MainActor
    func getASAuthorization() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            
            let request = ASAuthorizationAppleIDProvider()
                .createRequest()
            
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            let delegate = AppleSignProtocol(continuation: continuation)
            
            controller.delegate = delegate
            
            controller.performRequests()
            AppleSignInDelegateStore.shared.delegate = delegate
        }
    }
    
    func handleAuthorization(
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
}

final class AppleSignInDelegateStore {
    static let shared = AppleSignInDelegateStore()
    var delegate: AppleSignProtocol?
}

extension AppleLoginManager: DependencyKey {
    static let liveValue: AppleLoginManager = AppleLoginManager()
}

extension DependencyValues {
    var appleLoginManager: AppleLoginManager {
        get { self[AppleLoginManager.self] }
        set { self[AppleLoginManager.self] = newValue }
    }
}
