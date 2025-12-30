//
//  CategoryComparisonSectionView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/9/25.
//

import SwiftUI
import Utils
import Data

struct CategoryComparisonSectionView: View {
    
    let categoryInfo: CategoryCompareEntity
    
    var body: some View {
        content
    }
}

extension CategoryComparisonSectionView {
    private var content: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            topTextView
            
            chartView
                .padding(.horizontal, 20)
                .padding(.vertical, SpacingHelper.md.pixel)
        }
    }
    
    private var topTextView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            HStack {
                Text("카테고리별 비교")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                Spacer()
            }
            
            HStack {
                Text("\(categoryInfo.topCategory) 카테고리를 가장 많이 성공했어요!")
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
        }
    }
    
    private var chartView: some View {
        RadarChartView(items: categoryInfo.allCategories)
            .aspectRatio(1, contentMode: .fit)
    }
}

#if DEBUG
#Preview {
    CategoryComparisonSectionView(
        categoryInfo: CategoryCompareEntity(
            topCategory: "기타",
            allCategories: [
                .init(name: "식비", currentValue: 3, maxValue: 6),
                .init(name: "기타", currentValue: 4, maxValue: 4),
                .init(name: "생활비", currentValue: 5, maxValue: 7),
                .init(name: "쇼핑", currentValue: 1, maxValue: 4),
                .init(name: "교통비", currentValue: 4, maxValue: 7)
            ]
        )
    )
    .frame(maxWidth: .infinity)
    .background(GBColor.background1.asColor)
}
#endif
