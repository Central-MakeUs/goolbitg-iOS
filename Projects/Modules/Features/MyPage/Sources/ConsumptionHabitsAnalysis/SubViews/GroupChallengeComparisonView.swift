//
//  GroupChallengeComparisonView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/11/25.
//

import SwiftUI
import Utils

struct GroupChallengeComparisonView: View {
    
    let indvScore: Double
    let groupScore: Double
    let message: String
    let shouldAnimateBars: Bool

    init(
        indvScore: Double,
        groupScore: Double,
        message: String,
        shouldAnimateBars: Bool = true
    ) {
        self.indvScore = indvScore
        self.groupScore = groupScore
        self.message = message
        self.shouldAnimateBars = shouldAnimateBars
    }
    
    var body: some View {
        content
    }
}

extension GroupChallengeComparisonView {
    private var content: some View {
        VStack(spacing: 0) {
            topSection
            chartView
        }
    }
    
    private var topSection: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            HStack {
                Text("그룹 챌린지 비교")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                
                Spacer()
            }
            
            HStack {
                Text(message)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey100.asColor)
                
                Spacer()
            }
        }
    }
    
    private var chartView: some View {
        HStack(spacing: SpacingHelper.xl.pixel) {
            VStack(spacing: 0) {
                GraphBarView(
                    count: 0,
                    percentage: indvScore,
                    style: .grey,
                    topTextIgnored: true,
                    shouldAnimate: shouldAnimateBars
                )
                .padding(.bottom, 8)
                
                Text("개인")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey200.asColor)
                    .padding(.bottom, 6)
                    
                ImageHelper.individualPeople
                    .asImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
            }
            
            VStack(spacing: 0) {
                GraphBarView(
                    count: 0,
                    percentage: groupScore,
                    style: .mainColor,
                    topTextIgnored: true,
                    shouldAnimate: shouldAnimateBars
                )
                
                Text("그룹")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey200.asColor)
                    .padding(.bottom, 8)
                
                ImageHelper.groupPeople
                    .asImage
                    .resizable()
                    .frame(height: 40)
                    .aspectRatio(56.05 / 40, contentMode: .fit)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2.8)
        .aspectRatio(contentMode: .fit)
    }
    
}

#if DEBUG
#Preview {
    GroupChallengeComparisonView(indvScore: 0.33333334, groupScore: 0, message: "Asdad")
        .background(GBColor.background1.asColor)
}
#endif
