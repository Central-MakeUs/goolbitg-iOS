import SwiftUI
import FeatureCommon
import ComposableArchitecture
import Utils

struct HabitChartsView: View {

    @Perception.Bindable var store: StoreOf<HabitChartsFeature>
    @Environment(\.dismiss) var dismiss
    @Environment(\.safeAreaInsets) var safeAreaInsets

    var body: some View {
        WithPerceptionTracking {
            content
                .background(GBColor.background1.asColor)
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                
        }
    }
}

extension HabitChartsView {
    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, .md)
                .padding(.bottom, .md)
            
            ScrollViewReader { proxy in
                WithPerceptionTracking {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            SpacingHelper.md.pixel.heightBox
                                .id("habitChartsTop")
                            
                            topSectionView
                                .padding(.horizontal, .md)
                            
                            moreHabitSection
                                .padding(.horizontal, SpacingHelper.md.pixel)
                                .padding(.top, SpacingHelper.md.pixel)

                            CategoryComparisonSectionView(categoryInfo: store.categoryInfo)
                                .padding(.horizontal, SpacingHelper.md.pixel)
                                .padding(.top, SpacingHelper.md.pixel)
                                .overlay {
                                    RoundedRectangle(cornerRadius: SpacingHelper.sm.pixel)
                                        .stroke(GBColor.grey600.asColor, lineWidth: 1)
                                }
                                .padding(.horizontal, SpacingHelper.md.pixel)
                                .padding(.top, SpacingHelper.md.pixel)

                            GroupChallengeComparisonView(
                                indvScore: store.individualSuccessRate,
                                groupScore: store.groupSuccessRate,
                                message: store.individualGroupMessage
                            )
                            .padding(.horizontal, SpacingHelper.md.pixel)
                            .padding(.vertical, SpacingHelper.md.pixel)
                            .overlay {
                                RoundedRectangle(cornerRadius: SpacingHelper.sm.pixel)
                                    .stroke(GBColor.grey600.asColor, lineWidth: 1)
                            }
                            .padding(.horizontal, SpacingHelper.md.pixel)
                            .padding(.top, SpacingHelper.md.pixel)

                            BuyOrNotChartSection(datas: store.buyOrNotDatas, message: store.buyOrNotMessage)
                                .overlay {
                                    RoundedRectangle(cornerRadius: SpacingHelper.sm.pixel)
                                        .stroke(GBColor.grey600.asColor, lineWidth: 1)
                                }
                                .padding(.horizontal, SpacingHelper.md.pixel)
                                .padding(.top, SpacingHelper.md.pixel)
                            
                            SpacingHelper.md.pixel.heightBox
                            
                            HStack {
                                sendToTopSection
                                    .asButton {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            proxy.scrollTo("habitChartsTop", anchor: .top)
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            
                            safeAreaInsets.bottom.heightBox
                        }
                    }
                }
                
            }
        }
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text("소비습관 분석")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        dismiss()
                    }
                Spacer()
            }
        }
    }
    
    private var topSectionView: some View {
        let name = store.userHabitInfo.userName
        let type = store.userHabitInfo.userType
        let imageUrl = store.userHabitInfo.imageURL
        let percent = store.userHabitInfo.upperPercent
        
        let imageViewWidth = UIScreen.main.bounds.width / (390 / 200)
        
        return ZStack(alignment: .top) {
            
            DownImageView(url: URL(string: imageUrl), option: .max)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: imageViewWidth)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(name)님은 \(type) 중")
                    .font(FontHelper.h3.font)
                    .foregroundStyle(GBColor.white.asColor)
                Text("상위 \(percent)%")
                    .font(FontHelper.h1.font)
                    .foregroundStyle(GBColor.main.asColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK:  더 다양한 소비 습관 분석
    private var moreHabitSection: some View {
        return VStack(alignment: .leading, spacing: 0) {
            Text("더 다양한 소비 습관을 분석해봤어요!")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            16.heightBox
            
            RecentChallengeWeeklyComparisonGraphView(
                message: store.recentMessage,
                maxCount: max(store.recentMaxCount, 1),
                monthDataList: store.recentMonthlyData
            )
            .overlay {
                RoundedRectangle(cornerRadius: SpacingHelper.sm.pixel)
                    .stroke(GBColor.grey600.asColor, lineWidth: 1)
            }
        }
    }
    
    // MARK: 맨 위로 올라가기
    private var sendToTopSection: some View {
        return HStack(alignment: .center) {
            ImageHelper.arrowUpSm.asImage
                .resizable()
                .frame(width: 32)
 
            Text("맨 위로 올라가기")
                .font(FontHelper.btn3.font)
                .foregroundStyle(GBColor.grey400.asColor)
        }
    }
}

#if DEBUG
#Preview {
    HabitChartsView(
        store: .init(
            initialState: HabitChartsFeature.State(),
            reducer: { HabitChartsFeature() }
        )
    )
    .background(GBColor.background1.asColor)
}
#endif
