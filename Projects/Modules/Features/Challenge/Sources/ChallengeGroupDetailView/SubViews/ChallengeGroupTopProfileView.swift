//
//  ChallengeGroupTopProfileView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 6/9/25.
//

import SwiftUI
import FeatureCommon
import Utils

struct ChallengeGroupTopProfileViewConfig {
    let imageURL: String?
    let name: String
    let priceText: String
}

struct ChallengeGroupTopProfileView: View {
    
    let config: ChallengeGroupTopProfileViewConfig
    
    init(config: ChallengeGroupTopProfileViewConfig) {
        self.config = config
    }
    
    var body: some View {
        VStack(spacing: 6) {
            DownImageView(
                url: URL(string: config.imageURL ?? ""),
                option: .mid,
                fallBackImg: ImageHelper.pushChallenge.image,
                fallBackGrey: false
            )
            .aspectRatio(contentMode: .fill)
            .frame(width: 54, height: 54)
            .background(GBColor.main.asColor)
            .clipShape(Circle())
            
            Text(config.name)
                .font(FontHelper.body3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            VStack {
                Text(config.priceText)
                    .font(FontHelper.caption3.font)
                    .foregroundStyle(GBColor.white.asColor)
                    .padding(.horizontal, SpacingHelper.sm.pixel)
                    .padding(.vertical, SpacingHelper.sm.pixel - 2)
                    .background(GBColor.white.asColor.opacity(0.3))
                    .clipShape(Capsule())
            }
            .layoutPriority(100)
        }
    }
}

#if DEBUG
#Preview {
    ChallengeGroupTopProfileView(
        config: ChallengeGroupTopProfileViewConfig(
            imageURL: "https://i.sstatic.nets/GsDIl.jpg",
            name: "호랑이",
            priceText: "850,000원"
        )
    )
    .background(GBColor.main.asColor)
}
#endif
