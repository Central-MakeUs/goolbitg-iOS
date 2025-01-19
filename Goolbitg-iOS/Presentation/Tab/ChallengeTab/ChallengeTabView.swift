//
//  ChallengeTabView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct ChallengeTabView: View {
    
    @State private var tabMode: ChallengeTabInMode = .individuals
    
    @State private var currentMonth = Date()
    @State private var monthLeadingButtonState = true
    @State private var monthTrailingButtonState = true
    @State private var weekSlider:[[WeekDay]] = []
    @State private var weekIndex: Int = 1
    @State private var selectedWeekDay = WeekDay(date: Date())
    @State private var createWeekTrigger = true
    
    
    @Namespace private var daySelectedAnimation
    // 애니메이션 방향 (-1: 왼쪽, 1: 오른쪽)
    @State private var animationDirection: CGFloat = 0
    
    var body: some View {
        contentView
            .onAppear {
                if weekSlider.isEmpty {
                    let currentWeak = DateManager.shared.fetchWeek()
                    
                    if let firstDate = currentWeak.first?.date {
                        weekSlider.append(DateManager.shared.createPreviousWeek(firstDate))
                    }
                    
                    weekSlider.append(currentWeak)
                    
                    if let lastDate = currentWeak.last?.date {
                        weekSlider.append(DateManager.shared.createNextWeek(lastDate))
                    }
                }
            }
            .onChange(of: weekIndex) { newValue in
                print(newValue)
                RunLoop.current.perform {
                    if newValue == 2 {
                        pagingWeek()
                    } else if newValue == 0 {
                        pagingWeek()
                    }
                }
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
            
            Text("그룹")
                .font(headerTitleFont(mode: .groups , by: tabMode))
                .foregroundStyle(headerTitleColor(mode: .groups, by: tabMode))
                .asButton {
                    withAnimation {
                        tabMode = .groups
                        animationDirection = 1
                    }
                }
            
            Spacer()
            switch tabMode {
            case .individuals:
                Image(uiImage: ImageHelper.plusLogo.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .asButton {
                        
                    }
            case .groups:
                Image(uiImage: ImageHelper.plusLogo.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .asButton {
                        
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
            calendarWeakView
            challengeListView
        }
    }
    private var calendarWeakView: some View {

        return VStack (spacing: 0) {
            monthSelectionView
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.bottom, 12)
            
            TabView(selection: $weekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    weekView(week)
                        .tag(index)
                }
            }
            .frame(height: 135)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
    }
    
    private func weekView(_ weak: [WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(weak) { day in
                VStack(alignment: .center) {
                    if DateManager.shared.isToday(day.date) {
                        Circle()
                            .frame(width: 4,height: 4)
                            .foregroundStyle(GBColor.main.asColor)
                    } else {
                        VStack{}
                            .frame(width: 4,height: 4)
                    }
                    
                    Text(DateManager.shared.format(format: .simpleE, date: day.date))
                        .font(FontHelper.body1.font)
                        .foregroundStyle(GBColor.white.asColor)
                    
                    VStack(spacing: 0) {
                        Text(DateManager.shared.format(format: .dayDD, date: day.date))
                            .font(FontHelper.body1.font)
                            .foregroundStyle(day.active ? GBColor.white.asColor :GBColor.grey500.asColor )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background {
                        if selectedWeekDay == day ||
                            DateManager.shared.isSameDay(date: day.date, date2: selectedWeekDay.date)
                        {
                            Circle()
                                .foregroundStyle(GBColor.main60.asColor)
                                .padding(.all, 4)
                                .matchedGeometryEffect(id: "daySelectedAnimation", in: daySelectedAnimation)
                        }
                    }
                    
                    dayProgressView(percentage: 1)
                }
                .asButton {
                    withAnimation(.snappy) {
                        selectedWeekDay = day
                    }
                }
            }
        }
        .background {
           
        }
    }
    
    private var monthSelectionView: some View {
        HStack (spacing: 0) {
            
            leadingArrowView
                .padding(.trailing, 4)
            
            Text(DateManager.shared.format(format: .yearMonth, date: currentMonth))
                .padding(.trailing, 4)
            
            trailingButtonState
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var leadingArrowView: some View {
        if monthLeadingButtonState {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 10, height: 13)
                .foregroundStyle(GBColor.white.asColor)
                .asButton {
                    
                }
        } else {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 10, height: 13)
                .foregroundStyle(GBColor.white.asColor)
        }
    }
    
    @ViewBuilder
    private var trailingButtonState: some View {
        if monthTrailingButtonState {
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 10, height: 13)
                .foregroundStyle(GBColor.white.asColor)
                .asButton {
                    
                }
        } else {
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 10, height: 13)
                .foregroundStyle(GBColor.white.asColor)
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
                        width: proxy.size.width * CGFloat(percentage) - 4,
                        height: 4
                    )
                    .padding(.leading, 4)
            }
        }
        .frame(height: 4)
        .overlay {
            GeometryReader { proxy in
                if percentage == 1 {
                    HStack {
                        Spacer()
                        Image(uiImage: ImageHelper.kakao.image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .trailing
                    )
                }
            }
        }
    }
    
    private func pagingWeek() {
        if weekSlider.indices.contains(weekIndex) {
            if let firstDate = weekSlider[weekIndex].first?.date,
               weekIndex == 0 {
                weekSlider.insert(DateManager.shared.createPreviousWeek(firstDate), at: 0)
                weekSlider.removeLast()
                weekIndex = 1
            }
            
            if let lastDate = weekSlider[weekIndex].last?.date,
               weekIndex == 2 {
                weekSlider.append(DateManager.shared.createNextWeek(lastDate))
                weekSlider.removeFirst()
                weekIndex = 1
            }
        }
    }
    
    private var challengeListView: some View {
        ScrollView {
            
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
    ChallengeTabView()
}
