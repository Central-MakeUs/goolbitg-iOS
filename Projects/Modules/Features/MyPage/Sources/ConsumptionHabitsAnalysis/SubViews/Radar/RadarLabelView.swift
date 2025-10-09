//
//  RadarLabelView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/8/25.
//

import SwiftUI
import Utils

// MARK: - 라벨 뷰
struct RadarLabel: View {
    /// 항목 이름
    let name: String
    /// 현재 값
    let current: String
    /// 최댓 값
    let maximum: String
    /// 하이라이트 여부
    let highlight: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.grey200.asColor)
            
            HStack(spacing: 0) {
                Text(current)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(!highlight ? .white : GBColor.main.asColor)
                
                Text("/")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                
                Text(maximum)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey400.asColor)
            }
        }
    }
}
