//
//  BuyOrNotTabView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import Utils
import Data
import FeatureCommon

struct BuyOrNotTabView: View {

    @Perception.Bindable var store: StoreOf<BuyOrNotTabViewFeature>

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var emptyList: [BuyOrNotCardViewEntity] = BuyOrNotCardViewEntity.dummy()
    @State private var tabMode: BuyOrNotTabInMode = .buyOrNot
    @State private var ifModifierOrDelete: BuyOrNotCardViewEntity?
    @State private var ifReportModelID: String?
    @State private var currentSelectedIdx: Int?

    var body: some View {
        WithPerceptionTracking {
            content
                .onChange(of: store.tabMode) { newValue in
                    withAnimation {
                        tabMode = newValue
                    }
                }
                .onChange(of: store.loading) { newValue in
                    LoadingEnvironment.shared.loading(newValue)
                }
                .popup(item: $store.errorAlert.sending(\.bindingAlert)) { item in
                    VStack(spacing: 0) {
                        Spacer()
                        GBAlertView(model: item) {
                            store.send(.bindingAlert(nil))
                        } okTouch: {
                            store.send(.viewEvent(.alertOkTapped(item: item)))
                        }
                        Spacer()
                    }
                } customize: {
                    $0
                        .type(.floater())
                        .animation(.easeInOut)
                        .appearFrom(.centerScale)
                        .displayMode(.sheet)
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .backgroundColor(Color.black.opacity(0.5))
                }
                .popup(item: $ifModifierOrDelete) { _ in
                    BuyOrNotModifierActionSheetView(
                        safeAreaBottom: safeAreaInsets.bottom,
                        onModify: performModifyAction,
                        onDelete: performDeleteAction,
                        onClose: closeModifierSheet
                    )
                } customize: {
                    $0
                        .type(.toast)
                        .displayMode(.sheet)
                        .closeOnTap(false)
                        .closeOnTapOutside(true)
                        .animation(.smooth)
                        .backgroundColor(Color.black.opacity(0.5))
                }
                .popup(item: $ifReportModelID) { item in
                    BuyOrNotModifyBottomSheetView { reason in
                        ifReportModelID = nil
                        store.send(.viewEvent(.reportButtonTapped(id: item, reason: reason)))
                    }
                } customize: {
                    $0
                        .type(.toast)
                        .displayMode(.sheet)
                        .closeOnTap(false)
                        .closeOnTapOutside(true)
                        .animation(.smooth)
                        .backgroundColor(Color.black.opacity(0.5))
                }
        }
    }
}

// MARK: - Content

private extension BuyOrNotTabView {

    var content: some View {
        VStack(spacing: 0) {
            BuyOrNotTabHeaderView(currentTab: store.tabMode) { mode in
                store.send(.bindingTabMode(mode))
            } onAddTapped: {
                store.send(.viewEvent(.addButtonTapped))
            }
            .padding(.top, SpacingHelper.xs.pixel)
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.bottom, SpacingHelper.sm.pixel)

            VStack(spacing: 0) {
                switch tabMode {
                case .buyOrNot:
                    if store.currentMode == .empty {
                        BuyOrNotEmptyStateView {
                            store.send(.viewEvent(.addButtonTapped))
                        }
                    } else {
                        buyOrNotView
                            .onAppear {
                                store.send(.viewCycle(.onAppear))
                            }
                    }

                case .records:
                    BuyOrNotRecordSectionView(
                        currentUserList: store.currentUserList,
                        currentChatRoomList: store.filteredChatRoomList,
                        currentRecordIdx: $store.currentRecordIndex.sending(\.bindingCurrentRecordIndex),
                        currentRecordType: $store.currentRecordType.sending(\.bindingCurrentRecordType),
                        isInitialChatLoading: store.isInitialChatLoading,
                        groupOnlyMakeMeTrigger: store.groupOnlyMakeMeTrigger,
                        safeAreaBottom: safeAreaInsets.bottom,
                        onRecordItemAppear: { idx in
                            store.send(.viewEvent(.moreUserList(index: idx)))
                        },
                        onChatRoomItemAppear: { item in
                            store.send(.viewEvent(.moreChatRoomList(item)))
                        },
                        onMoreTapped: { model, idx in
                            withAnimation {
                                ifModifierOrDelete = model
                                currentSelectedIdx = idx
                            }
                        },
                        onShowOnlySelfMakeRoomTapped: {
                            store.send(.viewEvent(.onlyMakeMeButtonTapped))
                        },
                        onChatRoomTapped: { item in
                            store.send(.viewEvent(.moveChatRoomTap(item)))
                        },
                        onEmptyAction: {
                            store.send(.viewEvent(.addButtonTapped))
                        }
                    )
                    .onAppear {
                        store.send(.viewCycle(.recordOnAppear))
                    }
                }
            }

            Spacer()
        }
        .background(GBColor.background1.asColor)
    }

    var buyOrNotView: some View {
        let screenHeight = UIScreen.main.bounds.height
        let safeHeight = safeAreaInsets.bottom + safeAreaInsets.top
        let cardViewHeight = (screenHeight - safeHeight) * 0.68

        return VStack(spacing: 0) {
            GeometryReader { proxy in
                WithPerceptionTracking {
                    switch store.currentMode {
                    case .load:
                        BuyOrNotCardView(
                            entity: emptyList.first!,
                            reportTab: {},
                            messageTab: {}
                        )
                        .padding(.horizontal, SpacingHelper.lg.pixel)
                        .padding(.top, SpacingHelper.lg.pixel)
                        .skeletonEffect()

                    case .empty:
                        EmptyView()

                    case .on:
                        BuyOrNotCardListView(
                            currentListEntity: $store.currentList.sending(\.bindingCurrentList),
                            currentIndex: $store.currentIndex.sending(\.bindingCurrentIndex),
                            size: proxy.size,
                            selectedEntity: { selected in
                                Logger.debug(selected)
                            },
                            reportEntity: { report in
                                Logger.debug(report)
                                ifReportModelID = report.id
                            },
                            messageTap: { message in
                                Logger.debug(message.id)
                                store.send(.viewEvent(.moveMessageTap(item: message)))
                            }
                        )
                    }
                }
            }
            .frame(height: cardViewHeight)
            .padding(.bottom, 24)

            BuyOrNotVoteView(model: store.currentList[safe: store.currentIndex]) {
                store.send(.viewEvent(.likeButtonTapped(store.currentList[safe: store.currentIndex], index: store.currentIndex)))
            } onDislike: {
                store.send(.viewEvent(.disLikeButtonTapped(store.currentList[safe: store.currentIndex], index: store.currentIndex)))
            }

            Color.clear
                .frame(height: safeAreaInsets.bottom)
        }
    }

    func performModifyAction() {
        guard let entity = ifModifierOrDelete,
              let selectedIDX = currentSelectedIdx else {
            closeModifierSheet()
            return
        }

        closeModifierSheet()

        Task {
            try? await Task.sleep(for: .seconds(0.7))
            store.send(.viewEvent(.modifierModel(entity, index: selectedIDX)))
        }
    }

    func performDeleteAction() {
        guard let entity = ifModifierOrDelete,
              let selectedIDX = currentSelectedIdx else {
            closeModifierSheet()
            return
        }

        closeModifierSheet()

        Task {
            try? await Task.sleep(for: .seconds(0.7))
            store.send(.viewEvent(.deleteModel(entity, index: selectedIDX)))
        }
    }

    func closeModifierSheet() {
        ifModifierOrDelete = nil
        currentSelectedIdx = nil
    }
}

#if DEBUG
#Preview {
    BuyOrNotTabView(store: Store(initialState: BuyOrNotTabViewFeature.State(), reducer: {
        BuyOrNotTabViewFeature()
    }))
}
#endif
