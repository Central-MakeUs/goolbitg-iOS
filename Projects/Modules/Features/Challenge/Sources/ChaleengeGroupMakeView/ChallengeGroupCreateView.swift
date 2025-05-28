//
//  ChallengeGroupCreateView.swift
//  FeatureChallenge
//
//  Created by Jae hyung Kim on 5/28/25.
//

import SwiftUI
import ComposableArchitecture
import Utils
import FeatureCommon

struct ChallengeGroupCreateView: View {
    
    @Perception.Bindable var store: StoreOf<GroupChallengeCreateViewFeature>
    
    @State private var focusedField: Int? = nil
    @State private var hashTextFieldHeight: CGFloat = 0
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

// MARK: Top
extension ChallengeGroupCreateView {
    private var contentView: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal ,SpacingHelper.md.pixel)
            Spacer()
            scrollViewSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(TextHelper.groupChallengeTexts(.createGroupChallengeNavTitle).text)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        
                    }
                Spacer()
            }
        }
    }
}

// MARK: Section
extension ChallengeGroupCreateView {
    
    private var scrollViewSection: some View {
        ScrollViewReader { proxy in
            WithPerceptionTracking {
                ScrollView {
                    challengeNameSectionView
                        .padding(.top, 14)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                        .tag(1)
                    
                    challengePriceSectionView
                        .padding(.top, 50)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                    
                    hashTagsSectionView
                        .padding(.top, 50)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                    
                    maxPeopleSettingSectionView
                        .padding(.top, SpacingHelper.lg.pixel)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                    
                    secretRoomSettingSectionView
                        .padding(.top, SpacingHelper.lg.pixel)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                    
                    secretRoomPasswordSectionView
                        .padding(.top, SpacingHelper.lg.pixel)
                        .padding(.horizontal, SpacingHelper.md.pixel + SpacingHelper.sm.pixel)
                }
                .onChange(of: focusedField) { _ in
                    scrollToFocusedField(proxy)
                }
            }
        }
    }
    
    /// 챌린지 이름 색션
    private var challengeNameSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.groupChallengeTexts(.challengeName).text, required: true)
            
            DisablePasteTextField(
                configuration: commonDisablePasteTextFieldConfiguration(
                    placeholder: TextHelper.groupChallengeTexts(.challengeNamePlaceholder).text,
                    keyBoardType: .default,
                    secureTextEntry: false
                ),
                text: $store.challengeName.sending(\.inputChallengeNameText),
                onCommit: nil
            )
            .background(GBColor.grey600.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
        }
        .onTapGesture {
            focusedField = 1
        }
    }
    
    
    /// 챌린지 가격 섹션 뷰
    private var challengePriceSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.groupChallengeTexts(.challengePrice).text, required: true)
            
            ZStack (alignment: .leading) {
                DisablePasteTextField(
                    configuration: commonDisablePasteTextFieldConfiguration(
                        placeholder: TextHelper.groupChallengeTexts(.challengePricePlaceholder).text,
                        keyBoardType: .numberPad,
                        secureTextEntry: false,
                        ifLeadingEdge: 20
                    ),
                    text: $store.challengePrice.sending(\.inputChallengePriceText),
                    onCommit: nil
                )
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                if !store.challengePrice.isEmpty {
                    Text("₩")
                        .foregroundStyle(GBColor.white.asColor)
                        .padding(.leading, 17)
                }
            }
        }
        .onTapGesture {
            focusedField = 2
        }
    }
    
    /// HashTag 섹션
    private var hashTagsSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(
                text: TextHelper.groupChallengeTexts(.hashTag).text,
                required: true,
                subText: "최대 3개"
            )
            
            HStack(spacing: SpacingHelper.sm.pixel) {
                DisablePasteTextField(
                    configuration: commonDisablePasteTextFieldConfiguration(
                        placeholder: TextHelper.groupChallengeTexts(.hashTagPlaceholder).text,
                        keyBoardType: .numberPad,
                        secureTextEntry: false
                    ),
                    text: $store.hashTagText.sending(\.inputHashTagText),
                    onCommit: nil
                )
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                
                hashTagAddButton
            }
            .padding(.bottom, SpacingHelper.lg.pixel)
            
            if !store.hashTagList.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(store.hashTagList.enumerated()), id: \.element.self) { index, tag in
                            hashTagElementView(text: tag, index: index)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onTapGesture {
            focusedField = 3
        }
    }
    
    /// 해시태그 추가 버튼
    @ViewBuilder
    private var hashTagAddButton: some View {
        if store.hashTagText.isEmpty {
            Text("+추가")
                .font(FontHelper.btn3.font)
                .foregroundStyle(GBColor.disabledText.asColor)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .frame(maxHeight: .infinity)
                .background(GBColor.disabledBG.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.disabledText.asColor, lineWidth: 1)
                )
        }
        else {
            Text("+추가")
                .font(FontHelper.btn3.font)
                .foregroundStyle(GBColor.black.asColor)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .frame(maxHeight: .infinity)
                .background(GBColor.white.asColor)
            .asButton {
                store.send(.viewAction(.hashTagAddTapped))
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    
    /// 해시태그 자식뷰
    /// - Parameters:
    ///   - text: 해시태그
    ///   - index: 현재 인덱스
    /// - Returns: View
    private func hashTagElementView(text: String, index: Int) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.grey100.asColor)
                .padding(.trailing, SpacingHelper.xs.pixel)
                
            ImageHelper.xSmall
                .asImage
                .resizable()
                .frame(width: 16, height: 16)
                .asButton {
                    store.send(.viewAction(.deleteHashTagTapped(index: index)))
                }
        }
        .padding(.horizontal, SpacingHelper.sm.pixel)
        .padding(.vertical, SpacingHelper.xs.pixel)
        .background(GBColor.grey500.asColor)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(GBColor.grey400.asColor, lineWidth: 1)
        }
    }
    
    /// 최대 인원 설정 뷰
    private var maxPeopleSettingSectionView: some View {
        VStack(spacing:0) {
            HStack(spacing:0) {
                sectionTopTextView(
                    text: TextHelper.groupChallengeTexts(.maxPeopleSetting).text,
                    required: true,
                    subText: "최대 \(GroupChallengeCreateViewFeature.currentMaxCount)명"
                )
                
                AddOrRemoveNumberView(
                    currentLeadingButtonState: store.maxLeadingButtonState,
                    currentNumber: store.currentMaxCount,
                    currentTrailingButtonState: store.maxTrailingButtonState
                ) {
                    store.send(.viewAction(.maxLeadingButtonTapped))
                    
                } onTappedCurrentTrailingButtonState: {
                    store.send(.viewAction(.maxTrailingButtonTapped))
                }
            }
        }
    }
    
    /// 비밀방 여부 설정 뷰
    private var secretRoomSettingSectionView: some View {
        HStack {
            sectionTopTextView(
                text: TextHelper.groupChallengeTexts(.secretRoom).text,
                required: false
            )
            
            OnOffSwitchView(buttonState: $store.secretRoomState.sending(\.inputSecretRoomState))
        }
    }
    
    @ViewBuilder
    private var secretRoomPasswordSectionView: some View {
        if store.secretRoomState {
            VStack(spacing: 8) {
                sectionTopTextView(
                    text: TextHelper.groupChallengeTexts(.secretRoomPassword).text,
                    required: true
                )
                
                
                DisablePasteTextField(
                    configuration: commonDisablePasteTextFieldConfiguration(
                        placeholder: "비밀번호를 입력해주세요",
                        keyBoardType: .numberPad,
                        secureTextEntry: false
                    ),
                    text: $store.passwordText.sending(\.inputPasswordText),
                    onCommit: nil
                )
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
            }
        }
        else {
            EmptyView()
        }
    }
    
}

// MARK: COMMON
extension ChallengeGroupCreateView {
    
    private func sectionTopTextView(
        text: String,
        required: Bool,
        subText: String? = nil
    ) -> some View {
        HStack(spacing: 3) {
            Text(text)
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)
            if required {
                Text("*")
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.error.asColor)
            }
            if let subText {
                Text(subText)
                    .font(FontHelper.body5.font)
                    .foregroundStyle(GBColor.grey300.asColor)
            }
            Spacer()
        }
    }
    
    private func scrollToFocusedField(_ proxy: ScrollViewProxy) {
        guard let field = focusedField else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation {
                proxy.scrollTo(field, anchor: .top)
            }
        }
    }
    
    private func commonDisablePasteTextFieldConfiguration(
        placeholder: String,
        keyBoardType: UIKeyboardType,
        secureTextEntry: Bool,
        ifLeadingEdge: CGFloat? = nil
    ) -> DisablePasteTextFieldConfiguration {
        return DisablePasteTextFieldConfiguration(
            textColor: GBColor.white.asColor,
            placeholder: placeholder,
            placeholderColor: GBColor.grey500.asColor,
            edge: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            keyboardType: keyBoardType,
            isSecureTextEntry: secureTextEntry,
            ifLeadingEdge: ifLeadingEdge
        )
    }
}

#if DEBUG
#Preview {
    ChallengeGroupCreateView(
        store: Store(
            initialState: GroupChallengeCreateViewFeature.State(),
            reducer: { GroupChallengeCreateViewFeature() }
        )
    )
}
#endif
