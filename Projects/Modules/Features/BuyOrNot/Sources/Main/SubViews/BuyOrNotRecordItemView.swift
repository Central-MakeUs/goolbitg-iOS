//
//  BuyOrNotRecordItemView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import Data
import FeatureCommon

struct BuyOrNotRecordItemView: View {

    let model: BuyOrNotCardViewEntity
    let onMoreTapped: () -> Void

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
                        Text(model.itemName)
                            .font(FontHelper.body3.font)
                            .foregroundStyle(GBColor.white.asColor)
                            .padding(.bottom, SpacingHelper.xs.pixel)
                        Spacer()
                    }

                    HStack {
                        Text(model.priceString)
                            .font(FontHelper.body4.font)
                            .foregroundStyle(GBColor.white.asColor)
                        Spacer()
                    }

                    Spacer()

                    HStack(spacing: 0) {
                        ImageHelper.miniLikeHand
                            .asImage
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(voteColor(target: .good))
                            .padding(.trailing, 4)

                        Text(model.goodVoteCount)
                            .font(FontHelper.body5.font)
                            .foregroundColor(voteColor(target: .good))
                            .padding(.trailing, SpacingHelper.sm.pixel)

                        ImageHelper.miniUnlikeHand
                            .asImage
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(voteColor(target: .bad))
                            .padding(.trailing, 4)

                        Text(model.badVoteCount)
                            .font(FontHelper.body5.font)
                            .foregroundColor(voteColor(target: .bad))
                    }
                }
                .padding(.vertical, SpacingHelper.xs.pixel)

                VStack {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 18, height: 3)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(GBColor.white.asColor)
                        .padding(.trailing, SpacingHelper.sm.pixel)
                        .frame(width: 32)
                        .asButton {
                            onMoreTapped()
                        }
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

private extension BuyOrNotRecordItemView {

    func voteColor(target: GoodOrBadOrNot) -> Color {
        model.goodMoreOrBadMore == target ? GBColor.main.asColor : GBColor.grey300.asColor
    }
}
