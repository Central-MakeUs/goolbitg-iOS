//
//  ResultHabitView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import Utils
import FeatureCommon
import Data

public struct ResultHabitView: View {
    
    public init (store: StoreOf<ResultHabitFeature>) { self.store = store }
    
    @Perception.Bindable var store: StoreOf<ResultHabitFeature>
    
    @State private var cardRotate: Bool = false
    @State private var isShareImageTrigger = false
    @State private var isShareImage: UIImage? = nil
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                content
                
                GBButtonV2(title: TextHelper.fitMeHabitStart) {
                    store.send(.viewEvent(.fitHabitStartTapped))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GBColor.background1.asColor)
            .onAppear {
                store.send(.viewCycle(.onAppear))
            }
            .task {
                try? await Task.sleep(for: .seconds(1))
                cardRotate.toggle()
            }
            .onChange(of: isShareImage) {  newValue in
                isShareImageTrigger = newValue != nil
            }
            .sheet(isPresented: $isShareImageTrigger) {
                isShareImage = nil
            } content: {
                if let isShareImage {
                    ShareSheet(items: [isShareImage])
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium])
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
                Text(store.resultModel.topTitle)
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
        ZStack(alignment: .center) {
            cardAnimationView
                .zIndex(0)
//            replaceView
            userInfoCardView
                .zIndex(1)
                .padding(.horizontal, SpacingHelper.xl.pixel)
        }
    }
    
    private var userInfoCardView: some View {
        VStack(spacing: 0) {
            Text(store.resultModel.stepTitle)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.white.asColor.opacity(0.7))
                .padding(.top, SpacingHelper.lg.pixel)
            
            Text(store.resultModel.nameTitle)
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.white.asColor)
            
            Group {
                if let url = store.resultModel.imageUrl {
                    DownImageView(url: url, option: .max)
                } else {
                    ImageHelper.appLogo2.asImage
                        .resizable()
                }
            }
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
                    Text(store.resultModel.spendingScore)
                        .font(FontHelper.btn2.font)
                }
                
                Spacer()
                Color.white
                    .frame(width: 1)
                    .frame(maxHeight: 25)
                Spacer()
                
                VStack(spacing: 0) {
                    Text("같은 유형 굴비")
                        .font(FontHelper.body4.font)
                    
                    Text(store.resultModel.sameCount)
                        .font(FontHelper.btn2.font)
                }
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.md.pixel)
            
            if let imageURL = store.resultModel.shareImageUrl {
                VStack(alignment: .center, spacing: 0) {
                    Text("나의 소비습관 공유하기")
                        .font(FontHelper.btn4.font)
                        .foregroundStyle(GBColor.grey500.asColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                }
                .background(GBColor.white.asColor)
                .clipShape(Capsule())
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.bottom, SpacingHelper.lg.pixel)
                .asButton {
                    Task {
                        let result = try? await ImageHelper.downLoadImage(url: imageURL)
                        guard let result else { return }
    
                        isShareImage = result
                    }
                }
            }
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
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: cardRotate)
    }
}

extension ResultHabitView {
    private var replaceView: some View {
        VStack(spacing: 0) {
            Text(store.resultModel.stepTitle)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.white.asColor.opacity(0.7))
                .padding(.top, SpacingHelper.lg.pixel)
            
            Text(store.resultModel.nameTitle)
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.white.asColor)
            
            Group {
                if let url = store.resultModel.imageUrl {
                    DownImageView(url: url, option: .max)
                } else {
                    ImageHelper.appLogo2.asImage
                        .resizable()
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 160)
            .background(GBColor.primary300.asColor)
            .clipShape(Circle())
            .padding(.vertical, SpacingHelper.lg.pixel)
            
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                  Text("나의 소비 점수")
                        .font(FontHelper.body4.font)
                    Text(store.resultModel.spendingScore)
                        .font(FontHelper.h3.font)
                }
                
                Spacer()
                Color.white
                    .frame(width: 1)
                    .frame(maxHeight: 25)
                Spacer()
                
                VStack(spacing: 0) {
                    Text("같은 유형 굴비")
                        .font(FontHelper.body4.font)
                    
                    Text(store.resultModel.sameCount)
                          .font(FontHelper.h3.font)
                }
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.lg.pixel + 10)
            
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
}
#if DEBUG
#Preview {
    let spendingType = SpendingTypeDTO(
        id: 0,
        title: "ㅁㄴㅇㅁㄴㅇ",
        imageURL: nil,
        profileUrl: nil,
        onboardingResultUrl: "https://goolbitg.s3.ap-northeast-2.amazonaws.com/onboardingResult_type/02.png",
        goal: 2000,
        peopleCount: 10
    )
    ResultHabitView(store: Store(initialState: ResultHabitFeature.State(userModel: UserInfoDTO(
        id: "",
        nickname: "테스트",
        birthday: "테스트",
        gender: "테스트",
        check1: false,
        check2: false,
        check3: false,
        check4: true,
        check5: true,
        check6: false,
        avgIncomePerMonth: 300,
        avgSpendingPerMonth: 21,
        primeUseDay: nil,
        primeUseTime: nil,
        spendingHabitScore: 315,
        spendingType: spendingType,
        challengeCount: 3,
        postCount: 3,
        achievementGuage: 0.3
    )), reducer: {
        ResultHabitFeature()
    }))
}
#endif
