//
//  ChallengeTabView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ChallengeTabView: View {
    
    @Perception.Bindable var store: StoreOf<ChallengeTabFeature>
    
    @State private var tabMode: ChallengeTabInMode = .individuals
    
    @State private var showDatePicker: Bool = false
    
    @Namespace private var daySelectedAnimation
    // 애니메이션 방향 (-1: 왼쪽, 1: 오른쪽)
    @State private var animationDirection: CGFloat = 0
    @State private var selectedWeekDay = WeekDay(date: Date())
    
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .onChange(of: store.weekIndex) { newValue in
//                    RunLoop.main.perform {
//                       
//                    }
                    store.send(.viewEvent(.checkPagingForWeekData))
                }
                .onChange(of: store.selectedWeekDay) { newValue in
                    selectedWeekDay = newValue
                }
                .popup(isPresented: $showDatePicker) {
                    GBBottonSheetView {
                        AnyView(bottomSheetDateView)
                    }
                    .frame(maxWidth: .infinity)
                    .background(GBColor.grey600.asColor)
                    .cornerRadiusCorners(12, corners: [.topLeft, .topRight])
                    .onAppear {
                        store.send(.delegate(.hiddenTabBar))
                    }
                } customize: {
                    $0
                        .type(.toast)
                        .animation(.spring)
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .backgroundColor(Color.black.opacity(0.5))
                        .dismissCallback {
                            store.send(.delegate(.showTabBar))
                        }
                }

        }
    }
    
    private var bottomSheetDateView: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $store.datePickerMonth.sending(\.datePickerMonth),
                in: store.maxCalendar,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .changeTextColor(GBColor.white.asColor)
            
            GBButtonV2(title: TextHelper.acceptTitle) {
                store.send(.viewEvent(.selectedMonthDate(store.datePickerMonth)))
                showDatePicker.toggle()
            }
            .padding(.all, 16)
        }
    }
}

extension ChallengeTabView {
    private var contentView: some View {
        VStack {
            headerView
                .padding(.top, SpacingHelper.md.pixel)
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, SpacingHelper.md.pixel)
            
            ZStack {
                if tabMode == .individuals {
                    individualsSectionView
                        .transition(
                            animationDirection == 1 ?
                                .move(edge: .trailing) :
                                    .move(edge: .leading)
                        )
                } else {
                    groupChallengeView
                        .transition(
                            animationDirection == 1 ?
                                .move(edge: .trailing) :
                                    .move(edge: .leading)
                        )
                }
            }
            .animation(.easeInOut, value: tabMode) // 전환 애니메이션 적용
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GBColor.background1.asColor)
    }
    
    private var headerView: some View {
        HStack (spacing: 0) {
            
            Text("개인")
                .font(headerTitleFont(mode: .individuals , by: tabMode))
                .foregroundStyle(headerTitleColor(mode: .individuals, by: tabMode))
                .asButton {
                    withAnimation {
                        tabMode = .individuals
                        animationDirection = -1
                    }
                }
                .padding(.trailing, 4)
            
//            Text("그룹")
//                .font(headerTitleFont(mode: .groups , by: tabMode))
//                .foregroundStyle(headerTitleColor(mode: .groups, by: tabMode))
//                .asButton {
//                    withAnimation {
//                        tabMode = .groups
//                        animationDirection = 1
//                    }
//                }
            
            Spacer()
            switch tabMode {
            case .individuals:
                Image(uiImage: ImageHelper.plusLogo.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.showChallengeAdd))
                    }
            case .groups:
                Image(uiImage: ImageHelper.plusLogo.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.showChallengeAdd))
                    }
                    .padding(.trailing, 8)
                
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24)
                    .foregroundStyle(GBColor.grey300.asColor)
                    .asButton {
                       
                    }
            }
            
        }
    }
    
}

// MARK: 개인 섹션 뷰
extension ChallengeTabView {
    
    private var individualsSectionView: some View {
        VStack(spacing: 0) {
            
            monthSelectionView
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, 10)
            
            calendarWeakView
            
            ScrollView {
                if store.isToday {
                    toggleButtonView
                        .padding(.vertical, SpacingHelper.lg.pixel - 10)
                }
                ZStack(alignment: .top) {
                    
                    emptyView
                    
                    VStack(spacing: 0) {
                        challengeListView
                            .padding(.horizontal, SpacingHelper.md.pixel)
                        
                        Color.clear
                            .frame(height: safeAreaInsets.bottom + 20)
                    }
                }
            }
        }
    }
    
    private var emptyView: some View {
        let selectedSwitch = store.toggleSwitchCase[store.selectedSwitchIndex]
        
        return VStack(spacing: 0) {
            if !store.challengeList.isEmpty {}
            else if !store.isToday {
                if DateManager.shared.isBeforeToday(store.selectedWeekDay.date) {
                    ImageHelper.appLogo.asImage
                        .resizable()
                        .frame(width: 180, height: 180)
                        .grayscale(1)
                    
                    Text(ChallengeEmptyCase.beforeIngEmpty.title)
                        .font(FontHelper.body2.font)
                        .foregroundStyle(GBColor.white.asColor)
                } else {
                    ImageHelper.appLogo.asImage
                        .resizable()
                        .frame(width: 180, height: 180)
                        .grayscale(1)
                    
                    Text(ChallengeEmptyCase.todayButIngEmpty.title)
                        .font(FontHelper.body2.font)
                        .foregroundStyle(GBColor.white.asColor)
                }
            }
            else if selectedSwitch == .wait, !store.listLoad {
                ImageHelper.appLogo.asImage
                    .resizable()
                    .frame(width: 180, height: 180)
                    
                Text(ChallengeEmptyCase.todayButIngEmpty.title)
                    .multilineTextAlignment(.center)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.white.asColor)
                
            }
            else if selectedSwitch == .success, !store.listLoad  {
                ImageHelper.appLogo.asImage
                    .resizable()
                    .frame(width: 180, height: 180)
                    .grayscale(1)
                
                Text(ChallengeEmptyCase.todaySuccessEmpty.title)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
        }
        .padding(.vertical, SpacingHelper.xl.pixel)
    }
    
    private var calendarWeakView: some View {

        return VStack (spacing: 0) {
            TabView(selection: $store.weekIndex.sending(\.weekIndex)) {
                ForEach(store.weekSlider.indices, id: \.self) { index in
                    if let week = store.weekSlider[safe: index] {
                        weekView(week)
                            .tag(index)
                    }
                }
            }
            .frame(height: 105)
            .padding(.horizontal, SpacingHelper.md.pixel)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
    }
    
    private func weekView(_ weak: [WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(weak) { day in
                VStack(alignment: .center, spacing: 0) {
                    Group {
                        if DateManager.shared.isToday(day.date) {
                            Circle()
                                .frame(width: 4,height: 4)
                                .foregroundStyle(GBColor.main.asColor)
                        } else {
                            VStack{}
                                .frame(width: 4,height: 4)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    Text(DateManager.shared.format(format: .simpleE, date: day.date))
                        .font(FontHelper.body1.font)
                        .foregroundStyle(GBColor.white.asColor)
                        .padding(.bottom, SpacingHelper.sm.pixel)
                    
                    ZStack {
                        if DateManager.shared.isSameDay(date: day.date, date2: store.selectedWeekDay.date) {
                            Circle()
                                .foregroundStyle(GBColor.main60.asColor)
                                .matchedGeometryEffect(id: "daySelectedAnimation", in: daySelectedAnimation)
                                .frame(height: 36)
                        } else if DateManager.shared.isToday(day.date) {
                            Circle()
                                .foregroundStyle(GBColor.grey600.asColor)
                                .frame(height: 36)
                                .overlay {
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(GBColor.grey500.asColor)
                                }
                        }
                        
                        // 날짜 텍스트
                        if store.selectedWeekDay == day {
                            Text(DateManager.shared.format(format: .dayDD, date: day.date))
                                .font(FontHelper.body1.font)
                                .foregroundStyle(GBColor.white.asColor)
                                .frame(height: 36) // 고정된 크기로 UI 유지
                                .background(
                                    Circle()
                                        .foregroundStyle(Color.clear)
                                )
                        } else {
                            Text(DateManager.shared.format(format: .dayDD, date: day.date))
                                .font(FontHelper.body1.font)
                                .foregroundStyle(day.active ? GBColor.white.asColor : GBColor.grey500.asColor)
                                .frame(height: 36) // 고정된 크기로 UI 유지
                                .background(
                                    Circle()
                                        .foregroundStyle(Color.clear)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36) // 전체 크기 고정
                    .padding(.bottom, SpacingHelper.sm.pixel)
                    
                    dayProgressView(percentage: day.percent)
                }
                .asButton {
                    withAnimation(.snappy) {
                        selectedWeekDay = day
                    }
                    store.send(.viewEvent(.selectedWeek(day)))
                }
            }
        }
    }
    
    private var monthSelectionView: some View {
        let monthText = DateManager.shared.format(format: .yyyymmddKorean, date: store.datePickerMonth)
        
        return HStack (spacing: 0) {
            
            Text(monthText)
                .padding(.trailing, 8)
                .foregroundStyle(GBColor.white.asColor)
            
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 10, height: 13)
                .foregroundStyle(GBColor.white.asColor)
                .rotationEffect(.degrees(90))
            Spacer()
        }
        .asButton {
            showDatePicker.toggle()
        }
    }
    
    private func dayProgressView(percentage: Double) -> some View {
        ZStack (alignment: .leading) {
            GeometryReader { proxy in
                Capsule()
                    .frame(height: 4)
                    .foregroundStyle(GBColor.grey400.asColor)
                    .padding(.horizontal, 4)
                Capsule()
                    .frame(
                        width: max(proxy.size.width * CGFloat(percentage) - 4, 0),
                        height: 4
                    )
                    .padding(.leading, 4)
                    .foregroundStyle(GBColor.main.asColor)
            }
        }
        .frame(height: 4)
        .overlay {
            GeometryReader { proxy in
                if percentage == 1 {
                    HStack {
                        Spacer()
                        Image(uiImage: ImageHelper.bridge.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .trailing
                    )
                    .offset(x: 6)
                }
            }
        }
    }
    
    private var toggleButtonView: some View {
        HStack(spacing: 0) {
            GBSwitchButton(
                switchTitles: store.toggleSwitchCase.map({ $0.viewTittle }),
                selectedIndex: $store.selectedSwitchIndex.sending(\.selectedSwitchIndex),
                backGroundColor: GBColor.grey500.asColor,
                capsuleColor: GBColor.white.asColor,
                defaultTextColor: GBColor.grey300.asColor,
                selectedTextColor: GBColor.black.asColor
            )
            .disabled(!store.isToday)
            .padding(.horizontal, 4)
            .background(GBColor.grey500.asColor)
            .clipShape(Capsule())
            .frame(width: 247, height: 41)
        }
    }
    
    private var challengeListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(store.challengeList.enumerated()), id: \.element.self) { index, item in
                VStack(spacing:0) {
                    Group {
                        if DateManager.shared.isToday(store.selectedWeekDay.date) {
                            CommonChallengeListElementImageView(model: item, next: false)
                                .padding(.vertical, SpacingHelper.md.pixel)
                                .asButton {
                                    store.send(.viewEvent(.selectedDetail(item: item)))
                                }
                        }
                        else if DateManager.shared.isBeforeToday(store.selectedWeekDay.date) {
                            ChallengeBeforeView(model: item)
                                .padding(.vertical, SpacingHelper.md.pixel)
                        }
                        else {
                            CommonChallengeListElementImageView(model: item, next: true)
                                .padding(.vertical, SpacingHelper.md.pixel)
                        }
                    }
                    .onAppear {
                        store.send(.viewEvent(.currentIndex(index)))
                    }
                    
                    if index != store.challengeList.count - 1 {
                        GBColor.grey500.asColor
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                    }
                }
            }
        }
    }
}

// MARK: 그룹 섹션 뷰
extension ChallengeTabView {
    
    private var groupChallengeView: some View {
        VStack(spacing: 0) {
            HStack (spacing: 0){
                Text("참여중인 작심삼일 방")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.grey50.asColor)
                Spacer()
                
                HStack(spacing: 0) {
                    Image(uiImage: ImageHelper.checkMark2.image)
                        .padding(.trailing, 8)
                    
                    Text("내가 만든 방만 보기")
                        .font(FontHelper.body3.font)
                        .foregroundStyle(GBColor.grey400.asColor)
                }
                .asButton {
                    
                }
            }
            .padding(.horizontal, SpacingHelper.md.pixel)
            ScrollView {
                
            }
        }
    }
}


extension ChallengeTabView {
    
    private func headerTitleColor(mode: ChallengeTabInMode, by: ChallengeTabInMode) -> Color {
        return mode == by ? GBColor.white.asColor : GBColor.grey400.asColor
    }
    
    private func headerTitleFont(mode: ChallengeTabInMode, by: ChallengeTabInMode) -> Font {
        return mode == by ? FontHelper.h1.font : FontHelper.h2.font
    }
}

#Preview {
    ChallengeTabView(store: Store(initialState: ChallengeTabFeature.State(), reducer: {
        ChallengeTabFeature()
    }))
}
