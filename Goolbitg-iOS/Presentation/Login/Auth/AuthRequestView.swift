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
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .onTapGesture {
                    endTextEditing()
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
        VStack(spacing: 30) {
            
            nickNameCheckView
                .padding(.horizontal, 16)
            
            sectionBirthDayView
                .padding(.horizontal, 16)
            
            genderView
                .padding(.horizontal, 16)
        }
    }
    
    private var nickNameCheckView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestNickNameTitle, required: true)
            
            HStack (spacing: 0) {
                PlaceholderTextField(
                    text: $store.nickName.sending(\.nickNameText),
                    placeholder: TextHelper.authRequestNickNamePlaceHolder,
                    placeholderColor: GBColor.grey400.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18)
                ) { // onCommit
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                .padding(.trailing, 16)
                
                VStack {
                    Text(TextHelper.authRequestDuplicatedCheck)
                        .font(FontHelper.btn2.font)
                        .foregroundStyle(GBColor.black.asColor)
                        .padding(16)
                }
                .background(GBColor.white.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .asButton {
                    
                }
            }
        }
    }
    
    private var sectionBirthDayView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestBirthDayTitle, required: true)
            
            HStack {
                DisablePasteTextField(
                    text: $store.birthDayYear.sending(\.yearText),
                    isFocused: $store.isYearFocused.sending(\.yearFocused),
                    placeholder: TextHelper.authRequestBirthDayPlaceHolderYear,
                    placeholderColor: GBColor.grey400.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad
                ) { // onCommit
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                
                DisablePasteTextField(
                    text: $store.birthDayMonth.sending(\.monthText),
                    isFocused: $store.isMonthFocused.sending(\.monthFocused),
                    placeholder: TextHelper.authRequestBirthDayPlaceHolderMonth,
                    placeholderColor: GBColor.grey400.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad
                ) { // onCommit
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                
                DisablePasteTextField(
                    text: $store.birthDayDay.sending(\.dayText),
                    isFocused: $store.isDayFocused.sending(\.dayFocused),
                    placeholder: TextHelper.authRequestBirthDayPlaceHolderDay,
                    placeholderColor: GBColor.grey400.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad
                ) { // onCommit
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
            }
            
        }
    }
    
    private var genderView: some View {
        VStack {
            sectionTopTextView(text: TextHelper.authRequestGenderTitle, required: true)
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
            if !store.isActionButtonState {
                HStack {
                    Text(TextHelper.authStart)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(GBColor.grey500.asColor)
                .font(FontHelper.btn1.font)
                .foregroundStyle(GBColor.grey400.asColor)
                .clipShape(Capsule())
            } else {
                HStack {
                    Text(TextHelper.authStart)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background {
                    Rectangle()
                        .fill(
                            .linearGradient(colors: [
                                GBColor.primary600.asColor,
                                GBColor.primary400.asColor
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                .clipShape(Capsule())
                .font(FontHelper.btn1.font)
                .foregroundStyle(GBColor.white.asColor)
                .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    AuthRequestView(store: Store(initialState: AuthRequestFeature.State(), reducer: {
        AuthRequestFeature()
    }))
}
