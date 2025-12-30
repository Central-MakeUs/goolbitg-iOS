//
//  RecentChallengeWeeklyComparisonGraphView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/5/25.
//

import SwiftUI
import Utils
import Data

struct RecentChallengeWeeklyComparisonGraphView: View {
    
    let difference: Int
    let maxCount: Int
    let monthDataList: [RecentChallengeWeeklyEntity]
    
    var body: some View {
        content
    }
}

extension RecentChallengeWeeklyComparisonGraphView {
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
                Text(getTopTextMessage(difference: difference))
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
            
            ForEach(monthDataList, id: \.hashValue) { data in
                makeGraphBody(data: data)
            }
            
        }
        .padding(.vertical, SpacingHelper.md.pixel)
        
    }
    
    private func makeGraphBody(data: RecentChallengeWeeklyEntity) -> some View {
        VStack(spacing: 0) {
            GraphBarView(
                count: data.count,
                percentage: CGFloat(data.count) / CGFloat(maxCount),
                style: data.barStyle
            )
            
            Text(data.title)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.white.asColor)
        }
    }
    
    private func getTopTextMessage(difference: Int) -> String {
        var text: String = ""
        
        if difference == 0 {
            text = "지금 이대로 유지해도 좋아요!"
        } else {
            text = "지난부보다 \(abs(difference))개의 챌린지를 \(difference > 0 ? "더" : "덜") 완료했어요!"
        }
        return text
    }

}

#if DEBUG
#Preview {
    let max = RecentChallengeWeeklyEntity.mocks.max(by: { a, b in
        a.count < b.count
    })
    let min = RecentChallengeWeeklyEntity.mocks.min(by: { a, b in
        a.count < b.count
    })
    VStack {
        RecentChallengeWeeklyComparisonGraphView(
            difference: (min?.count ?? 0) - (max?.count ?? 0),
            maxCount: max?.count ?? 0,
            monthDataList: RecentChallengeWeeklyEntity.mocks
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(GBColor.background1.asColor)
}
#endif
