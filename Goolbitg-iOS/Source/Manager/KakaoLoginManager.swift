//
//  KakaoLoginManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import Foundation
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKUser

enum KakaoLoginErrorCase: Error {
    case cancel
    case error(SdkError)
    
    var message: String {
        switch self {
        case .cancel:
            return ""
        case .error(_):
            return "KAKAO 로그인 실패\n재시도 바랍니다."
        }
    }
}

protocol KakaoLoginManagerType {
    /// Kakao Login 은 GCD 구조로 Result 형태로 방출 해드립니다.
    static func requestKakao() async -> Result<String, KakaoLoginErrorCase>
}

struct KakaoLoginManager: KakaoLoginManagerType {
    
     static func requestKakao() async -> Result<String, KakaoLoginErrorCase> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return await withCheckedContinuation { contin in
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error {
                        let results = checkKakaoError(error: error)
                        contin.resume(returning: .failure(results))
                    } else if let oauthToken,
                              let idToken = oauthToken.idToken {
                        print("카카오톡 성공 \(oauthToken)")
                        Logger.info(" ㅗㅗㅗㅗㅗㅗㅗㅗ \(idToken)")
                        contin.resume(returning: .success(idToken))
                    } else {
                        contin.resume(returning:.failure(.error(.init(apiFailedMessage: "FAIL KAKAO"))))
                    }
                }
            }
        } else {
            return await withCheckedContinuation { contin in
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error {
                        let result = checkKakaoError(error: error)
                        contin.resume(returning: .failure(result))
                    } else if let oauthToken,
                              let idToken = oauthToken.idToken {
                        print("카카오톡 성공 \(oauthToken)")
                        Logger.info(" ㅗㅗㅗㅗㅗㅗㅗㅗ \(idToken)")
                        contin.resume(returning: .success(idToken))
                    } else {
                        contin.resume(returning: .failure(.error(.init(apiFailedMessage: "FAIL KAKAO"))))
                    }
                }
            }
        }
    }
    
    static private func checkKakaoError(error: Error) -> KakaoLoginErrorCase {
        
        guard let error = error as? SdkError else {
            return .error(.init(apiFailedMessage: "알수 없는 에러"))
        }
        if !error.isClientFailed {
            print("카카오 에러 \(error)")
            return .error(error)
        }
        return .cancel
    }
    
}


extension KakaoLoginManager: DependencyKey {
    static let liveValue: Self = Self()
}

extension DependencyValues {
    
    var kakaoLoginManager: KakaoLoginManager {
        get { self[KakaoLoginManager.self] }
        set { self[KakaoLoginManager.self] = newValue }
    }
}
