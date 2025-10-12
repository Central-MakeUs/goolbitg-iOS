//
//  PieChartView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/12/25.
//

import SwiftUI
import Data
import Utils

struct PieChartView: View {
    
    let items: [Double]
    let colors: [Color]
    private var bestIndex: Int? = nil
    
    init(items: [Double], colors: [Color]) {
        self.items = items
        self.colors = colors
        
        if items.count > 1 {
            if let maxVal = items.max() {
                let first = items.firstIndex(of: maxVal)
                let last  = items.lastIndex(of: maxVal)
                
                self.bestIndex = (first == last) ? first : nil
            } else {
                self.bestIndex = nil
            }
        }
    }
    
    var body: some View {
        content
    }
}

extension PieChartView {
    private var content: some View {
        let slices = angles(for: items)

        return ZStack {
            if slices.isEmpty {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            } else {
                ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                    PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                        .fill(colors[safe: index] ?? .accentColor)
                        .scaleEffect(bestIndex == index ? 1.1 : 1.0)
                }
            }
        }
        .padding(.all, bestIndex != nil ? 20 : 0)
    }
}

extension PieChartView {
    
    func angles(for slices: [Double]) -> [(start: Angle, end: Angle)] {
        // 음수는 0으로 수정
        // [-5, 10] -> [0, 10]
        let positive = slices.map { max(0, $0) }
        let total = positive.reduce(0, +)
        guard total > 0 else { return [] }

        // -90 도 -> 12시 부터
        var accumulated: Double = -90
        var result: [(start: Angle, end: Angle)] = []

        // - 해당 값이 전체에서 차지하는 비율 * 360도
        // - 시작각은 누적각
        // - 끝각은 시작각 + 조각각
        for value in positive {
            let degrees = (value / total) * 360
            let start = Angle(degrees: accumulated)
            let end = Angle(degrees: accumulated + degrees)
            result.append((start, end))
            accumulated += degrees
        }
        
        return result
    }
}

#if DEBUG
#Preview {
    PieChartView(items: [
       20, 30, 50
    ], colors: [ // BestColor 는 같은 인덱스 값만 가능
        .red, .blue, .black
    ])
}
#endif
