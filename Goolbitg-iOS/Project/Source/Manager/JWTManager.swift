//
//  JWTManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import Foundation
import ComposableArchitecture
import SwiftJWT

final class JWTManager: Sendable {
    func makeAppleClientSecretJWT() -> String {
        let header = Header(kid: SecretKeys.appleKeyID)
        
        struct AppleClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + (6 * 30 * 24 * 60 * 60)
        let myClaims = AppleClaims(
            iss: SecretKeys.teamID,
            iat: iat,
            exp: exp,
            aud: "https://appleid.apple.com",
            sub: Bundle.main.bundleIdentifier ?? SecretKeys.bundleID
        )
        var jwt = JWT(header: header, claims: myClaims)
        
        guard let url = Bundle.main.url(forResource: SecretKeys.p8Path, withExtension: ""),
              let privateKey = try? Data(contentsOf: url, options: .alwaysMapped) else {
            Logger.error("🔴 JWT 생성 실패: SecretKeys.p8Path 파일을 찾을 수 없음")
            return ""
        }
        do {
            let jwtSigner = JWTSigner.es256(privateKey: privateKey)
            let signedJWT = try jwt.sign(using: jwtSigner)
            Logger.info("✅ JWT 생성 성공: \(signedJWT)")
            return signedJWT
        } catch {
            Logger.error("🔴 JWT 서명 실패: \(error.localizedDescription)")
            return ""
        }
    }
}

extension JWTManager: DependencyKey {
    static let liveValue: JWTManager = JWTManager()
}
extension DependencyValues {
    var jwtManager: JWTManager {
        get {
            self[JWTManager.self]
        } set {
            self[JWTManager.self] = newValue
        }
    }
}
