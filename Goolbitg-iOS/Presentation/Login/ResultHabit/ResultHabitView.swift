//
//  ResultHabitView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import ComposableArchitecture

struct ResultHabitView: View {
    
    @State private var cardRotate: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                content
                
                GBButtonV2(title: TextHelper.fitMeHabitStart) {
                    
                }
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GBColor.background1.asColor)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    cardRotate.toggle()
                }
            }
        }
    }
}

extension ResultHabitView {
    private var content: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 12)
            
            cardView
            
            Spacer()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: SpacingHelper.lg.pixel) {
            HStack {
                Text("바쁜굴비님은\n배고픈 굴비유형입니다")
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            .padding(.top, 34)
            
            HStack {
                Text(TextHelper.resultHabitRecommendationTitle)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
    }
    
    private var cardView: some View {
        ZStack {
            cardAnimationView
            userInfoCardView
                .padding(.horizontal, SpacingHelper.xl.pixel)
        }
    }
    private var userInfoCardView: some View {
        VStack(spacing: 0) {
            Text("1단계 굴비")
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.white.asColor.opacity(0.7))
                .padding(.top, SpacingHelper.lg.pixel)
            
            Text("아가 굴비")
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.white.asColor)
            
            Image(.appLogo2)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 132)
                .background(GBColor.primary300.asColor)
                .clipShape(Circle())
                .padding(.vertical, SpacingHelper.md.pixel)
            
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                  Text("나의 소비 점수")
                        .font(FontHelper.body4.font)
                  Text("12점")
                        .font(FontHelper.h2.font)
                }
                
                Spacer()
                Color.white
                    .frame(width: 1)
                    .frame(maxHeight: 25)
                Spacer()
                
                VStack(spacing: 0) {
                    Text("같은 유형 굴비")
                        .font(FontHelper.body4.font)
                    
                    Text("40명")
                          .font(FontHelper.h2.font)
                }
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.md.pixel)
            
            VStack(alignment: .center, spacing: 0) {
                Text("나의 소비습관 공유하기")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.grey500.asColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .background(GBColor.white.asColor)
            .clipShape(Capsule())
            .padding(.horizontal, SpacingHelper.lg.pixel)
            .padding(.bottom, SpacingHelper.lg.pixel)
            
        }
        .frame(maxWidth: .infinity)
        .background {
            BlurView(style: .systemUltraThinMaterialLight)
                .opacity(0.984)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 1)
                .opacity(0.8)
        }
    }
    
    private var cardAnimationView: some View {
        Image(uiImage: ImageHelper.greenCard.image)
            .resizable()
            .aspectRatio(329 / 407, contentMode: .fit)
            .padding(.horizontal, 30)
            .padding(.trailing, 10)
            .offset(y: cardRotate ? 40 : 0)
            .offset(x: cardRotate ? -15: -4)
            .rotationEffect(.degrees(cardRotate ? 4 : 0))
    }
}

#if DEBUG
#Preview {
    ResultHabitView()
}
#endif
