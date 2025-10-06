//
//  RecentChallengeMonthlyComparisonGraphView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/5/25.
//

import SwiftUI
import Utils

struct RecentChallengeMonthlyComparisonGraphView: View {
    
    let difference: Int
    let monthDataCount: [Int]
    
    var body: some View {
        content
    }
}

extension RecentChallengeMonthlyComparisonGraphView {
    private var content: some View {
        VStack(spacing: 0) {
            topSection
            graph
                .padding(.horizontal, UIScreen.main.bounds.width / 5.5)
                .aspectRatio(2, contentMode: .fit)
        }
    }
    
    private var topSection: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            HStack {
                Text("최근 챌린지 비교")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                Spacer()
            }
            
            HStack {
                Text("지난달보다 \(abs(difference))개의 챌린지를 \(difference > 0 ? "더" : "덜") 완료했어요!")
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey100.asColor)
                Spacer()
            }
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
        .padding(.top, SpacingHelper.md.pixel)
        .padding(.bottom, SpacingHelper.sm.pixel)
    }
    
    
    private var graph: some View {
        HStack(alignment: .bottom, spacing: SpacingHelper.xl.pixel) {
            
            VStack(spacing: 8) {
                GraphBarView(count: 5, percentage: 5 / 10, style: .grey)
                
                Text("지난달")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            
            VStack(spacing: 8) {
                
                GraphBarView(count: 8, percentage: 8 / 10, style: .mainColor)
                
                Text("이번달")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            VStack(spacing: 8) {
                GraphBarView(count: 10, percentage: 10 / 10, style: .dotStyleForRecommend)
                
                Text("지난달")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.white.asColor) 
            }
            
        }
        .padding(.vertical, SpacingHelper.md.pixel)
        
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
