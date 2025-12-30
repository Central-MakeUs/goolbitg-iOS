//
//  AnalysisOfConsumptionHabitsTopView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/14/25.
//

import SwiftUI
import FeatureCommon
import Utils

struct AnalysisOfConsumptionHabitsTopViewConfig {
    let name: String
    let gbName: String
    let topRate: Double
    let imageURL: String
    
#if DEBUG
    static var dummy: Self {
        return AnalysisOfConsumptionHabitsTopViewConfig(
            name: "굴비",
            gbName: "거지굴비",
            topRate: 40.0,
            imageURL: "https://play-lh.googleusercontent.com/GO2pHhJcXegeWo4FpTyWGSXO-lJKzmi6pfEnhJfibEcgnflHIAm9pUvuLiWFsdRdEIf5=w240-h480-rw"
        )
    }
#endif
}

struct AnalysisOfConsumptionHabitsTopView: View {
    
    let data: AnalysisOfConsumptionHabitsTopViewConfig
    
    var body: some View {
        content
    }
}

extension AnalysisOfConsumptionHabitsTopView {
    
    private var content: some View {
        ZStack(alignment: .top) {
            HStack {
                topTextView
                Spacer()
            }
            .zIndex(1)
            
            HStack {
                Spacer()
                DownImageView(url: URL(string:data.imageURL), option: .mid, fallbackURL: nil, fallBackImg: ImageHelper.splashBack.image, fallBackGrey: true, cache: false)
                    .aspectRatio(184/198, contentMode: .fit)
                    .frame(height: 198)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var topTextView: some View {
        VStack(alignment: .leading ,spacing: .gb(.xs)) {
            
            Text("\(data.name)님은 \(data.gbName) 중에서")
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            Text("상위 \(Int(data.topRate))%")
                .font(FontHelper.h1.font)
                .foregroundStyle(GBColor.main.asColor)
        }
    }
}

#if DEBUG
#Preview {
    AnalysisOfConsumptionHabitsTopView(data: .dummy)
        .padding(.all, .gb(.md))
        .background(GBColor.background1.asColor)
}
#endif
