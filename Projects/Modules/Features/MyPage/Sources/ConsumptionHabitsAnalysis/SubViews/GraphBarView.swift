//
//  GraphBarView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/6/25.
//

import SwiftUI
import Utils
import Domain

struct GraphBarView: View {
    
    @State private var textHeight: CGFloat = 0
    @State private var animatePercentage: CGFloat = 0
    @State private var hasAnimatedAfterVisible: Bool = false
    
    let count: Int
    let percentage: CGFloat
    let style: GraphBarStyle
    let topTextIgnored: Bool
    let shouldAnimate: Bool
    
    init(
        count: Int = 0,
        percentage: CGFloat,
        style: GraphBarStyle,
        topTextIgnored: Bool = false,
        shouldAnimate: Bool = true
    ) {
        self.count = count
        self.percentage = percentage.isFinite ? min(max(percentage, 0), 1) : 0
        self.style = style
        self.topTextIgnored = topTextIgnored
        self.shouldAnimate = shouldAnimate
    }
    
    var body: some View {
        content
    }
}

extension GraphBarView {
    
    private var content: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                Spacer(minLength: 0)
                if !topTextIgnored {
                    VStack(spacing: 0) {
                        Text("추천")
                            .font(FontHelper.caption3.font)
                            .opacity(style == .dotStyleForRecommend ? 1 : 0)
                        
                        Text("\(count) 개")
                            .font(FontHelper.body5.font)
                    }
                    .readHeight { h in
                        textHeight = h + 8
                    }
                    .foregroundStyle(getTextColor)
                }
                Color.clear.frame(height: 8) // MARK: Spacing
                
                getStick(proxy: proxy)
            }
            .animation(.bouncy(duration: 0.6), value: animatePercentage)
            .frame(alignment: .bottom)
        }
        .onAppear {
            guard shouldAnimate else {
                animatePercentage = 0
                return
            }
            guard !hasAnimatedAfterVisible else { return }
            hasAnimatedAfterVisible = true

            if percentage > 0 {
                animatePercentage = 0
                DispatchQueue.main.async {
                    animatePercentage = percentage
                }
            } else {
                animatePercentage = 0
            }
        }
        .onChange(of: percentage) { newValue in
            if hasAnimatedAfterVisible, shouldAnimate {
                animatePercentage = newValue
            }
        }
        .onChange(of: shouldAnimate) { newValue in
            guard newValue else { return }
            guard !hasAnimatedAfterVisible else { return }
            hasAnimatedAfterVisible = true

            if percentage > 0 {
                animatePercentage = 0
                DispatchQueue.main.async {
                    animatePercentage = percentage
                }
            }
        }
    }

    private func calcHeight(proxy: GeometryProxy) -> CGFloat {
        let safePercentage = animatePercentage.isFinite ? min(max(animatePercentage, 0), 1) : 0
        return max(proxy.size.height * safePercentage - textHeight, 0)
    }

    private var getTextColor: Color {
        return switch style {
        case .dotStyleForRecommend, .mainColor:
            GBColor.main.asColor
        case .grey:
            GBColor.grey300.asColor
        }
    }

    @ViewBuilder
    private func getStick(proxy: GeometryProxy) -> some View {
        switch style {
        case .grey:
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            GBColor.white.asColor.opacity(0.15),
                            GBColor.white.asColor.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: calcHeight(proxy: proxy))
                .cornerRadiusCorners(proxy.size.width / 2, corners: [.topLeft, .topRight])
               
        case .mainColor:
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            GBColor.main.asColor,
                            GBColor.main.asColor.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: calcHeight(proxy: proxy))
                .cornerRadiusCorners(proxy.size.width / 2, corners: [.topLeft, .topRight])
                    
        case .dotStyleForRecommend:
            RoundedCornerShape(corners:[.topLeft, .topRight], radius: proxy.size.width / 2)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .fill(
                    LinearGradient(
                        colors: [
                            GBColor.main.asColor,
                            GBColor.main.asColor.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: calcHeight(proxy: proxy))
        }

    }
}

#if DEBUG
import Data

#Preview {
    VStack {
        RecentChallengeWeeklyComparisonGraphView(
            message: "지난주보다 3개의 챌린지를 더 완료했어요!",
            maxCount: 10,
            monthDataList: RecentChallengeWeeklyEntity.mocks
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(GBColor.background1.asColor)
}
#endif
