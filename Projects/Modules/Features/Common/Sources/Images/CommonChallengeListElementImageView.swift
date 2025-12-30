//
//  CommonChallengeListElementImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI
import Data
import Utils

public struct CommonChallengeListElementImageView: View {
    
    public let model: ChallengeEntity
    public let next: Bool
    
    public init(model: ChallengeEntity, next: Bool) {
        self.model = model
        self.next = next
    }
    
    public var body: some View {
        content
    }
}

extension CommonChallengeListElementImageView {
    
    private var content: some View {
        HStack(spacing:0){
            /// Image
            Group {
                if let url = model.imageUrl {
                    DownImageView(url: url, option: .min, fallbackURL: nil, fallBackImg: ImageHelper.appLogo.image)
                } else {
                    Image(uiImage: ImageHelper.appLogo.image)
                        .resizable()
                        .saturation(0)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 45)
            .background(GBColor.grey500.asColor)
            .clipShape(Circle())
            
            /// Title And SubTitle
            VStack(spacing:0) {
                HStack {
                    Text(model.title)
                        .multilineTextAlignment(.leading)
                        .font(FontHelper.body3.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Spacer()
                }
                if let subTitle = model.subTitle {
                    HStack {
                        Text(subTitle)
                            .multilineTextAlignment(.leading)
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                        Spacer()
                    }
                }
            }
            .padding(.leading, SpacingHelper.md.pixel)
            
            if next != true {
                Image(uiImage: ImageHelper.right.image)
                    .resizable()
                    .frame(width: 7, height: 14)
            }
        }
    }
}
