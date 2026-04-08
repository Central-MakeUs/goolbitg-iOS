//
//  BuyOrNotChatRoomItemView.swift
//  FeatureBuyOrNot
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import Data
import FeatureCommon

struct BuyOrNotChatRoomItemView: View {
    
    let model: BuyOrNotChatCardViewEntity
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                DownImageView(url: model.imageUrl, option: .min)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(GBColor.grey500.asColor)
                    }
                    .padding(.trailing, SpacingHelper.md.pixel)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        // API 카테고리 추가시 적용
                        
                        
                        Text(model.productName)
                            .font(FontHelper.body3.font)
                            .foregroundStyle(GBColor.white.asColor)
                            .padding(.bottom, SpacingHelper.xs.pixel)
                        Spacer()
                    }

                    HStack {
                        Text(model.price)
                            .font(FontHelper.body4.font)
                            .foregroundStyle(GBColor.white.asColor)
                        Spacer()
                    }

                    Spacer()

                    HStack(spacing: .gb(.xs)) {
                       Text("작성자")
                             .font(FontHelper.body5.font)
                             .foregroundStyle(GBColor.grey300.asColor)
                        
                        Text(model.writerName)
                             .font(FontHelper.body5.font)
                             .foregroundStyle(GBColor.grey300.asColor)
                    }
                }
                .padding(.vertical, SpacingHelper.xs.pixel)

                VStack {
                    Spacer()
                    ImageHelper.right.asImage
                        .resizable()
                        .frame(width: 7, height: 14)
                        .foregroundStyle(GBColor.grey400.asColor)
                        .padding(.trailing, .sm)
                    Spacer()
                }
                .padding(.vertical, SpacingHelper.xs.pixel)
            }
            .padding(.vertical, SpacingHelper.md.pixel)
        }
        .padding(.horizontal, SpacingHelper.md.pixel)
        .frame(height: 112)
    }
}
