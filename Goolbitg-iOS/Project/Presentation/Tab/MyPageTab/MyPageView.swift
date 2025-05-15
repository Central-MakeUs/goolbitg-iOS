//
//  MyPageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import Lottie

struct MyPageView: View {
    
    @Perception.Bindable var store: StoreOf<MyPageViewFeature>
    
    @State private var showShareLink: Bool = false
    @State private var imageTrigger: UIImage? = nil
    @State private var pushCount: Int = 0

    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Dependency(\.pushNotiManager) var pushManager
    
    var body: some View {
        WithPerceptionTracking {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    ImageHelper.myBg.asImage
                        .resizable()
                        .ignoresSafeArea()
                }
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .sheet(isPresented: $showShareLink) {
                    if let image = imageTrigger {
                        ShareSheet(items: [image])
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.medium])
                    }
                }
                // MARK: LogOut
                .popup(item: $store.logoutAlert.sending(\.alertState)) { item in
                    GBAlertView(
                        model: item) {
                            store.send(.alertState(nil))
                        } okTouch: {
                            store.send(.alertState(nil))
                            store.send(.viewEvent(.acceptLogoutButtonTapped))
                        }
                } customize: {
                    $0
                        .type(.default)
                        .animation(.bouncy)
                        .appearFrom(.centerScale)
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .backgroundColor(Color.black.opacity(0.5))
                }
        }
    }
}

extension MyPageView {
    private var content: some View {
        ZStack(alignment: .top) {
            ScrollView {
                navigationBar
                    .padding(.horizontal, SpacingHelper.lg.pixel)
                    .padding(.vertical, SpacingHelper.sm.pixel)
                    .opacity(0)
                
                profileView
                    .padding(.top, 6)
                    .padding(.horizontal, SpacingHelper.md.pixel)
                
                accountSection
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.top, SpacingHelper.md.pixel)
                
                serviceSectionView
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.vertical, SpacingHelper.md.pixel)
                
                logOutAndServiceRevoke
                    .padding(.bottom, SpacingHelper.md.pixel)
                
                Color.clear
                    .frame(height: safeAreaInsets.bottom + 20)
                
            }
            
            navigationBar
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.vertical, SpacingHelper.sm.pixel)
                .background(GBColor.background1.asColor)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 0) {
            Text(TextHelper.myPage)
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.white.asColor)
            Spacer()
            alertView
        }
    }
    
    private var alertView: some View {
        NotiAlertView(notiCount: $pushCount)
            .asButton {
                store.send(.viewEvent(.alertButtonTapped))
            }
            .onReceive(pushManager.publishNewMessageCount) { count in
                pushCount = count
            }
    }
}

extension MyPageView {
    private var profileView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top ,spacing: 0) {
                
                if let url = store.userEntity.userTypeImageUrl {
                    DownImageView(url: URL(string: url), option: .mid)
                        .frame(width: 54, height: 54)
                        .padding(.trailing, SpacingHelper.md.pixel)
                } else {
                    Image(uiImage: ImageHelper.greenLogo.image)
                        .resizable()
                        .frame(width: 54, height: 54)
                        .padding(.trailing, SpacingHelper.md.pixel)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(store.userEntity.typeDetail)
                        .font(FontHelper.h4.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text(store.userEntity.nickname)
                        .font(FontHelper.h1.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                
                Spacer()
                
                if let url = store.userEntity.shareImageUrl {
                    Text(TextHelper.sharedTitle)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                        .padding(.horizontal, SpacingHelper.sm.pixel)
                        .padding(.vertical, 4)
                        .background(GBColor.white.asColor.opacity(0.2))
                        .clipShape(Capsule())
                        .asButton {
                            Task {
                                let image = try? await ImageHelper.downLoadImage(url: url)
                                guard let image else { return }
                                imageTrigger = image
                                showShareLink = true
                            }
                        }
                }
            }
            
            HStack(spacing:0) {
                Spacer()
                VStack(spacing:0){
                    Text(TextHelper.mySpendingScoreTitle)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text(store.userEntity.spandingScore)
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
                Color.white.opacity(0.2)
                    .frame(width: 0.8, height: 40)
                Spacer()
                VStack(spacing:0){
                    Text(TextHelper.totalChallengeCount)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text(store.userEntity.totalChallengeCount)
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
                Color.white.opacity(0.2)
                    .frame(width: 0.6, height: 20)
                Spacer()
                VStack(spacing:0){
                    Text(TextHelper.writeCount)
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text(store.userEntity.writeCount)
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
            }
            .padding(.vertical, SpacingHelper.md.pixel)
            
            HStack {
                Text(store.userEntity.nextGoolbTitle)
                    .font(FontHelper.body4.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            
            progressView(percentage: store.userEntity.nextGoolBPercent)
                .padding(.vertical, SpacingHelper.xs.pixel)
            
        }
        .padding(.all, SpacingHelper.lg.pixel)
        .background {
            Rectangle()
                .fill(
                    .linearGradient(colors: [
                        Color(uiColor: UIColor(hexCode: "#41A420", alpha: 1)),
                        Color(uiColor: UIColor(hexCode: "#67BF4E", alpha: 1)),
                        Color(uiColor: UIColor(hexCode: "#67BF4E", alpha: 0.9))
                    ], startPoint: .leading, endPoint: .trailing)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func progressView(percentage: Double) -> some View {
        ZStack (alignment: .leading) {
            GeometryReader { proxy in
                Capsule()
                    .frame(height: 17)
                    .foregroundStyle(GBColor.black.asColor.opacity(0.1))
                Capsule()
                    .frame(
                        width: proxy.size.width * CGFloat(percentage),
                        height: 17
                    )
                    .foregroundStyle(GBColor.white.asColor)
            }
        }
    }
}

extension MyPageView {
    private var accountSection: some View {
        VStack(spacing:0) {
            HStack {
                Text(TextHelper.accountSetting)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            ForEach(AccountSectionType.allCases, id: \.self) { item in
                HStack(spacing:0) {
                    Image(uiImage: UIImage(named: item.imgName) ?? UIImage())
                        .resizable()
                        .frame(width: 18, height: 16)
                        .padding(.trailing, SpacingHelper.sm.pixel)
                    Text(item.title)
                        .font(FontHelper.caption1.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Spacer()
                    
                    if case .accountID = item {
                        Text(store.userEntity.userID)
                            .font(FontHelper.caption1.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                    }
                }
                .asButton {
                    store.send(.viewEvent(.accountSectionItemTapped(item: item)))
                }
            }
            .padding(.vertical, SpacingHelper.md.pixel)
            .padding(.horizontal, SpacingHelper.sm.pixel)
        }
        .padding(.all, SpacingHelper.md.pixel)
        .background {
            BlurView(style: .systemUltraThinMaterialDark)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var serviceSectionView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TextHelper.serviceInfo)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            .padding(.bottom, SpacingHelper.sm.pixel)
            
            ForEach(ServiceInfoSectionType.allCases, id: \.self) { item in
                LazyVStack(spacing: 0) {
                    HStack(spacing:0) {
                        Image(uiImage: UIImage(named: item.imgName) ?? UIImage())
                            .padding(.trailing, SpacingHelper.sm.pixel)
                        
                        Text(item.title)
                            .font(FontHelper.caption1.font)
                            .foregroundStyle(GBColor.white.asColor)
                        Spacer()
                        
                        if item == .appVersion {
                            Text(store.version ?? "")
                                .font(FontHelper.caption1.font)
                                .foregroundStyle(GBColor.grey300.asColor)
                        } else {
                            ImageHelper.right.asImage
                                .resizable()
                                .frame(width: 6, height: 10)
                        }
                    }
                    .padding(.all, SpacingHelper.sm.pixel)
                    .asButton {
                        store.send(.viewEvent(.serviceSectionItemTapped(item: item)))
                    }
                    Group {
                        if ServiceInfoSectionType.allCases.last != item {
                            Color.white
                                .frame(height: 0.3)
                                .foregroundStyle(GBColor.grey300.asColor.opacity(0.2))
                        }
                    }
                    .padding(.vertical, SpacingHelper.sm.pixel)
                }
            }
            
            .padding(.horizontal, SpacingHelper.sm.pixel)
            
        }
        .padding(.all, SpacingHelper.md.pixel)
        .background {
            BlurView(style: .systemUltraThinMaterialDark)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var logOutAndServiceRevoke: some View {
        HStack(spacing: 0){
            Text(TextHelper.logOut)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.trailing, 6)
                .asButton {
                    store.send(.viewEvent(.logOutButtonTapped))
                }
            
            Circle()
                .frame(width: 2)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.trailing, 6)
            
            Text(TextHelper.serviceRevoke)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey300.asColor)
                .asButton {
                    store.send(.viewEvent(.revokeButtonTapped))
                }
        }
    }
}

enum AccountSectionType: CaseIterable {
    case accountID
    
    var title: String {
        switch self {
        case .accountID:
            return TextHelper.accountID
        }
    }
    
    var imgName: String {
        switch self {
        case .accountID:
            return "User"
        }
    }
}

enum ServiceInfoSectionType: CaseIterable {
    case appVersion
    case request
    case serviceInfo
    case privacyPolicy
    
    var title: String {
        switch self {
        case .appVersion:
            return "앱 버전"
        case .request:
            return "문의하기"
        case .serviceInfo:
            return "서비스 이용약관"
        case .privacyPolicy:
            return "개인 정보 처리 방침"
        }
    }
    
    var imgName: String {
        switch self {
        case .appVersion:
            return "box"
        case .request:
            return "headPhone"
        case .serviceInfo:
            return "document"
        case .privacyPolicy:
            return "document"
        }
    }
}


#if DEBUG
#Preview {
    MyPageView(store: Store(initialState: MyPageViewFeature.State(), reducer: {
        MyPageViewFeature()
    }))
}
#endif
