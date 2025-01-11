//
//  ComsumptionHabitsView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import SwiftUI
import ComposableArchitecture

struct ComsumptionHabitsView: View {
    
    var body: some View {
        WithPerceptionTracking {
            contentView
        }
    }
}

extension ComsumptionHabitsView {
    private var contentView: some View {
        VStack{
            
            headerView
            
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Text("소비 습관 점수")
            }
        }
    }
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
