//
//  BuyOrNotVoteView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import Data

struct BuyOrNotVoteView: View {

    let model: BuyOrNotCardViewEntity?
    let onLike: () -> Void
    let onDislike: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            voteButton(
                image: ImageHelper.good.asImage,
                iconOffset: CGSize(width: 3, height: -2),
                countText: model?.goodVoteCount ?? "??",
                action: onLike
            )

            voteButton(
                image: ImageHelper.bad.asImage,
                iconOffset: CGSize(width: -3, height: 2),
                countText: model?.badVoteCount ?? "??",
                action: onDislike
            )
        }
    }
}

private extension BuyOrNotVoteView {

    func voteButton(
        image: Image,
        iconOffset: CGSize,
        countText: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            Circle()
                .frame(width: 64, height: 64)
                .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                .overlay {
                    image
                        .resizable()
                        .frame(width: 39, height: 35.7)
                        .offset(x: iconOffset.width, y: iconOffset.height)
                }
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(GBColor.white.asColor.opacity(0.1))
                }

            Text(countText)
                .foregroundStyle(GBColor.grey400.asColor)
                .font(FontHelper.caption2.font)
        }
        .asButton {
            action()
        }
    }
}
