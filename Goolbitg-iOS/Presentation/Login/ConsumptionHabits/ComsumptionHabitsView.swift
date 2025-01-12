//
//  ComsumptionHabitsView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import SwiftUI
import ComposableArchitecture

struct ComsumptionHabitsView: View {
    
    @Perception.Bindable var store: StoreOf<ComsumptionHabitsViewFeature>
    
    @State private var showToolTip = false
    @State private var showNextButton = false
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .onTapGesture {
                    endTextEditing()
                }
                .onChange(of: store.ifNextButtonState) { newValue in
                    showNextButton = newValue
                }
                .ignoresSafeArea(.keyboard)
        }
    }
}

extension ComsumptionHabitsView {
    private var contentView: some View {
        VStack{
            
            headerView
                .padding(.top, SpacingHelper.xxl.pixel / 2)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.xl.pixel)
            
            mainContentView
                .padding(.horizontal, SpacingHelper.md.pixel)
               
            
            Spacer()
            
            if showNextButton {
                GBButton(
                    isActionButtonState: $store.ifNextButtonState.sending(\.dummyButtonState),
                    title: TextHelper.nextTitle
                ) {
                    store.send(.viewEvent(.nextButtonTapped))
                }
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, 14)
            }
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var headerView: some View {
        ZStack (alignment: .top) {
            HStack(spacing: 8) {
                Text(TextHelper.ConsumptionScore)
                    .font(FontHelper.h1.font)
                
                Image(uiImage: ImageHelper.infoTip.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24)
                    .asButton {
                        withAnimation {
                            showToolTip.toggle()
                        }
                    }
                    .overlay {
                        if showToolTip {
                            GBToolTipView(
                                description: TextHelper.ConsumptionToolTip,
                                arrowAlignment: .TopCenter,
                                padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                backgroundColor: GBColor.background1.asColor
                            )
                            .offset(y: 60)
                            .animation(.spring, value: showToolTip)
                            .onAppear {
                                store.send(.viewEvent(.showToolTopEvent))
                            }
                        }
                    }
                    .onChange(of: store.closeToolTipTrigger) { _ in
                        withAnimation {
                            showToolTip = false
                        }
                    }
                
                Spacer()
            }
            .padding(.bottom, SpacingHelper.lg.pixel)
            .zIndex(1)
            
            HStack {
                Text(TextHelper.consumptionOverconsumptionIndexMeasurement)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            monthGetTextFieldView
            
            monthSavingTestFieldView
        }
    }
    
    private var monthGetTextFieldView: some View {
        VStack (spacing: 0) {
            sectionTopTextView(text: TextHelper.consumptionAverageMonthlyIncome, required: true)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            ZStack (alignment: .leadingFirstTextBaseline){
                DisablePasteTextField(
                    text: $store.monthGetText.sending(\.monthGetText),
                    isFocused: $store.getisFocused.sending(\.getFocused),
                    placeholder: TextHelper.consumptionAverageMonthlyIncomeWrite,
                    placeholderColor: GBColor.grey500.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad,
                    ifLeadingEdge: 20
                ) {
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                .padding(.bottom, SpacingHelper.xl.pixel)
                
                if store.monthTextGetWonState {
                    Text("₩")
                        .padding(.leading, 20)
                }
            }
        }
    }
    
    private var monthSavingTestFieldView: some View {
        VStack (spacing: 0) {
            sectionTopTextView(text: TextHelper.consumptionAverageMonthlySavings, required: true)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            ZStack (alignment: .leading ) {
                DisablePasteTextField(
                    text: $store.monthSavingText.sending(\.monthSavingText),
                    isFocused: $store.savingIsFocused.sending(\.savingFocused),
                    placeholder: TextHelper.consumptionAverageMonthlySavingsWrite,
                    placeholderColor: GBColor.grey500.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad,
                    ifLeadingEdge: 20
                ) {
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                
                if store.monthTextSavingWonState {
                    Text("₩")
                        .padding(.leading, 20)
                }
            }
            .padding(.bottom, 8)
            
            if store.ifMoreGetting {
                HStack {
                    Text(TextHelper.consumptionAverageMonthlyIncomeBigger)
                        .foregroundStyle(GBColor.error.asColor)
                        .font(FontHelper.caption1.font)
                    
                    Spacer()
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
}

#Preview {
    ComsumptionHabitsView(store: Store(initialState: ComsumptionHabitsViewFeature.State(), reducer: {
        ComsumptionHabitsViewFeature()
    }))
}


/*
 /*
  GBToolTipView(
      description: "소비습관 점수는 평균 수입에 대한\n평균 저축률을 기반으로\n소비 점수를 계산해주고 있어요",
      arrowAlignment: .TopCenter,
      padding: .init(top: 20, left: 20, bottom: 20, right: 20),
      backgroundColor: GBColor.black.asColor.opacity(0.6)
  ) {
      
  }
  .offset(y: -100)
  */
 */
