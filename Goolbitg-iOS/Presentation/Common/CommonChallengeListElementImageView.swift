//
//  CommonChallengeListElementImageView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/28/25.
//

import SwiftUI

struct CommonChallengeListElementImageView: View {
    
    let model: ChallengeEntity
    
    var body: some View {
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
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 45)
            .saturation(0)
            .background(GBColor.grey500.asColor)
            .clipShape(Circle())
            
            /// Title And SubTitle
            VStack(spacing:0) {
                HStack {
                    Text(model.title)
                        .font(FontHelper.body3.font)
                        .foregroundStyle(GBColor.white.asColor)
                    Spacer()
                }
                if let subTitle = model.subTitle {
                    HStack {
                        Text(subTitle)
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                        Spacer()
                    }
                }
            }
            .padding(.leading, SpacingHelper.md.pixel)
            
            Image(uiImage: ImageHelper.right.image)
                .resizable()
                .frame(width: 7, height: 14)
                
        }
    }
}
