//
//  SelectExpenditureDateView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/13/25.
//

import SwiftUI
import ComposableArchitecture

struct SelectExpenditureDateView: View {
    
    @Perception.Bindable var store: StoreOf<ExpressExpenditureDateViewFeature>
    
    @State private var dropDownTrigger = false
   
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

// MARK: UI
extension SelectExpenditureDateView {
    private var contentView: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.top, SpacingHelper.xl.pixel / 2 )
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.xl.pixel)
            
            ZStack(alignment: .top) {
                weakExpenditureDayView
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .zIndex(2)
                
                if store.selectedWeak != nil {
                    weakExpendingTimeView
                        .padding(.top, 110)
                        .padding(.horizontal, SpacingHelper.md.pixel)
                }
            }
            
            Spacer()
            
            if store.selectedWeak != nil {
                GBButtonV2(title: TextHelper.nextTitle) {
                    store.send(.viewEvent(.nextButtonTapped))
                }
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, 16)
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TextHelper.expenditureSelectMainTitle)
                    .font(FontHelper.h1.font)
                Spacer()
                Text(TextHelper.skipTitle)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                    .asButton {
                        store.send(.viewEvent(.skipClicked))
                    }
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            .padding(.bottom, SpacingHelper.lg.pixel)
            
            HStack {
                Text(TextHelper.expenditureWriteYourTimeAndDay)
                    .font(FontHelper.body1.font)
                    .foregroundStyle(GBColor.grey300.asColor)
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
        }
    }
    
    private var weakExpenditureDayView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TextHelper.expenditureWeakDay)
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.grey50.asColor)
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            .padding(.bottom, 8)
            dropDownWeakView
        }
    }
    
    private var dropDownWeakView: some View {
        VStack(spacing: 0) {
            if !dropDownTrigger {
                VStack(spacing: 0) {
                    HStack {
                        Text(store.selectedWeak?.title ?? TextHelper.expenditureUsuallySelectDay)
                            .foregroundStyle(store.selectedWeak?.title == nil ? GBColor.grey300.asColor : GBColor.white.asColor)
                            .padding(.horizontal, 8)
                        Spacer()
                        Image(uiImage: ImageHelper.chevronDown.image)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 44)
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(GBColor.grey500.asColor, lineWidth: 1)
                }
                .asButton {
                    toggleDropDown()
                }
            } else {
                weakListView
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(GBColor.grey500.asColor, lineWidth: 1)
                    }
            }
        }
    }
    
    private var weakListView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text(store.selectedWeak?.title ?? TextHelper.expenditureUsuallySelectDay)
                        .foregroundStyle(store.selectedWeak?.title == nil ? GBColor.grey300.asColor : GBColor.white.asColor)
                        .padding(.horizontal, 8)
                    Spacer()
                    Image(uiImage: ImageHelper.chevronDown.image)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 44)
            .background(GBColor.grey600.asColor)
            .asButton {
                toggleDropDown()
            }
            .border(width: 1, edges: [.bottom], color: GBColor.grey500.asColor)
            
            ForEach(WeakEnum.allCases, id: \.self) { item in
                VStack {
                    HStack {
                        Text(item.title)
                            .font(FontHelper.body4.font)
                            .foregroundStyle(GBColor.grey50.asColor)
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .asButton {
                        store.send(.viewEvent(.selectedWeak(item)))
                        toggleDropDown()
                    }
                }
                .frame(height: 38)
                .background(GBColor.grey600.asColor)
                .border(width: 1, edges: [.bottom], color: GBColor.grey500.asColor)
            }
        }
    }
    
    private var weakExpendingTimeView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(TextHelper.expenditureWeakTime)
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.grey50.asColor)
                
                Spacer()
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            
            DatePicker(
                "",
                selection: $store.selectedDate.sending(\.selectedDate),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
    }
    
    private func toggleDropDown() {
        withAnimation {
            dropDownTrigger.toggle()
        }
    }
}

#if DEBUG
#Preview {
    SelectExpenditureDateView(store: Store(initialState: ExpressExpenditureDateViewFeature.State(), reducer: {
        ExpressExpenditureDateViewFeature()
    }))
}
#endif
