//
//  ChallengeGroupDetailView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 6/9/25.
//

import SwiftUI
import Data
import Utils
import FeatureCommon

public struct ChallengeGroupDetailView: View {
    
    @Environment(\.safeAreaInsets) private var safeArea
    @State private var currentOffset: CGFloat = 0
    
    @State private var bottomListModels: [ChallengeRankEntity] = [
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        ),
        .init(
            userID: UUID().uuidString,
            imageURL: "https://i.sstatic.net/GsDIl.jpg",
            name: "호랑이",
            priceText: "3,000,000원"
        )
    ]
    
    public var body: some View {
        contentView
            .onPreferenceChange(ScrollOffsetKey.self) { offsetY in
                currentOffset = offsetY
            }
            .background(GBColor.main.asColor)
    }
}

extension ChallengeGroupDetailView {
    
    private var contentView: some View {
        ZStack(alignment: .top) {
            
            GBColor.main.asColor
                .frame(height: calculateHeight())
                .zIndex(1)
                .offset(y: -5)
            
            ScrollView {
                VStack (spacing: 0) {
                    VStack (spacing: 0) {
                        ScrollViewOffsetPreference { offsetY in
                            currentOffset = offsetY
                        }
                        
                        ChallengeProfilePodiumView(challengers: [
                            .init(
                                userID: UUID().uuidString,
                                imageURL: "https://i.sstatic.nets/GsDIl.jpg",
                                name: "호랑이",
                                priceText: "3,000,000원"
                            ),
                            .init(
                                userID: UUID().uuidString,
                                imageURL: "https://i.sstatic.nets/GsDIl.jpg",
                                name: "호랑이",
                                priceText: "3,000,000원"
                            ),
                            .init(
                                userID: UUID().uuidString,
                                imageURL: "https://i.sstatic.nets/GsDIl.jpg",
                                name: "호랑이",
                                priceText: "3,000,000원"
                            )
                        ])
                        .padding(.horizontal, calcTopPodiumHorizontalPadding())
                    }
                    .padding(.top, 64)
                    .padding(.top, safeArea.top)
                    .background(GBColor.main.asColor)
                    .cornerRadiusCorners(40, corners: [.bottomLeft, .bottomRight])
                    .background(GBColor.background1.asColor)
                    
                    bottomListView
                        .padding(.vertical, SpacingHelper.md.pixel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GBColor.background1.asColor)
            .zIndex(0)
            
            navigationView
                .zIndex(2)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var navigationView: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Image(uiImage: ImageHelper.back.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asButton {

                        }
                    Spacer()
                }
                
                Text("챌린지 명")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                HStack(spacing: 0) {
                    Spacer()
                    Image(uiImage: ImageHelper.settingBtn.image)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .asButton {

                        }
                }
            }
            .frame(height: 64)
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.top, safeArea.top)
            .background {
                BlurView(style: .dark)
                    .opacity(calcNavOpacity())
            }
        }
    }
    
    private var bottomListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(bottomListModels.enumerated()), id: \.element.userID) { index, model in
                listElementView(entity: model, rank: index + 4)
                    .padding(.bottom, SpacingHelper.sm.pixel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SpacingHelper.md.pixel)
    }
    
    private func listElementView(entity: ChallengeRankEntity, rank: Int) -> some View {
        VStack {
            HStack(spacing: 0) {
                Text(String(rank))
                    .foregroundStyle(GBColor.grey200.asColor)
                    .font(FontHelper.h3.font)
                
                DownImageView(url: URL(string: entity.imageURL ?? ""), option: .mid)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
                    .padding(.leading, SpacingHelper.sm.pixel * 2 + 9)
                    .padding(.trailing, SpacingHelper.md.pixel)
                
                Text(entity.name)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
                
                Spacer()
                
                Text("+" + entity.priceText)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.main.asColor)
            }
            .padding(.vertical, SpacingHelper.sm.pixel)
            .padding(.horizontal, SpacingHelper.md.pixel + 10)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(GBColor.grey500.asColor)
            }
        }
    }
}

// MARK: UI Calc Logic
extension ChallengeGroupDetailView {
    private func calculateHeight() -> CGFloat {
        let topNavigationHeight: CGFloat = 64
        
        let calc = currentOffset - topNavigationHeight
        
        let result = max(0, min(calc, UIScreen.main.bounds.height))
        
        print(result)
        
        return result
    }
    
    private func calcTopPodiumHorizontalPadding() -> CGFloat {
        let maxOffset: CGFloat = safeArea.top
        let clampedOffset = min(max(-currentOffset + maxOffset, 0), maxOffset)
        let progress = clampedOffset / maxOffset
        let padding: CGFloat = 40
        
        let calc = padding * ( 1 - progress )
        print("Current -> ",currentOffset)
        print("->",calc)
        return calc
    }
    
    private func calcNavOpacity() -> CGFloat {
        let maxOffset: CGFloat = safeArea.top
        let clampedOffset = min(max(-currentOffset, 0), maxOffset)
        let progress = clampedOffset / maxOffset // 0.0 ~ 1.0 사이 값
        return progress
    }
}

#Preview {
    ChallengeGroupDetailView()
}
