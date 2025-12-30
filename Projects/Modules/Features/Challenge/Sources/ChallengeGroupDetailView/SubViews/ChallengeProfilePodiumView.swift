//
//  ChallengeProfilePodiumView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 6/13/25.
//

import SwiftUI
import Data
import Utils

/// 상단 가장 높은 순위에서만 사용하여야 합니다. ( 3위까지 )
struct ChallengeProfilePodiumView: View {
    
    let challengers: [ChallengeRankEntity]
    
    @State private var animated: Bool = false
    
    init(challengers: [ChallengeRankEntity]) {
        self.challengers = challengers
    }
    
    var body: some View {
        contentView
            .onAppear {
                withAnimation(.smooth(duration: 0.7)) {
                    if !animated {
                        animated.toggle()
                    }
                }
            }
    }
}

extension ChallengeProfilePodiumView {
    private var contentView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            rankStackView(entity: challengers[safe: 1], rank: 2)
            rankStackView(entity: challengers[safe: 0], rank: 1)
            rankStackView(entity: challengers[safe: 2], rank: 3)
        }
        .offset(y: animated ? 0 : 300)
        .opacity(animated ? 1 : 0)
    }
    
    private func rankStackView(entity: ChallengeRankEntity?, rank: Int) -> some View {
        VStack(spacing: 4) {
            if let entity {
                VStack {
                    ChallengeGroupTopProfileView(
                        config: ChallengeGroupTopProfileViewConfig(
                            imageURL: entity.imageURL,
                            name: entity.name,
                            priceText: entity.priceText
                        )
                    )
                }
            } else {
                rankStackDummy()
            }
            
            ChallengePodiumView(rank: rank)
        }
    }
    
    private func rankStackDummy() -> some View {
        let entity = ChallengeRankEntity(
            modelID: UUID().uuidString,
            imageURL: nil,
            name: "",
            priceText: ""
        )
        
        return VStack {
            ChallengeGroupTopProfileView(
                config: ChallengeGroupTopProfileViewConfig(
                    imageURL: entity.imageURL,
                    name: entity.name,
                    priceText: entity.priceText
                )
            )
        }
    }
}

#if DEBUG
#Preview {
    ChallengeProfilePodiumView(challengers: [
        .init(
            modelID: UUID().uuidString,
            imageURL: "https://i.sstatic.nets/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            modelID: UUID().uuidString,
            imageURL: "https://i.sstatic.nets/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            modelID: UUID().uuidString,
            imageURL: "https://i.sstatic.nets/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        )
    ])
}
#endif


