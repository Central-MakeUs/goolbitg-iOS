//
//  GBLoginView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI
import AuthenticationServices
import ComposableArchitecture

struct GBLoginView: View {
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

// MARK: UI
extension GBLoginView {
    private var contentView: some View {
        VStack {
            appLogoView
                .padding(.top, 160)
               
            Spacer()
            
            loginButtonViews
                .padding(.bottom, 100)
                
        }
    }
    
    private var loginButtonViews: some View {
        VStack(spacing: 14) {
            
            kakaoLoginButtonView
                .padding(.horizontal, 10)
                .asButton {
                    Task {
                        let result = await KakaoLoginManager.requestKakao()
                        switch result {
                        case .success(let accessToken):
                            print(accessToken)
                        case .failure(let fail):
                            print(fail)
                        }
                    }
                }
                .foregroundStyle(.black)
                
            appleLoginButtonView
                .padding(.horizontal, 10)
                .overlay {
                    SignInWithAppleButton { request in
                        
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            handleAuthorization(authorization)
                        case .failure(let fail):
                            print("FAIL \(fail)")
                        }
                    }
                    .blendMode(.overlay)
                }
                
        }
    }
    
    private var appLogoView: some View {
        VStack {
            Image(uiImage: ImageHelper.appLogo.image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 93, height: 93)
        }
    }
    
    private var appleLoginButtonView: some View {
        VStack {
            HStack {
                
                Image(uiImage: ImageHelper.appleLogo.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 46, height: 46)
                    .padding(.leading, 60)
                    .padding(.trailing, 40)
                
                Text(TextHelper.appleLogin)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
    
    private var kakaoLoginButtonView: some View {
        VStack {
            HStack {
            
                Image(uiImage: ImageHelper.kakao.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 46, height: 46)
                    .padding(.leading, 60)
                    .padding(.trailing, 40)

                Text(TextHelper.kakaoLogin)
                
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .background(Color(uiColor: GBColor.kakao.color))
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

#Preview {
    GBLoginView()
}

// 비즈니스 로직 옮길 예정
extension GBLoginView {
    
    func handleAuthorization(_ authorization: ASAuthorization) {
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
        }
    }

}
