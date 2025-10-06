//
//  GraphBarView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/6/25.
//

import SwiftUI
import Utils

struct GraphBarView: View {
    
    @State private var textHeight: CGFloat = 0
    @State private var animatePercentage: CGFloat = 0
    
    let count: Int
    let percentage: CGFloat
    let style: GraphBarStyle
    
    var body: some View {
        content
    }
}

enum GraphBarStyle: Equatable, Hashable {
    case grey
    case mainColor
    case dotStyleForRecommend
}

extension GraphBarView {
    
    private var content: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                Spacer(minLength: 0)
                
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
                
                Color.clear.frame(height: 8) // MARK: Spacing
                
                getStick(proxy: proxy)
            }
            .animation(.bouncy(duration: 0.6), value: animatePercentage)
            .frame(alignment: .bottom)
        }
        .onAppear {
            animatePercentage = percentage
        }
    }
    
    private func calcHeight(proxy: GeometryProxy) -> CGFloat {
        max(proxy.size.height * CGFloat(animatePercentage) - textHeight, 0)
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
                .frame(
                    width: .infinity,
                    height: calcHeight(proxy: proxy)
                )
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
                .frame(
                    width: .infinity,
                    height: calcHeight(proxy: proxy)
                )
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
                .frame(
                    width: .infinity,
                    height: calcHeight(proxy: proxy)
                )
        }
        
    }
}

#if DEBUG
#Preview {
    VStack {
        RecentChallengeMonthlyComparisonGraphView(
            difference: 3,
            monthDataCount: [5, 8, 10]
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(GBColor.background1.asColor)
}
#endif
