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
    
    private let topText: String
    private let goodData: BuyOrNotChartDataEntity
    private let badData: BuyOrNotChartDataEntity
    private let pieType: PieType
    
    init(datas: [BuyOrNotChartDataEntity]) {
        self.goodData = datas.filter { $0.goodOrBad == true }.first ?? .init(goodOrBad: true, rate: 50)
        self.badData = datas.filter { $0.goodOrBad == false }.first ?? .init(goodOrBad: false, rate: 50)
        
        let topText: String
        if goodData.rate == badData.rate {
            topText = "의견이 반반이에요!"
            self.pieType = .draw
        } else {
            let bool = goodData.rate > badData.rate
            let bestText = bool ? "살까" : "말까"
            let betterRate = abs(goodData.rate - badData.rate)
            topText = "\(bestText)가 \(Int(betterRate))% 더 많아요"
            self.pieType = bool ? .buy : .not
        }
        
        self.topText = topText
        self.datas = datas
    }
    
    var body: some View {
        content
    }
    
    private enum PieType {
        case draw
        case buy
        case not
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
                Text(topText)
                    .font(FontHelper.body2.font)
                    .foregroundStyle(GBColor.grey100.asColor)
                Spacer()
            }
        }
    }
    
    private var chartSection: some View {
        HStack(spacing: 24) {
            goodOrBadView(item: goodData)
            PieChartView(configs: datas.enumerated().map{ mapToConfig(item: $0.element, last: $0.offset == (datas.count - 1)) }.reversed())
                .frame(width: 130, height: 130)
            goodOrBadView(item: badData)
        }
    }
    
    private func mapToConfig(item: any BuyOrNotChartDataEntityProtocol, last: Bool) -> PieChartSliceConfig {
        let bool = datas.map(\.rate).max() == item.rate
        let ifDraw = self.pieType == .draw
        let fill: PieChartSliceConfig.Fill
        
        if ifDraw && last {
            print("LAST")
            fill = .gradient(GBGradientColor.subMainGradient.shape)
        } else {
            print("not LAST")
            fill = bool ? .gradient(GBGradientColor.mainGradient.shape) : .color(Color.white.opacity(0.15))
        }
        
        return PieChartSliceConfig(
            value: item.rate,
            fill: fill,
            stroke: .init(lineWidth: 1, color: GBColor.white.asColor.opacity(0.15))
        )
    }
    
    private func goodOrBadView(item: BuyOrNotChartDataEntity) -> some View {
        let bool = datas.map(\.rate).max() == item.rate
        return VStack {
            Group {
                switch self.pieType {
                case .draw:
                    if item.goodOrBad {
                        ImageHelper.badGreen.asImage
                            .resizable()
                            .rotationEffect(Angle(degrees: 180))
                    } else {
                        ImageHelper.badGreen.asImage
                            .resizable()
                    }
                    
                case .buy:
                    if item.goodOrBad {
                        ImageHelper.badGreen.asImage
                            .resizable()
                            .rotationEffect(Angle(degrees: 180))
                    } else {
                        ImageHelper.bad.asImage
                            .resizable()
                    }
                    
                case .not:
                    if item.goodOrBad {
                        ImageHelper.good.asImage
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
        .init(goodOrBad: true, rate: 50),
        .init(goodOrBad: false, rate: 050)
    ])
    .background(GBColor.background1.asColor)
}
#endif
