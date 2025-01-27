//
//  GBHomeTabViewV1.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI
import ComposableArchitecture

struct GBHomeTabViewV1: View {
    
    @State private var currentMoney: Double = 0
    @State private var currentMoneyColor = GBColor.white.asColor
    @State private var currentWeek: [OneWeekDay] = []
    @State private var currentOffset: CGFloat = 0
    @State private var currentTodayCheckList: [CommonCheckListConfiguration] = []
    
    var body: some View {
        contentView
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    currentMoney = 45000
                }
                if currentWeek.isEmpty {
                    let currentWeek = DateManager.shared.fetchWeek()
                    let mapping = currentWeek.map {
                        let ifToday = DateManager.shared.isToday($0.date)
                        return OneWeekDay(
                            date: $0.date,
                            active: $0.active,
                            isSelected: ifToday,
                            isToday: ifToday
                        )
                    }
                    self.currentWeek = mapping
                }
                
                self.currentTodayCheckList = [
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000"),
                    .init(currentState: false, checkListTitle: "야식 안시켜먹기", subText: "+15,000")
                ]
            }
    }
}

extension GBHomeTabViewV1 {
    private var contentView: some View {
        ZStack {
            
            gradientShadowLayerView
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                ScrollView {
                    headerView
                        .padding(.horizontal, SpacingHelper.md.pixel)
                        .padding(.vertical, 16)
                        .padding(.bottom, 7)
                        .opacity(0)
                    
                    ScrollViewOffsetPreference { offsetY in
                        currentOffset = offsetY
                    }
                    
                    moneyView
                        .padding(.horizontal, SpacingHelper.md.pixel)
                        .padding(.bottom, SpacingHelper.lg.pixel)
                    
                    weekView
                        .padding(.horizontal, SpacingHelper.md.pixel)
                        .padding(.bottom, SpacingHelper.lg.pixel)
                    
                    todayListView
                        .padding(.horizontal, SpacingHelper.md.pixel)
                        .padding(.bottom, SpacingHelper.md.pixel)
                }
                .onPreferenceChange(ScrollOffsetKey.self) { offsetY in
                    currentOffset = offsetY
                }
                
                headerView
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.vertical, 16)
                    .background {
                        let opacity = max(0, min(1, (1 - (currentOffset / 99))))
                        return BlurView(style: .systemChromeMaterialDark)
                            .ignoresSafeArea()
                            .opacity(Double(opacity))
                        
                    }
                    .padding(.bottom, 7)
                    
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(uiImage: ImageHelper.homeBack.image)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: ImageHelper.logo3.image)
                    .resizable()
                    .frame(width: 116, height: 28)
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: ImageHelper.bell.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .asButton {
                            
                        }
                    ZStack {
                        Circle()
                            .foregroundStyle(GBColor.error.asColor)
                        Text("1")
                            .font(.system(size: 11, weight: .medium, design: .default))
                    }
                    .frame(width: 16, height: 16)
                    .offset(y: -5)
                    .offset(x: 5)
                }
            }
        }
    }
    
    private var moneyView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(UserDefaultsManager.userNickname + "님,\n이번주 얼마나 아끼셨나요?")
                    .font(FontHelper.h2.font)
                Spacer()
            }
            .padding(.bottom, SpacingHelper.md.pixel)
            
            HStack(alignment: .bottom , spacing: 0) {
                AnimateNumber(
                    font: FontHelper.hero1.font,
                    value: $currentMoney,
                    textColor: $currentMoneyColor,
                    numberStyle: .decimal
                )
                    
                Text("원 아꼇어요!")
                    .font(FontHelper.h3.font)
                Spacer()
            }
            .padding(.bottom, SpacingHelper.sm.pixel)
            
            awardSectionView
        }
        .frame(maxWidth: .infinity)
    }
    
    private var awardSectionView: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(uiImage: ImageHelper.trophy.image)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(.trailing, SpacingHelper.xs.pixel)
                
                Text("3일째 달성중")
                    .font(FontHelper.body5.font)
                
                Color.white
                    .frame(width: 1, height: 16)
                    .padding(.horizontal, SpacingHelper.sm.pixel)
                
                Image(uiImage: ImageHelper.won.image)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(.trailing, SpacingHelper.xs.pixel)
                
                Text("치킨 2마리 만큼 아꼈어요")
                    .font(FontHelper.body5.font)
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            .padding(.vertical, SpacingHelper.xs.pixel)
            .background(GBColor.background1.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(GBColor.grey400.asColor)
            }
            Spacer()
        }
    }
    
    private var weekView: some View {
        HStack(spacing: 0) {
            ForEach(currentWeek, id: \.self) { item in
                weekElementView(model: item)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.all, SpacingHelper.md.pixel)
        .background(GBColor.main.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 2)
                .foregroundStyle(
                    GBColor.white.asColor.opacity(0.4)
                )
        }
    }
    
    private func weekElementView(model: OneWeekDay) -> some View {
        VStack(spacing: 0) {
            Group {
                if DateManager.shared.isToday(model.date) {
                    Circle()
                        .frame(width: 4,height: 4)
                        .foregroundStyle(GBColor.white.asColor)
                } else {
                    Color.clear
                        .frame(width: 4,height: 4)
                }
            }
            .padding(.bottom, SpacingHelper.sm.pixel)
            
            Text(DateManager.shared.format(format: .simpleE, date: model.date))
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.bottom, SpacingHelper.sm.pixel)
                
            if model.isSelected {
                Circle()
                    .background(.clear)
                    .foregroundStyle(.clear)
                    .overlay {
                        Image(uiImage: ImageHelper.kakao.image)
                            .resizable()
                    }
                    .padding(.all, SpacingHelper.sm.pixel)
            } else {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(GBColor.white.asColor.opacity(0.3))
                    .overlay {
                        Text(DateManager.shared.format(format: .dayD, date: model.date))
                            .font(FontHelper.body1.font)
                            .foregroundStyle(GBColor.white.asColor.opacity(0.3))
                    }
                    .padding(.all, SpacingHelper.sm.pixel)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var todayListView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom , spacing: 0) {
                Text("오늘 실천해야해요")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.grey50.asColor)
                Spacer()
                Text("총 49,000원 절약 가능")
                    .font(FontHelper.body4.font)
                    .foregroundStyle(GBColor.grey300.asColor)
            }
            .padding(.horizontal, SpacingHelper.sm.pixel)
            .padding(.bottom, 10)
            
            LazyVStack(spacing: SpacingHelper.md.pixel) {
                ForEach(currentTodayCheckList, id: \.id) { item in
                    todayListElementView(item: item)
                }
            }
        }
    }
    
    private func todayListElementView(item: CommonCheckListConfiguration) -> some View {
        CommonCheckListButtonView(configuration: item)
            .asButton {
                
            }
    }
}


extension GBHomeTabViewV1 {
    private var gradientShadowLayerView: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.1),
                Color.black.opacity(0.3),
                Color.black.opacity(0.5),
                Color.black.opacity(0.6),
                Color.black.opacity(0.7),
                Color.black.opacity(0.8),
                Color.black.opacity(1)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

#if DEBUG
#Preview {
    GBHomeTabViewV1()
}
#endif


