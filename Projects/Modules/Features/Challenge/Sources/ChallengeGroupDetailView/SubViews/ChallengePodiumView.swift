//
//  ChallengePodiumView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 6/13/25.
//

import SwiftUI
import Utils

struct ChallengePodiumView: View {
    
    let rank: Int
    
    init(rank: Int) {
        self.rank = rank
    }
    
    var body: some View {
        contentView
    }
}

extension ChallengePodiumView {
    private var contentView: some View {
        VStack(spacing: 0) {
            topView
            bottomView
        }
    }
    
    private var topView: some View {
        VStack {
            GBColor.white.asColor
        }
        .frame(height: 10)
        .opacity(calcRankOpacity(rank)+0.14)
        .cornerRadiusCorners(6, corners: [.topLeft, .topRight])
    }
    
    private var bottomView: some View {
        ZStack(alignment: .top) {
            GBColor.white.asColor
                .opacity(calcRankOpacity(rank))
            
            if rank == 1 {
                ImageHelper.appLogoEX.asImage
                    .padding(.top, 14)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: calcRankHeight(rank))
    }
    
    private func calcRankOpacity(_ rank: Int) -> Double {
        switch rank {
        case 1:
            return 0.6
        case 2:
            return 0.5
        default:
            return 0.4
        }
    }
    
    private func calcRankHeight(_ rank: Int) -> CGFloat {
        switch rank {
        case 1:
            return 91
        case 2:
            return 64
        default:
            return 46
        }
    }
}

#if DEBUG
#Preview {
    ChallengePodiumView(rank: 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.main.asColor)
}
#endif
