//
//  AuthRequestView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/10/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct AuthRequestView: View {
    
    @Perception.Bindable var store: StoreOf<AuthRequestFeature>
    
    @State private var isShowDatePicker: Bool = false
    @State private var emptyFocus = false
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .ignoresSafeArea(.keyboard)
                .onTapGesture {
                    endTextEditing()
                    emptyFocus = false
                }
                .popup(isPresented: $isShowDatePicker) {
                    GBBottonSheetView {
                        AnyView(bottomSheetDateView)
                    }
                    .frame(maxWidth: .infinity)
                    .background(GBColor.grey600.asColor)
                    .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
                } customize: {
                    $0
                        .type(.toast)
                        .animation(.spring)
                        .closeOnTapOutside(true)
                        .closeOnTap(false)
                        .backgroundView {
                            Color.black.opacity(0.5)
                        }
                }
                .popup(isPresented: $store.showAgreeBottomSheet.sending(\.agreeBottomSheet)) {
                    GBBottonSheetView(
                        headerView: {
                            AnyView(bottomSheetAgreeHeaderView)
                        },
                        contentView: {
                            AnyView(bottomSheetAgreeListView)
                        }
                    )
                        .frame(maxWidth: .infinity)
                        .background(GBColor.grey600.asColor)
                        .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
                } customize: {
                    $0
                        .type(.toast)
                        .animation(.spring)
                        .closeOnTap(false)
                        .closeOnTapOutside(true)
                        .backgroundView {
                            Color.black.opacity(0.5)
                        }
                }
        }
    }
    
    private var bottomSheetDateView: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $store.birthDayDate.sending(\.selectedDate),
                in: store.maxCalendar,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .changeTextColor(GBColor.white.asColor)
            
            GBButtonV2(title: TextHelper.acceptTitle) {
                isShowDatePicker.toggle()
            }
            .padding(.all, 16)
        }
    }
    private var bottomSheetAgreeHeaderView: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(TextHelper.authRequestWellComeToGoolB)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            Text(TextHelper.authRequestAgree)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.grey200.asColor)
       }
        .padding(.bottom, 16)
    }
    private var bottomSheetAgreeListView: some View {
        VStack(alignment: .center, spacing: 0) {
            allAgreeButtonView
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.vertical, SpacingHelper.sm.pixel)
            agreeListView
            
            Divider()
                .frame(height: 1)
                .foregroundStyle(GBColor.grey400.asColor)
            
            GBButton(
                isActionButtonState: $store.agreeStartButtonState.sending(\.agreeStartButtonState),
                title: TextHelper.authStart) {
                    store.send(.viewEvent(.startButtonTapped))
                }
                .padding(.all, 16)
                .padding(.bottom, 2)
        }
    }
    
    private var allAgreeButtonView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: store.allAgreeButtonState ?  ImageHelper.checked.image : ImageHelper.unChecked.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(TextHelper.allAgreeText)
                    .padding(.leading, SpacingHelper.sm.pixel)
                    .font(FontHelper.body4.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.md.pixel)
            .padding(.vertical, 12)
        }
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
        }
        .asButton {
            store.send(.viewEvent(.allAgreeButtonTapped))
        }
    }
    
    private var agreeListView: some View {
        VStack(spacing: SpacingHelper.md.pixel) {
            ForEach(AgreeListCase.allCases, id: \.self) { item in
                agreeListElementView(caseOf: item)
                    .asButton {
                        store.send(.viewEvent(.agreeListButtonTapped(item)))
                    }
            }
        }
        .padding(.horizontal, SpacingHelper.lg.pixel)
        .padding(.vertical, 16)
    }
    
    private func agreeListElementView(caseOf: AgreeListCase) -> some View {
        let currentButtonState = store.agreeList.contains { $0 == caseOf }
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: currentButtonState ? ImageHelper.checked.image : ImageHelper.unChecked.image )
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(caseOf.title)
                    .padding(.leading, SpacingHelper.sm.pixel)
                    .font(FontHelper.body4.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                
                Spacer()
                if caseOf != .fourTeen {
                    Image(uiImage: ImageHelper.right.image)
                        .resizable()
                        .frame(width: 7, height: 14)
                        .onTapGesture {
                            store.send(.viewEvent(.agreeListRightButtonTapped(caseOf)))
                        }
                }
            }
        }
    }
}

// MARK: UI
extension AuthRequestView {
    private var contentView: some View {
        VStack {
            headerView
                .padding(.top, SpacingHelper.xxl.pixel / 2)
                .padding(.horizontal, 16)
                .padding(.bottom, SpacingHelper.xl.pixel)
                
            infoRequestView
                .padding(.bottom, 10)
            
            Spacer()
            
            startButtonView
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
        .onChange(of: emptyFocus) { _ in
            store.send(.viewEvent(.nickNameTextFieldEventEnd))
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Text(TextHelper.authRequestHeaderTitle)
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.white.asColor)
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack {
                Text(TextHelper.authRequestHeaderSub)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
        }
    }
    
    private var infoRequestView: some View {
        VStack(spacing: 0) {
            
            nickNameCheckView
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
    
            sectionBirthDayView
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
            
            genderView
                .padding(.horizontal, 16)
        }
    }
    
    private var nickNameCheckView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestNickNameTitle, required: true)
            
            HStack (spacing: 0) {
                DisablePasteTextField(
                    text: $store.nickName.sending(\.nickNameText),
                    isFocused: $emptyFocus,
                    placeholder: TextHelper.authRequestNickNamePlaceHolder,
                    placeholderColor: GBColor.grey400.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .default
                ) { // onCommit
                    endTextEditing()
                }
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                .padding(.trailing, 8)
                
                Group {
                    if store.isDuplicateButtonState {
                        VStack {
                            Text(TextHelper.authRequestDuplicatedCheck)
                                .font(FontHelper.btn3.font)
                                .foregroundStyle(GBColor.black.asColor)
                        }
                        .frame(width: 88, height: 48)
                        .background(GBColor.white.asColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .asButton {
                            store.send(.viewEvent(.duplicatedButtonTapped))
                            emptyFocus = false
                        }
                    } else {
                        VStack {
                            Text(TextHelper.authRequestDuplicatedCheck)
                                .font(FontHelper.btn3.font)
                                .foregroundStyle(GBColor.grey500.asColor)
                                .padding(16)
                        }
                        .frame(width: 88, height: 48)
                        .background(GBColor.grey600.asColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
            }
            
            if let placeholder = store.nickNameResult.placeholder {
                HStack (spacing:0) {
                    Text(placeholder)
                        .font(FontHelper.body2.font)
                        .foregroundStyle(store.nickNameResult == .active ? GBColor.main.asColor : GBColor.error.asColor)
                    Spacer()
                }
            } else {
                HStack (spacing:0) {
                    Text("XXXXXXXXXX")
                        .font(FontHelper.body2.font)
                    Spacer()
                }
                .opacity(0)
            }
        }
    }
    
    private var sectionBirthDayView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestBirthDayTitle, required: false)
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack {
                        switch store.state.birthDayShowTextState {
                        case .placeholder:
                            HStack {
                                Text(TextHelper.authRequestBirthDayPlaceHolder)
                                    .font(FontHelper.caption2.font)
                                    .foregroundStyle(GBColor.grey400.asColor)
                                    .padding(.horizontal, SpacingHelper.md.pixel)
                                Spacer()
                            }
                        case .show:
                            HStack {
                                Text(store.birthDayText ?? "")
                                    .padding(.horizontal, SpacingHelper.md.pixel)
                                    .font(FontHelper.caption2.font)
                                    .foregroundStyle(GBColor.white.asColor)
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                .asButton {
                    endTextEditing()
                    isShowDatePicker.toggle()
                    emptyFocus = false
                }
                .padding(.trailing, 8)
                Group {
                    if store.birthDayText != nil {
                        VStack {
                            Text("삭제")
                                .font(FontHelper.btn3.font)
                                .foregroundStyle(GBColor.black.asColor)
                        }
                        .frame(width: 88, height: 48)
                        .background(GBColor.white.asColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .asButton {
                            store.send(.viewEvent(.deleteDateString))
                        }
                    }
                    else {
                        VStack {
                            Text("삭제")
                                .font(FontHelper.btn3.font)
                                .foregroundStyle(GBColor.grey500.asColor)
                                .padding(16)
                        }
                        .frame(width: 88, height: 48)
                        .background(GBColor.grey600.asColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }
    
    private var genderView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestGenderTitle, required: false)
            HStack (spacing: 16) {
                VStack {
                    Text(TextHelper.authRequestGenderMale)
                        .font(FontHelper.btn3.font)
                        .foregroundStyle (
                            store.currentGender == .male ? GBColor.black.asColor : GBColor.grey200.asColor
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background {
                    if case .male = store.currentGender {
                        GBColor.white.asColor
                    } else {
                        GBColor.grey500.asColor
                    }
                }
                .clipShape(Capsule())
                .asButton {
                    store.send(.viewEvent(.maleTaped))
                    emptyFocus = false
                }
                
                VStack {
                    Text(TextHelper.authRequestGenderFemale)
                        .font(FontHelper.btn3.font)
                        .foregroundStyle(
                            store.currentGender == .female ? GBColor.black.asColor : GBColor.grey200.asColor
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background {
                    if case .female = store.currentGender {
                        GBColor.white.asColor
                    } else {
                        GBColor.grey500.asColor
                    }
                }
                .clipShape(Capsule())
                .asButton {
                    store.send(.viewEvent(.femaleTapped))
                    emptyFocus = false
                }
            }
        }
    }
    
    private func sectionTopTextView(text: String, required: Bool) -> some View {
        HStack(spacing: 3) {
            Text(text)
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)
            if required {
                Text("*")
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.error.asColor)
            }
            Spacer()
        }
    }
    
    private var startButtonView: some View {
        VStack {
            if store.isActionButtonState {
                GBButtonV2(title: TextHelper.agreeAndConditionStart) {
                    store.send(.viewEvent(.agreeStartButtonTapped))
                }
            }
        }
    }
}

#Preview {
    AuthRequestView(store: Store(initialState: AuthRequestFeature.State(), reducer: {
        AuthRequestFeature()
    }))
}
