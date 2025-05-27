//
//  ParticipatingGroupChallengeEmptyView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/27/25.
//

import SwiftUI
import Utils
import FeatureCommon

struct ParticipatingGroupChallengeEmptyView: View {
    
    let onTappedButton: () -> Void
    
    init(onTappedButton: @escaping () -> Void) {
        self.onTappedButton = onTappedButton
    }
    
    var body: some View {
        contentView
    }
}

extension ParticipatingGroupChallengeEmptyView {
    
    private var contentView: some View {
        VStack(spacing: 0) {
            ImageHelper.pushNull
                .asImage
                .resizable()
                .frame(width: 160, height: 160)
            
            Text(TextHelper.groupChallengeTexts(.emptyParticipatingRoom).text)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.grey300.asColor)
                .padding(.bottom, 24)
            
            buttonView
        }
    }
    
    private var buttonView: some View {
        VStack(spacing: 0) {
            Text(TextHelper.groupChallengeTexts(.emptyParticipatingRoomButtonText).text)
                .font(FontHelper.btn2.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.horizontal, SpacingHelper.lg.pixel)
                .padding(.vertical, 16)
                .background {
                    Rectangle()
                        .fill(
                            GBGradientColor.mainGradient.shape
                        )
                }
                .clipShape(Capsule())
        }
        .asButton {
            onTappedButton()
        }
    }
}

#if DEBUG
#Preview {
    ParticipatingGroupChallengeEmptyView {
        
    }
    .background(GBColor.grey600.asColor)
}
#endif
