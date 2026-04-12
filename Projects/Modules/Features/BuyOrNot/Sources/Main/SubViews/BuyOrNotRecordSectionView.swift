//
//  BuyOrNotRecordSectionView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 4/8/26.
//

import SwiftUI
import Utils
import Data
import FeatureCommon

struct BuyOrNotRecordSectionView: View {

    let currentUserList: [BuyOrNotCardViewEntity]
    let currentChatRoomList: [ChatRoomCardEntity]
    @Binding var currentRecordIdx: Int
    @Binding var currentRecordType: RecordType
    let isInitialChatLoading: Bool
    let groupOnlyMakeMeTrigger: Bool
    let safeAreaBottom: CGFloat
    let onRecordItemAppear: (Int) -> Void
    let onChatRoomItemAppear: (ChatRoomCardEntity) -> Void
    let onMoreTapped: (BuyOrNotCardViewEntity, Int) -> Void
    let onShowOnlySelfMakeRoomTapped: () -> Void
    let onChatRoomTapped: (ChatRoomCardEntity) -> Void
    let onEmptyAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GBSwitchButton(
                switchTitles: RecordType.allCases.map(\.title),
                selectedIndex: $currentRecordIdx,
                backGroundColor: GBColor.grey500.asColor,
                capsuleColor: GBColor.white.asColor,
                defaultTextColor: GBColor.grey300.asColor,
                selectedTextColor: GBColor.black.asColor
            )
            .padding(.horizontal, 4)
            .background(GBColor.grey500.asColor)
            .clipShape(Capsule())
            .frame(width: 247, height: 41)
            .onChange(of: currentRecordIdx) { newValue in
                currentRecordType = RecordType.allCases[newValue]
            }

            switch currentRecordType {
            case .writePost:
                if !currentUserList.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(currentUserList.enumerated()), id: \.element.id) { idx, item in
                                BuyOrNotRecordItemView(model: item) {
                                    onMoreTapped(item, idx)
                                }
                                .onAppear {
                                    onRecordItemAppear(idx)
                                }
                            }
                        }

                        Color.clear
                            .frame(height: safeAreaBottom)
                    }
                } else {
                    BuyOrNotEmptyStateView(action: onEmptyAction)
                }

            case .joinChat:
                showOnlySelfMakeRoomButton
                    .padding(.vertical, .sm)

                if isInitialChatLoading || !currentChatRoomList.isEmpty {
                    List {
                        if isInitialChatLoading {
                            ForEach(Array(loadingChatItems.enumerated()), id: \.offset) { index, item in
                                chatRoomRow(
                                    model: item,
                                    isLast: index == loadingChatItems.count - 1,
                                    isLoading: true
                                )
                                .resetRowStyle()
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(Array(currentChatRoomList.enumerated()), id: \.element.id) { index, item in
                                chatRoomRow(
                                    model: BuyOrNotChatCardViewEntity(chatRoomCard: item),
                                    isLast: index == currentChatRoomList.count - 1,
                                    isLoading: false
                                )
                                .asButton {
                                    onChatRoomTapped(item)
                                }
                                .resetRowStyle()
                                .listRowBackground(Color.clear)
                                .onAppear {
                                    onChatRoomItemAppear(item)
                                }
                            }
                        }
                        Color.clear
                            .frame(height: safeAreaBottom)
                            .resetRowStyle()
                            .listRowBackground(Color.clear)
                    }
                    .resetListStyle()
                    
                } else {
                    emptyChatRoomView
                }
            }
        }.background(GBColor.background1.asColor)
    }

    /// 본인이 만든 방만 보는 뷰
    private var showOnlySelfMakeRoomButton: some View {
        HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Image(uiImage: groupOnlyMakeMeTrigger ? ImageHelper.checked.image : ImageHelper.unChecked.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                    .padding(.trailing, 2)

                Text(TextHelper.groupChallengeTexts(.onlyMakeMeShow).text)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(groupOnlyMakeMeTrigger ? GBColor.white.asColor : GBColor.grey400.asColor)
            }
            .asButton {
                onShowOnlySelfMakeRoomTapped()
            }
        }
        .padding(.trailing, .md)
    }

    private func chatRoomRow(
        model: BuyOrNotChatCardViewEntity,
        isLast: Bool,
        isLoading: Bool
    ) -> some View {
        VStack(spacing: 0) {
            BuyOrNotChatRoomItemView(model: model)
                .skeletonEffect(isActive: isLoading)

            GBColor.grey600.asColor
                .frame(height: 1)
                .padding(.horizontal, .md)
                .opacity(isLast ? 0 : 1)
        }
        .padding(.horizontal, .sm)
    }

    private var emptyChatRoomView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            Text("참여한 토론방이 없어요")
                .font(FontHelper.body3.font)
                .foregroundStyle(GBColor.grey300.asColor)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var loadingChatItems: [BuyOrNotChatCardViewEntity] {
        Array(repeating: BuyOrNotChatCardViewEntity.loadingPlaceholder, count: 3)
    }
}

private extension BuyOrNotChatCardViewEntity {
    static var loadingPlaceholder: BuyOrNotChatCardViewEntity {
        BuyOrNotChatCardViewEntity(
            imageUrl: nil,
            productName: "로딩 중인 상품",
            price: "0원",
            writerName: "작성자",
            category: nil
        )
    }
}
