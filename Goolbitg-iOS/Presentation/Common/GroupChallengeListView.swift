//
//  GroupChallengeListView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/14/25.
//

import SwiftUI

struct GroupChallengeListView: View {

    let entity: GroupChallengeListElementEntity
    
    var body: some View {
        contentView
    }
}

extension GroupChallengeListView {
    
    private var contentView: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                titleSectionView
                    .padding(.bottom, 4)
                peopleAndHashTagSectionView
            }
            
            ImageHelper.right.asImage
                .resizable()
                .frame(width: 7, height: 14)
        }
    }
    
    private var titleSectionView: some View {
        HStack(spacing: 0) {
            Text(entity.groupTitle)
                .asFont(.body2)
                .padding(.trailing, 4)
            
            ImageHelper.lock.asImage
                .resizable()
                .frame(width: 20, height: 20)
            
            Spacer()
        }
    }
    
    private var peopleAndHashTagSectionView: some View {
        HStack(spacing: 0) {
            ImageHelper.group.asImage
                .resizable()
                .frame(width: 12, height: 12)
                
            Text(entity.currentUserCount)
                .asFont(.btn4)
                .foregroundStyle(GBColor.main.asColor)
                .padding(.trailing, 4)
            
            Circle()
                .foregroundStyle(GBColor.grey400.asColor)
                .frame(width: 2, height: 2)
                .padding(.trailing, 4)
            
            ForEach(entity.hashTags, id: \.self) { item in
                Text("#" + item)
                    .asFont(.body4)
                    .padding(.trailing, 4)
                    .foregroundStyle(GBColor.grey300.asColor)
            }
            
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    GroupChallengeListView(entity: .init(
        groupID: "ASDASD",
        groupTitle: "거지방 챌린지",
        currentUserCount: "3/6",
        hashTags: [
            "배달줄이기",
            "배민",
            "야식"
        ]
    ))
}
#endif
