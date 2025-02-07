//
//  AppleSignProtocol.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/5/25.
//

import Foundation
import AuthenticationServices

/// Apple Login 전용
final class AppleSignProtocol: NSObject, ASAuthorizationControllerDelegate {
    
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
