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
    
    @Perception.Bindable var store: StoreOf<LoginViewFeature>
    
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
            Spacer()
            
            appLogoView
                .padding(.horizontal, 20)
                
            Spacer()
            
            loginButtonViews
                .padding(.horizontal, 30)
                .padding(.bottom, 80)
                
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var loginButtonViews: some View {
        VStack(spacing: 14) {
            
            kakaoLoginButtonView
                .asButton {
                    store.send(.kakaoLoginStart)
                }
                .foregroundStyle(.black)
                
            appleLoginButtonView
                .overlay {
                    SignInWithAppleButton { request in
                        
                        request.requestedScopes = store.requestAppleLoginList
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            store.send(.getASAuthorization(authorization))
                        case .failure(let fail):
                            store.send(.appleLoginError(fail))
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var appleLoginButtonView: some View {
        ZStack {
            HStack {
            
                Image(uiImage: ImageHelper.appleLogo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 18)
                    .padding(.leading, 20)
            
                Spacer()
            }
            
            Text(TextHelper.appleLogin)
                .font(FontHelper.apple600.font)
                .foregroundStyle(Color.black.opacity(0.85))
        }
        .frame(height: 45)
        .background(Color(uiColor: GBColor.white.color))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var kakaoLoginButtonView: some View {
        ZStack {
            HStack {
            
                Image(uiImage: ImageHelper.kakao.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .padding(.leading, 20)
            
                Spacer()
            }
            
            Text(TextHelper.kakaoLogin)
                .font(FontHelper.apple600.font)
                .foregroundStyle(Color.black.opacity(0.85))
        }
        .frame(height: 45)
        .background(Color(uiColor: GBColor.kakao.color))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#if DEBUG
#Preview {
    GBLoginView(store: Store(initialState: LoginViewFeature.State(), reducer: {
        LoginViewFeature()
    }))
}
#endif

