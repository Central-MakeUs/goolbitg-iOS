//
//  AuthPageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/5/25.
//

import SwiftUI
import ComposableArchitecture

/// 권환 가져오는 뷰
struct AuthPageView: View {
    
    // MARK: feature 로 이동할 로직입니다.
    @Dependency(\.pushNotiManager) var pushManager
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

// MARK: UI
extension AuthPageView {
    private var contentView: some View {
        VStack {
            headerView
                .padding(.top, 40)
                .padding(.horizontal, 20)
                
            Spacer()
            
            authRequestListView
                .padding(.bottom, 100)
            
            startButtonView
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .asButton {
                    Task {
                        // 허용 가정하고 푸시 테스트
                       let result = try await pushManager.requestNotificationPermission()
                        if result {
                            pushManager.getDeviceToken()
                        }
                    }
                }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                Text(TextHelper.authHeader)
                    .font(Font.system(size: 30, weight: .bold))
                Spacer()
            }
            HStack {
                Text(TextHelper.authHeaderSub)
                    .font(Font.system(size: 19))
                Spacer()
            }
        }
    }
    
    private var authRequestListView: some View {
        VStack(spacing: 34) {
            ForEach(AuthListEnum.allCases, id: \.self) { item in
                makeAuthReqeustView(
                    image: item.image.image,
                    headerText: item.title,
                    subText: item.subTitle
                )
            }
        }
    }
    
    private var startButtonView: some View {
        VStack {
            HStack {
                Spacer()
                Text(TextHelper.authStart)
                    .font(Font.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.vertical, 18)
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

extension AuthPageView {
    private func makeAuthReqeustView(
        image: UIImage,
        headerText: String,
        subText: String
    ) -> some View {
        VStack (spacing: 0) {
            Image(uiImage: image)
                .padding(.bottom, 14)
            Text(headerText)
                .font(Font.system(size: 16, weight: .bold))
                .padding(.bottom, 5)
            Text(subText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(Font.system(size: 14))
                .fixedSize()
        }
    }
}

#Preview {
    AuthPageView()
}
