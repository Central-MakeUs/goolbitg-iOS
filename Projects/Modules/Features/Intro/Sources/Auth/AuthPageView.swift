//
//  AuthPageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/5/25.
//

import SwiftUI
import ComposableArchitecture
import Utils
import Data

/// 권환 가져오는 뷰
struct AuthPageView: View {
    
    @Perception.Bindable var store: StoreOf<AuthRequestPageFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .background(GBColor.background1.asColor)
                .alert(item: $store.alertAlertState.sending(\.alertAlertState)) { title in
                    Text(title)
                } actions: { _ in
                    Text("확인")
                        .asButton {
                            store.send(.alertAlertOKTapped)
                        }
                }

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
              
            Spacer()
            
            startButtonView
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .asButton {
                    store.send(.startButtonTapped)
                }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                Text(TextHelper.authHeader)
                    .font(PretendardFont.extraBold.asFont(size: 24))
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            HStack {
                Text(TextHelper.authHeaderSub)
                    .font(PretendardFont.midFont.asFont(size: 19))
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
        }
    }
    
    private var authRequestListView: some View {
        VStack(spacing: 36) {
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
        .background {
            Rectangle()
                .fill(
                    .linearGradient(colors: [
                        GBColor.primary600.asColor,
                        GBColor.primary400.asColor
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
        .clipShape(Capsule())
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
                .font(PretendardFont.boldFont.asFont(size: 16))
                .foregroundStyle(GBColor.grey200.asColor)
                .padding(.bottom, 4)
            
            Text(subText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(PretendardFont.midFont.asFont(size: 14))
                .foregroundStyle(GBColor.grey300.asColor)
                .fixedSize()
        }
    }
}

#if DEBUG
#Preview {
    AuthPageView(store: Store(initialState: AuthRequestPageFeature.State(), reducer: {
        AuthRequestPageFeature()
    }))
}
#endif
