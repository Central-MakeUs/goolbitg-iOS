//
//  GBChallengeBottomSheetView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI
import Utils

public struct GBChallengeBottomSheetView: View {
    
    public let title: String
    public let subTitle: String?
    public let imageURL: URL?
    public let bottomHashTag: [String]?
    public let buttonTitle: String
    
    public var onTabButton: () -> Void
    
    public var body: some View {
        content
            .background(GBColor.grey600.asColor)
            .cornerRadiusCorners(28, corners: [.topLeft, .topRight])
    }
}

extension GBChallengeBottomSheetView {
    
    private var content: some View {
        VStack(spacing: 0) {
            headView
                .frame(maxWidth: .infinity)
            middleContent
            
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
            
            challengeButton
                .padding(.bottom, 20)
        }
    }
    
    private var headView: some View {
        VStack( alignment: .center, spacing: 0) {
            Capsule()
                .foregroundStyle(GBColor.grey300.asColor)
                .frame(width: 32, height: 4)
                .padding(.all, SpacingHelper.md.pixel)
            Divider()
                .foregroundStyle(GBColor.grey300.asColor)
        }
    }
    
    private var middleContent: some View {
        VStack(alignment: .center, spacing: 0) {
            Group {
                if let url = imageURL {
                    DownImageView(
                        url: url,
                        option: .custom(CGSize(width: 160, height: 160)),
                        fallbackURL: nil,
                        fallBackImg: ImageHelper.appLogo.image
                    )
                } else {
                    Image(uiImage: ImageHelper.appLogo.image)
                        .resizable()
                        .saturation(0)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 160)
//            .background(GBColor.grey500.asColor)
            .clipShape(Circle())
            
            Text(title)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.grey50.asColor)
                .padding(.vertical, SpacingHelper.xs.pixel)
            
            if let hashTag = bottomHashTag {
                HStack(spacing: 0) {
                    ForEach(hashTag, id: \.self) { item in
                        Text(item)
                            .font(FontHelper.body5.font)
                            .foregroundStyle(GBColor.grey200.asColor)
                            .padding(.trailing, 1)
                    }
                }
            }
            if let subText = subTitle {
                Text(subText)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey200.asColor)
            }
        }
        .padding(.all, SpacingHelper.md.pixel)
    }
    
    private var challengeButton: some View {
        VStack (spacing: 0) {
            GBButtonV2(title: buttonTitle) {
                onTabButton()
            }
            .padding(.all, SpacingHelper.md.pixel)
        }
    }
}
