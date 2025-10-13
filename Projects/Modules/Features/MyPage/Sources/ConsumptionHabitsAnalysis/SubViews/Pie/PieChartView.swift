//
//  PieChartView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/12/25.
//

import SwiftUI
import Data
import Utils

// MARK: - Pie Chart Slice Configuration
public struct PieChartSliceConfig: Identifiable {
    public struct Stroke {
        public var lineWidth: CGFloat
        public var color: Color
        public init(lineWidth: CGFloat = 1, color: Color = .white) {
            self.lineWidth = lineWidth
            self.color = color
        }
    }

    public enum Fill {
        case color(Color)
        case gradient(LinearGradient)
    }

    public let id = UUID()
    public var value: Double
    public var fill: Fill
    public var stroke: Stroke?

    public init(value: Double, fill: Fill, stroke: Stroke? = nil) {
        self.value = value
        self.fill = fill
        self.stroke = stroke
    }
}

struct PieChartView: View {

    // New preferred API
    let configs: [PieChartSliceConfig]

    // Back-compat API
    let items: [Double]
    let colors: [Color]

    private var bestIndex: Int?

    // New init
    init(configs: [PieChartSliceConfig]) {
        self.configs = configs
        self.items = configs.map { max(0, $0.value) }
        self.colors = configs.enumerated().map { idx, cfg in
            switch cfg.fill {
            case .color(let c): return c
            case .gradient: return .accentColor // fallback only for legacy color array usage
            }
        }
        self.bestIndex = PieChartView.computeBestIndex(from: self.items)
    }

    // Legacy init
    init(items: [Double], colors: [Color]) {
        self.items = items
        self.colors = colors
        self.configs = zip(items, colors).map { (value, color) in
            PieChartSliceConfig(value: value, fill: .color(color), stroke: nil)
        }
        self.bestIndex = PieChartView.computeBestIndex(from: items)
    }

    var body: some View {
        content
    }

    private static func computeBestIndex(from items: [Double]) -> Int? {
        if items.count > 1 {
            if let maxVal = items.max() {
                let first = items.firstIndex(of: maxVal)
                let last  = items.lastIndex(of: maxVal)

                return (first == last) ? first : nil
            }
        }
        return nil
    }
}

extension PieChartView {
    private var content: some View {
        let slices = angles(for: configs.map { max(0, $0.value) })
        let noBest = bestIndex == nil
        return ZStack {
            if slices.isEmpty {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            } else {
                ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                    let cfg = configs[safe: index]
                    if let cfg {
                        if noBest {
                            newPieSlice(index: index, cfg: cfg, slice: slice)
                        } else {
                            newPieSlice(index: index, cfg: cfg, slice: slice)
                                .scaleEffect(bestIndex == index ? 1.0 : 0.9)
                        }
                    } else { // 일반적인 방식
                        if noBest {
                            PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                                .fill(colors[safe: index] ?? .accentColor)
                        }
                        PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                            .fill(colors[safe: index] ?? .accentColor)
                            .scaleEffect(bestIndex == index ? 1 : 0.9)
                    }
                }
            }
        }
    }
    
    private func newPieSlice(index: Int, cfg: PieChartSliceConfig, slice:(start: Angle, end: Angle)) -> some View {
        ZStack {
            Group {
                switch cfg.fill {
                case .color(let c):
                    PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                        .fill(c)
                case .gradient(let g):
                    PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                        .fill(g)
                }
            }
            .overlay(
                Group {
                    if let stroke = cfg.stroke, stroke.lineWidth > 0 {
                        PieSlice(startAngle: slice.start, endAngle: slice.end, clockwise: false)
                        .strokeBorder(stroke.color, lineWidth: stroke.lineWidth)
                    }
                }
            )
        }
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
#Preview("Legacy API") {
    PieChartView(items: [20, 30, 30, 20], colors: [.red, .blue, .black, .green])
        .frame(width: 220, height: 220)
        .padding()
}

#Preview("Config API with Gradient & Stroke") {
    let configs: [PieChartSliceConfig] = [
        .init(value: 20, fill: .color(.red), stroke: .init(lineWidth: 2, color: .white)),
        .init(value: 30, fill: .gradient(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)), stroke: .init(lineWidth: 3, color: .black.opacity(0.3))),
        .init(value: 30, fill: .gradient(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))),
        .init(value: 20, fill: .color(.green), stroke: .init(lineWidth: 1, color: .white.opacity(0.6)))
    ]
    return PieChartView(configs: configs)
        .frame(width: 220, height: 220)
        .background(GBColor.error.asColor)
}
#endif

