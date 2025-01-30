//
//  MyPageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import Lottie

struct MyPageView: View {
    
    var body: some View {
        WithPerceptionTracking {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    ImageHelper.myBg.asImage
                        .resizable()
                        .ignoresSafeArea()
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
            }
            
            navigationBar
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.vertical, SpacingHelper.sm.pixel)
                .background(GBColor.background1.asColor)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 0) {
            Text("마이페이지")
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.white.asColor)
            Spacer()
            alertView
        }
    }
    
    private var alertView: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: ImageHelper.bell.image)
                .resizable()
                .frame(width: 24, height: 24)
                .asButton {
                    
                }
            ZStack {
                Circle()
                    .foregroundStyle(GBColor.error.asColor)
                Text("1")
                    .font(.system(size: 11, weight: .medium, design: .default))
            }
            .frame(width: 16, height: 16)
            .offset(y: -5)
            .offset(x: 5)
        }
    }
}

extension MyPageView {
    private var profileView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top ,spacing: 0) {
                
                Image(uiImage: ImageHelper.greenLogo.image)
                    .resizable()
                    .frame(width: 54, height: 54)
                    .padding(.trailing, SpacingHelper.md.pixel)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("초딩 굴비")
                        .font(FontHelper.h4.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text("바쁜 굴비님")
                        .font(FontHelper.h1.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                
                Spacer()
                
                Text("공유하기")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
                    .padding(.horizontal, SpacingHelper.sm.pixel)
                    .padding(.vertical, 4)
                    .background(GBColor.white.asColor.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            HStack(spacing:0) {
                Spacer()
                VStack(spacing:0){
                    Text("내소비 점수")
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text("12점")
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
                Color.white.opacity(0.2)
                    .frame(width: 0.8, height: 40)
                Spacer()
                VStack(spacing:0){
                    Text("내소비 점수")
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text("12점")
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
                Color.white.opacity(0.2)
                    .frame(width: 0.6, height: 20)
                Spacer()
                VStack(spacing:0){
                    Text("내소비 점수")
                        .font(FontHelper.body5.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Text("12점")
                        .font(FontHelper.h3.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
                Spacer()
            }
            .padding(.vertical, SpacingHelper.md.pixel)
            
            HStack {
                Text("다음 굴비까지 18,000원 남았어요")
                    .font(FontHelper.body4.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            
            progressView(percentage: 0.5)
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
                Text("계정 관리")
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
                    
                    Text("아이디")
                        .font(FontHelper.caption1.font)
                        .foregroundStyle(GBColor.grey300.asColor)
                }
                .asButton {
                    
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
                Text("이용 인내")
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
                            Text(version ?? "")
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
            Text("로그아웃")
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.trailing, 6)
                .asButton {
                    
                }
            
            Circle()
                .frame(width: 2)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.trailing, 6)
            
            Text("서비스 탈퇴")
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey300.asColor)
                .asButton {
                    
                }
        }
    }
    
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
        let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        
        return version
    }
}

enum AccountSectionType: CaseIterable {
    case accountID
    
    var title: String {
        switch self {
        case .accountID:
            return "아이디"
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
    MyPageView()
}
#endif
