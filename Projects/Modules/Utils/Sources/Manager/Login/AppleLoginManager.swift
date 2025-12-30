//
//  AppleLoginManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/5/25.
//

import Foundation
import ComposableArchitecture
import AuthenticationServices
import Domain

public final class AppleLoginManager: Sendable {
    
    @MainActor
    public func getASAuthorization() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            
            let request = ASAuthorizationAppleIDProvider()
                .createRequest()
            
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            let delegate = AppleSignDelegate(continuation: continuation)
            
            controller.delegate = delegate
            
            controller.performRequests()
            AppleSignInDelegateStore.shared.delegate = delegate
        }
    }
    
    public func handleAuthorization(
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

final class AppleSignInDelegateStore: @unchecked Sendable {
    var delegate: AppleSignDelegate?
}

extension AppleSignInDelegateStore {
    public static let shared = AppleSignInDelegateStore()
}

extension AppleLoginManager: DependencyKey {
    public static let liveValue: AppleLoginManager = AppleLoginManager()
}

extension DependencyValues {
    public var appleLoginManager: AppleLoginManager {
        get { self[AppleLoginManager.self] }
        set { self[AppleLoginManager.self] = newValue }
    }
}

/// Apple Login 전용
final class AppleSignDelegate: NSObject, ASAuthorizationControllerDelegate {
    
    let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}
