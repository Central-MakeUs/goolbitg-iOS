//
//  ParticipatingChallengeGroupElementView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/27/25.
//

import SwiftUI
import Data
import Utils

struct ParticipatingChallengeGroupElementView: View {
    
    private let entity: ParticipatingGroupChallengeListEntity
    
    init(entity: ParticipatingGroupChallengeListEntity) {
        self.entity = entity
    }
    
    var body: some View {
        contentView
    }
}

// MARK: UI
extension ParticipatingChallengeGroupElementView {
    
    private var contentView: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                
                topSectionView
                
                bottomSectionView
                    .padding(.leading, 3)
            }
            
            ImageHelper.right.asImage
                .resizable()
                .frame(width: 9, height: 15)
        }
        .padding(.vertical, SpacingHelper.md.pixel)
        .padding(.horizontal, SpacingHelper.sm.pixel)
    }
    
    private var topSectionView: some View {
        HStack(spacing: 0) {
            Text(entity.title)
                .font(FontHelper.body2.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(SpacingHelper.xs.pixel)
            
            if entity.isSecret {
                ImageHelper.secretRoomLogo
                    .asImage
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            Spacer()
        }
    }
    
    private var bottomSectionView: some View {
        HStack(alignment: .center, spacing: 0) {
            ImageHelper.group
                .asImage
                .resizable()
                .frame(width: 12, height: 12)
            
            Text(entity.totalWithParticipatingPeopleCount)
                .font(FontHelper.btn4.font)
                .foregroundStyle(GBColor.main.asColor)
            
            Text("·")
                .font(FontHelper.btn4.font)
                .foregroundStyle(GBColor.grey400.asColor)
                .padding(.horizontal, 4)
            
            hashTagsView(hashTags: entity.hashTags)
            
            Spacer()
        }
    }
    
    private func hashTagsView(hashTags: [String]) -> some View {
        let oneLine = hashTags.joined(separator: " ")
        
        return HStack(spacing: 0) {
            Text(oneLine)
                .foregroundStyle(GBColor.grey300.asColor)
                .font(FontHelper.body4.font)
                .lineLimit(1)
        }
    }
}

#if DEBUG
#Preview {
    ParticipatingChallengeGroupElementView(
        entity: .init(
            id: UUID().hashValue,
            ownerId: UUID().uuidString,
            title: "거지방챌린지",
            totalWithParticipatingPeopleCount: "3/6",
            hashTags: ["배달줄이기", "배민", "야식", "배민1", "야식2", "배민3", "야식3"], reward: "5,000원",
            isSecret: false
        )
    )
    .background(.black)
}
#endif
