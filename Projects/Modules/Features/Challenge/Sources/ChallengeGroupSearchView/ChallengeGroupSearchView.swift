//
//  ChallengeGroupSearchView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/30/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import Utils
import FeatureCommon

struct ChallengeGroupSearchView: View {
    
    @State private var searchBarFocus: Bool = false
    @State private var searchBarBigTrigger: Bool = false
    
    @Perception.Bindable var store: StoreOf<ChallengeGroupSearchViewFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .background(GBColor.background1.asColor)
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .popup(item: $store.selectedRoomPopupComponent.sending(\.selectedRoomPopupComponentBinding)) { model in
                    ParticipationAlertView(
                        components: model,
                        textBinding: $store.popupPasswordText.sending(\.popupPasswordTextBinding)
                    ) {
                        store.send(.viewEvent(.popUpCancel))
                    } onJoin: {
                        store.send(.viewEvent(.popUpJoin))
                    }
                } customize: {
                    $0
                        .animation(.easeInOut)
                        .type(.default)
                        .displayMode(.sheet)
                        .appearFrom(.centerScale)
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .backgroundColor(Color.black.opacity(0.5))
                }
                .popup(item: $store.errorPopupComponent.sending(\.errorPopupComponentBinding)) { model in
                    GBAlertView(model: model) {} okTouch: {}
                } customize: {
                    $0
                        .animation(.easeInOut)
                        .type(.default)
                        .displayMode(.window)
                        .appearFrom(.none)
                        .closeOnTap(true)
                        .backgroundColor(Color.black.opacity(0.5))
                }

        }
    }
}

extension ChallengeGroupSearchView {
    private var contentView: some View {
        VStack {
            navigationView
                .padding(.top, 12)
                .padding(.horizontal, 16)
            
            searchResultTopSection
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .padding(.bottom, SpacingHelper.md.pixel)
            
            ScrollView {
                searchResultListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var navigationView: some View {
        HStack(spacing: 4) {
            
            if !searchBarBigTrigger {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.backButtonTapped))
                    }
            }
            HStack(spacing: 0) {
                DisablePasteTextField(
                    configuration: DisablePasteTextFieldConfiguration(
                        textColor: GBColor.white.asColor,
                        placeholder: TextHelper.groupChallengeTexts(
                            .findGroupChallengePlaceholder
                        ).text,
                        placeholderColor: GBColor.grey300.asColor,
                        edge: UIEdgeInsets(
                            top: 12,
                            left: SpacingHelper.md.pixel,
                            bottom: 12,
                            right: 4
                        ),
                        keyboardType: .default,
                        isSecureTextEntry: false
                    ),
                    text: $store.searchText.sending(\.searchTextBinding),
                    isFocused: $searchBarFocus,
                    onCommit: {
                        searchBarFocus = false
                    }
                )
                .fixedSize(horizontal: false, vertical: true)
                
                Image(systemName: "magnifyingglass")
                    .padding(.trailing, SpacingHelper.md.pixel)
                    .foregroundStyle(GBColor.white.asColor)
            }
            .background(GBColor.grey600.asColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .onChange(of: searchBarFocus) { newValue in
                withAnimation {
                    print(newValue)
                    searchBarBigTrigger = newValue
                }
            }
        }
    }
}

extension ChallengeGroupSearchView {
    var searchResultTopSection: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("검색 결과")
                .foregroundStyle(GBColor.white.asColor)
                .font(FontHelper.h3.font)
                .padding(.trailing, 8)
            Text("총 \(store.searchItemCount)건")
                .font(FontHelper.body4.font)
                .foregroundStyle(GBColor.grey300.asColor)
            Spacer()
        }
    }
    
    var searchResultListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(store.listItems.enumerated()), id: \.element.self) { index, item in
                VStack(spacing: 0) {
                    ParticipatingChallengeGroupElementView(entity: item)
                        .padding(.horizontal, SpacingHelper.lg.pixel)
                    
                    VStack(spacing:0) {
                        GBColor.grey600.asColor
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(.horizontal, SpacingHelper.lg.pixel)
                    .opacity(index != store.listItems.count - 1 ? 1 : 0)
                }
                .asButton {
                    store.send(.viewEvent(.tappedItem(item)))
                }
                .onAppear {
                    if !store.apiLoadTrigger && index > store.listItems.count - 3 && store.onAppearTrigger {
                        store.send(.viewEvent(.moreItem))
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    ChallengeGroupSearchView(store: Store(initialState: ChallengeGroupSearchViewFeature.State(), reducer: {
        ChallengeGroupSearchViewFeature()
    }))
}
#endif
