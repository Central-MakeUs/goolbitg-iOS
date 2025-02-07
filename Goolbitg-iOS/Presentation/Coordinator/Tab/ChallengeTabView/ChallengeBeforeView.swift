//
//  ChallengeBeforeView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/8/25.
//

import SwiftUI

struct ChallengeBeforeView: View {
    let model: ChallengeEntity
    
    var body: some View {
        content
    }
}

extension ChallengeBeforeView {
    
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
            Group {
                if let caseOf = model.status {
                    switch caseOf {
                    case .success:
                        Text(model.status?.buttonTitle ?? "")
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.main.asColor)
                            .padding(.vertical, SpacingHelper.xs.pixel)
                            .padding(.horizontal, SpacingHelper.md.pixel)
                            .background(GBColor.main15.asColor)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    case .fail:
                        Text(model.status?.buttonTitle ?? "")
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey300.asColor)
                            .padding(.vertical, SpacingHelper.xs.pixel)
                            .padding(.horizontal, SpacingHelper.md.pixel)
                            .background(GBColor.white.asColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
