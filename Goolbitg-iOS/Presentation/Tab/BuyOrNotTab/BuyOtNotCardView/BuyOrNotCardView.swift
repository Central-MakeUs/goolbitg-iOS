//
//  BuyOrNotCardView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI

struct BuyOrNotCardView: View {
    
    let entity: BuyOrNotCardViewEntity
    
    var reportTab: () -> Void
    
    var body: some View {
        content
    }
}

extension BuyOrNotCardView {
    var content: some View {
        VStack(spacing: 0) {
            
            reportSectionView
                .padding(.top, SpacingHelper.md.pixel)
                .padding(.horizontal, SpacingHelper.lg.pixel)
            
            imageView
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.top, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.md.pixel)
            
            titleSectionView
                .padding(.horizontal, SpacingHelper.lg.pixel)
            
            likeOrBadSectionView
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.bottom, SpacingHelper.lg.pixel)
            
        }
        .background(GBColor.white.asColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                
        }
    }
    
    private var reportSectionView: some View {
        HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 9) {
                Image(.alertTriangle)
                
                Text("신고하기")
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                    
            }
            .asButton {
                reportTab()
            }
        }
    }
    
    private var imageView: some View {
        DownImageView(
            url: entity.imageUrl,
            option: .max,
            fallbackURL: nil,
            fallBackImg: .loginAppLogo
        )
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var titleSectionView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entity.itemName)
                    .font(FontHelper.body4.font)
                    .padding(.bottom, SpacingHelper.xs.pixel)
                
                Text(entity.priceString)
                    .font(FontHelper.h3.font)
                    .padding(.bottom, SpacingHelper.md.pixel)
                
                GBColor.white.asColor
                    .opacity(0.1)
                    .frame(height: 1)
                    .padding(.bottom, SpacingHelper.md.pixel)
            }
            Spacer()
        }
    }
    
    private var likeOrBadSectionView: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: SpacingHelper.xs.pixel) {
                ImageHelper.likeHand.asImage
                    .resizable()
                    .frame(width: 12, height: 12)
                    
                Text(entity.goodReason)
                    .font(FontHelper.body4.font)
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.sm.pixel)
            
            HStack(spacing: SpacingHelper.xs.pixel) {
                ImageHelper.bad.asImage
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Text(entity.badReason)
                    .font(FontHelper.body4.font)
                
                Spacer()
            }
        }
    }
}

#if DEBUG
#Preview {
    BuyOrNotCardView(entity: BuyOrNotCardViewEntity(
        id: "asd",
        userID: "ASDASDA",
        imageUrl: URL(string: "https://health.chosun.com/site/data/img_dir/2024/04/23/2024042302394_0.jpg"),
        itemName: "나이키 ACG 써마핏 ADV 루나 레이크 패딩 BC1220",
        priceString: "70,000원",
        goodReason: "누구나 좋아하는 강아지",
        badReason: "누구나 싫어하는 강아지",
        goodVoteCount: "99",
        badVoteCount: "1"
    ),
        reportTab: {
            
        }
    )
}
#endif
