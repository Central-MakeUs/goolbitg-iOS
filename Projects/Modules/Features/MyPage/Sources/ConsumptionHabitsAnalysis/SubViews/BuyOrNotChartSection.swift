//
//  BuyOrNotChartSection.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/13/25.
//

import SwiftUI
import Data
import Utils

struct BuyOrNotChartSection: View {
    
    var datas: [BuyOrNotChartDataEntity]
    
    private let ifGoodBest: Bool
    private let bestName: String
    private let betterRate: Double
    private let goodData: BuyOrNotChartDataEntity
    private let badData: BuyOrNotChartDataEntity
    
    init(datas: [BuyOrNotChartDataEntity]) {
        self.goodData = datas.filter { $0.goodOrBad == true }.first ?? .init(goodOrBad: true, rate: 50)
        self.badData = datas.filter { $0.goodOrBad == false }.first ?? .init(goodOrBad: false, rate: 50)
        
        self.ifGoodBest = goodData.rate > badData.rate
        
        self.bestName = ifGoodBest ? "살까" : "말까"
        self.betterRate = abs(goodData.rate - badData.rate)
        self.datas = datas
    }
    
    var body: some View {
        content
    }
}

extension BuyOrNotChartSection {
    
    private var content: some View {
        VStack(spacing: 0) {
            topSection
            chartSection
                .padding(.vertical, SpacingHelper.xl.pixel)
        }
        .padding(.all, SpacingHelper.md.pixel)
    }
    
    private var topSection: some View {
        
        return VStack(spacing: SpacingHelper.sm.pixel) {
            HStack {
                Text("살까말까 투표 결과")
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.grey400.asColor)
                Spacer()
            }
            HStack {
                Text("\(bestName)가 \(Int(betterRate))% 더 많아요")
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey100.asColor)
                Spacer()
            }
        }
    }
    
    private var chartSection: some View {
        HStack(spacing: 24) {
            goodOrBadView(item: goodData)
            PieChartView(configs: datas.map{ mapToConfig(item: $0) })
                .frame(width: 130, height: 130)
            goodOrBadView(item: badData)
        }
    }
    
    private func mapToConfig(item: any BuyOrNotChartDataEntityProtocol) -> PieChartSliceConfig {
        let bool = datas.map(\.rate).max() == item.rate
        
        return PieChartSliceConfig(
            value: item.rate,
            fill: bool ? .gradient(GBGradientColor.mainGradient.shape) : .color(Color.white.opacity(0.15)),
            stroke: .init(lineWidth: 1, color: GBColor.white.asColor.opacity(0.15))
        )
    }
    
    private func goodOrBadView(item: BuyOrNotChartDataEntity) -> some View {
        let bool = datas.map(\.rate).max() == item.rate
        return VStack {
            Group {
                if item.goodOrBad {
                    if self.ifGoodBest {
                        ImageHelper.badGreen.asImage
                            .resizable()
                            .rotationEffect(Angle(degrees: 180))
                    } else {
                        ImageHelper.good.asImage
                            .resizable()
                    }
                } else {
                    if self.ifGoodBest {
                        ImageHelper.bad.asImage
                            .resizable()
                    } else {
                        ImageHelper.badGreen.asImage
                            .resizable()
                    }
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 40)
      
            Text(Int(item.rate).toString + "%")
                .font(FontHelper.body5.font)
                .foregroundStyle(bool ? GBColor.main.asColor : GBColor.grey300.asColor)
        }
    }
}

#if DEBUG
#Preview {
    BuyOrNotChartSection(datas: [
        .init(goodOrBad: false, rate: 60),
        .init(goodOrBad: true, rate: 40)
    ])
    .background(GBColor.background1.asColor)
}
#endif
