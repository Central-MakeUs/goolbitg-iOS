//
//  ChallengeCategoryTextView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 10/5/25.
//

import SwiftUI
import Utils

struct ChallengeCategoryTextView: View {
    
    let category: String
    
    var body: some View {
        content
    }
}

extension ChallengeCategoryTextView {
    
    private var content: some View {
        VStack {
            Text(category)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.horizontal, SpacingHelper.sm.pixel)
                .padding(.vertical, 2)
        }
        .background(GBColor.white.asColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#if DEBUG
#Preview {
    VStack {
        ChallengeCategoryTextView(category: "식비")
    }
    .frame(maxWidth: .infinity)
    .frame(height: 50)
    .background(GBColor.background1.asColor)
}
#endif
