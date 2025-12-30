//
//  RadarChartView.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/9/25.
//

import SwiftUI
import Utils
import Data

struct GBRaderChartItem: Hashable, Equatable, GBRadarChartItemProtocol {
    var name: String
    var currentValue: Double
    var maxValue: Double
}

// 샘플 데이터
private let testRadarChartData: [GBRaderChartItem] = [
    .init(name: "식비", currentValue: 3, maxValue: 6),
    .init(name: "기타", currentValue: 4, maxValue: 4),
    .init(name: "생활비", currentValue: 5, maxValue: 7),
    .init(name: "쇼핑", currentValue: 1, maxValue: 4),
    .init(name: "교통비", currentValue: 4, maxValue: 7)
]

// MARK: - 원주율 계산
private extension Angle {
    /// 원주율 에서 값의 포인트 찾기
    /// - Parameter count: 갯수
    /// - Returns: 포인트 값
    static func degreesPerSlice(_ count: Int) -> Double { 360.0 / Double(max(count, 1)) }
}

private struct PolarPoint { let x: CGFloat; let y: CGFloat }

/// 중심/반지름/각도(도)로 원 위의 점 계산
private func pointOnCircle(center: CGPoint, radius: CGFloat, angleDegrees: Double) -> PolarPoint {
    let rad = angleDegrees * .pi / 180
    return PolarPoint(
        x: center.x + radius * CGFloat(cos(rad)),
        y: center.y + radius * CGFloat(sin(rad))
    )
}

// MARK: - 메인 뷰
struct RadarChartView: View {
    
    @State private var progress = 0.0
    private var dependencyItems: [GBRadarChartItemProtocol]
    
    // 표시 옵션
    /// 배경 링 갯수
    private var ringCount: Int
    /// 링, 배경 코너레디우스
    private var cornerRadius: CGFloat
    /// 포인트 옵션
    private var pointOption: Bool
    /// 텍스트 정보 offset
    private var labelOffset: CGFloat
    
    init(
        items: [GBRadarChartItemProtocol] = testRadarChartData,
        ringCount: Int = 4,
        cornerRadius: CGFloat = 8,
        pointOption: Bool = false,
        labelOffset: CGFloat = 30
    ) {
        self.ringCount = ringCount
        self.cornerRadius = cornerRadius
        self.pointOption = pointOption
        self.labelOffset = labelOffset
        self.dependencyItems = items
    }
    
    var body: some View {
        GeometryReader { geo in
            // 그리기 영역(로컬 좌표계) -> 프레임
            let rect = geo.frame(in: .local)
            // 도형의 중심점 (프레임의 중심)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            // 사용할 최대 반지름
            let radius = min(rect.width, rect.height) / 2
            // 정다각형의 변(축) 개수. 최소 3
            let sides = max(dependencyItems.count, 3)
            // 각 꼭짓점 간 각도(도 단위). 360도를 변 개수로 나눈 값
            let step = Angle.degreesPerSlice(sides)
            // 시작 각도 오프셋: -90도(12시 방향)에서 시작하여 위쪽을 첫 축으로
            let startAngleOffset = -90.0

            ZStack {
                // 1) 배경 링(정다각형)들
                ForEach(0..<ringCount, id: \.self) { ring in
                    // 선
                    ringPath(
                        sides: sides,
                        ringIndex: ring,
                        ringCount: ringCount,
                        in: rect,
                        maxRadius: radius,
                        cornerRadius: cornerRadius
                    )
                    .stroke(GBColor.grey500.asColor.opacity(0.25), lineWidth: 1)
                    
                    // 가장 바깥 링을 살짝 채워 배경 도형처럼 표현
                    if ring == ringCount - 1 {
                        ringPath(
                            sides: sides,
                            ringIndex: ring,
                            ringCount: ringCount,
                            in: rect,
                            maxRadius: radius,
                            cornerRadius: cornerRadius
                        )
                        .fill(GBColor.grey500.asColor.opacity(0.15))
                        .overlay(
                            ringPath(
                                sides: sides,
                                ringIndex: ring,
                                ringCount: ringCount,
                                in: rect,
                                maxRadius: radius,
                                cornerRadius: cornerRadius
                            )
                            .stroke(GBColor.grey500.asColor.opacity(0.25), lineWidth: 1)
                        )
                    }
                }

                // 3) 데이터 폴리곤
                let values = dependencyItems.map { $0.currentValue }
                let maxValues = dependencyItems.map { $0.maxValue }
                
                polygonPath(values: values, maxValues: maxValues, in: rect, radius: radius, cornerRadius: cornerRadius)
                    .fill(GBGradientColor.mainGradient.shape.opacity(0.82))
                    .overlay(
                        polygonPath(values: values, maxValues: maxValues, in: rect, radius: radius, cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .scaleEffect(CGSize(width: progress, height: progress))
                    .animation(.smooth(duration: 0.5), value: progress)
                
                if pointOption {
                    // 4) 꼭짓점 하이라이트
                    ForEach(0..<sides, id: \.self) { i in
                        if i < maxValues.count && i < values.count {
                            let ratio = maxValues[i] == 0 ? 0 : min(max(values[i] / maxValues[i], 0), 1)
                            let r = radius * CGFloat(ratio)
                            let angle = startAngleOffset + step * Double(i)
                            let p = pointOnCircle(center: center, radius: r, angleDegrees: angle)
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 6, height: 6)
                                .position(x: p.x, y: p.y)
                        } else {
                            EmptyView()
                        }
                    }
                }
               
                ForEach(0..<sides, id: \.self) { i in
                    if i < dependencyItems.count {
                        let angle = startAngleOffset + step * Double(i)
                        let p = pointOnCircle(center: center, radius: radius + labelOffset, angleDegrees: angle)

                        let name = dependencyItems[i].name
                        let v = Int(dependencyItems[i].currentValue)
                        let m = Int(dependencyItems[i].maxValue)

                        RadarLabel(
                            name: name,
                            current: "\(v)",
                            maximum: "\(m)",
                            highlight: v >= m
                        )
                        .position(x: p.x, y: p.y)
                        
                    } else {
                        EmptyView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            progress = 1
        }
        .padding(.top, labelOffset)
        .padding(.all, labelOffset)
    }
}

// MARK: - Path 생성기
extension RadarChartView {
    /// 주어진 값 비율(current/max)에 따라 레이더 폴리곤 경로를 생성
    /// 꼭짓점을 이어 곡선으로 둥글게 처리
    private func polygonPath(
        values: [Double],
        maxValues: [Double],
        in rect: CGRect,
        radius: CGFloat,
        cornerRadius: CGFloat = 0
    ) -> Path {
        var path = Path()
        guard !values.isEmpty, values.count == maxValues.count else { return path }

        // 중심점/최대 반지름/각도 간격
        let count = values.count
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let step = Angle.degreesPerSlice(count)
        let startAngleOffset = -90.0 // 12시 방향에서 시작

        // 1) 꼭짓점 좌표 계산
        var vertices: [CGPoint] = []
        for i in 0..<count {
            let ratio = maxValues[i] == 0 ? 0 : min(max(values[i] / maxValues[i], 0), 1)
            let r = radius * CGFloat(ratio)
            let angle = startAngleOffset + step * Double(i)
            let p = pointOnCircle(center: center, radius: r, angleDegrees: angle)
            vertices.append(CGPoint(x: p.x, y: p.y))
        }

        // 2) cornerRadius == 0 이면 직선 연결
        guard cornerRadius > 0 else {
            for (idx, p) in vertices.enumerated() {
                if idx == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.closeSubpath()
            return path
        }

        // 3) 라운드 코너 처리
        //    각 꼭짓점에서 이전/다음 변 방향으로 거리 만큼
        //    잘라 입구 / 출구점을 만듬
        //    원래 꼭짓점을 제어점으로 하는 쿼드 커브(곡선 그리기 간단함)로 연결
        let n = vertices.count
        let maxTrim: CGFloat = 24                 // 과도한 라운드를 방지하기 위한 상한
        let rCorner = min(cornerRadius, maxTrim)  // 실제 적용 라운드 반경

        var rounded: [(CGPoint, CGPoint, CGPoint)] = [] // (입구, 코너(제어점), 출구)
        for i in 0..<n {
            let prev = vertices[(i - 1 + n) % n]
            let curr = vertices[i]
            let next = vertices[(i + 1) % n]
            let (pIn, pOut) = trimmedPoints(prev: prev, curr: curr, next: next, trim: rCorner)
            rounded.append((pIn, curr, pOut))
        }

        if let first = rounded.first { path.move(to: first.0) }
        
        for i in 0..<n {
            let (_, corner, pOut) = rounded[i]
            path.addQuadCurve(to: pOut, control: corner)      // 코너 곡선
            let nextIn = rounded[(i + 1) % n].0
            path.addLine(to: nextIn)                          // 다음 입구점까지 직선
        }
        path.closeSubpath()
        return path
    }
    
    
    /// curr 꼭짓점에서 이전/다음 변을 기준으로 "모서리를 깎아낸" 두 점을 계산합니다.
    /// 레이더 폴리곤의 라운드 코너를 만들기 위해, 입구점(pIn)과 출구점(pOut)을 반환합니다.
    /// - Parameters:
    ///   - prev: 현재 꼭짓점(curr) 바로 이전 꼭짓점
    ///   - curr: 라운드를 만들 기준이 되는 현재 꼭짓점(코너, 곡선의 control point로 사용)
    ///   - next: 현재 꼭짓점(curr) 바로 다음 꼭짓점
    ///   - trim: 꼭짓점에서 변 방향으로 잘라낼 거리(라운드의 강도)
    /// - Returns: (pIn, pOut) 튜플. pIn은 이전 변에서 curr로 들어오다 멈추는 지점, pOut은 다음 변으로 나아가기 시작하는 지점
    private func trimmedPoints(prev: CGPoint, curr: CGPoint, next: CGPoint, trim: CGFloat) -> (CGPoint, CGPoint) {
        // prev -> curr 방향 벡터
        let v1 = CGVector(dx: curr.x - prev.x, dy: curr.y - prev.y)
        // curr -> next 방향 벡터
        let v2 = CGVector(dx: next.x - curr.x, dy: next.y - curr.y)

        // 각 벡터의 길이(√(dx² + dy²)). 0으로 나누는 것을 방지하기 위해 0.0001
        let l1 = max(hypot(v1.dx, v1.dy), 0.0001)
        let l2 = max(hypot(v2.dx, v2.dy), 0.0001)

        // 단위 벡터(방향만 유지, 길이 1)
        let u1 = CGVector(dx: v1.dx / l1, dy: v1.dy / l1)
        let u2 = CGVector(dx: v2.dx / l2, dy: v2.dy / l2)

        // pIn: 이전 변을 따라 curr로 들어오다가, curr 직전에서 trim만큼 떨어진 지점
        let pIn  = CGPoint(x: curr.x - u1.dx * trim, y: curr.y - u1.dy * trim)
        // pOut: 다음 변의 방향으로 curr에서 trim만큼 이동한 지점(다음 변으로 출발하는 시작점)
        let pOut = CGPoint(x: curr.x + u2.dx * trim, y: curr.y + u2.dy * trim)

        return (pIn, pOut)
    }
}

extension RadarChartView {
    /// 정다각형(그리드 링) 경로 생성
    /// - Parameters:
    ///   - sides: 정다각형 변의 개수 (최소 3)
    ///   - ringIndex: 0 기반 인덱스. 0이면 가장 안쪽 링, ringCount-1이면 가장 바깥 링
    ///   - ringCount: 총 링 개수. ringIndex와 함께 반경 비율을 계산
    ///   - rect: 도형을 그릴 영역(중심/반지름 계산에 사용)
    ///   - inset: 외곽 여백. 값이 클수록 전체 반경이 줄어듭니다.
    ///   - cornerRadius: 꼭짓점 라운드 반경. 0이면 직선, 양수면 둥근 꼭짓점
    /// - Returns: 해당 링의 정다각형 Path (채우기/스트로크 모두에 사용 가능)
    private func ringPath(
        sides: Int,
        ringIndex: Int,
        ringCount: Int,
        in rect: CGRect,
        maxRadius: CGFloat,
        cornerRadius: CGFloat = 0
    ) -> Path {
        var path = Path()
        // 방어 코드: 최소 조건 확인
        guard sides >= 3, ringCount > 0 else { return path }

        // 1) 기하 파라미터 계산
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let step = Angle.degreesPerSlice(sides)
        let startAngle = -90.0 // 12시 방향 기준

        // ringIndex를 ringCount로 나눠 링의 반경 비율을 구함 (1..ringCount)
        let ringRatio = Double(ringIndex + 1) / Double(ringCount)
        let radius = maxRadius * CGFloat(ringRatio)

        // 2) 꼭짓점 좌표 계산 헬퍼
        func verticesOfRegularPolygon() -> [CGPoint] {
            var points: [CGPoint] = []
            points.reserveCapacity(sides)
            for i in 0..<sides {
                let angle = startAngle + step * Double(i)
                let p = pointOnCircle(center: center, radius: radius, angleDegrees: angle)
                points.append(CGPoint(x: p.x, y: p.y))
            }
            return points
        }

        let vertices = verticesOfRegularPolygon()

        // 3) cornerRadius == 0 이면 직선 연결로 빠르게 반환
        guard cornerRadius > 0 else {
            for (idx, p) in vertices.enumerated() {
                if idx == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.closeSubpath()
            return path
        }

        // 4) 라운드 코너 처리: 각 꼭짓점에서 입구/출구점을 만들고 쿼드 커브로 연결
        let n = vertices.count
        let maxTrim: CGFloat = 24
        let rCorner = min(cornerRadius, maxTrim)

        var rounded: [(CGPoint, CGPoint, CGPoint)] = [] // (입구, 코너(제어점), 출구)
        rounded.reserveCapacity(n)
        for i in 0..<n {
            let prev = vertices[(i - 1 + n) % n]
            let curr = vertices[i]
            let next = vertices[(i + 1) % n]
            let (pIn, pOut) = trimmedPoints(prev: prev, curr: curr, next: next, trim: rCorner)
            rounded.append((pIn, curr, pOut))
        }

        if let first = rounded.first { path.move(to: first.0) }
        for i in 0..<n {
            let (_, corner, pOut) = rounded[i]
            path.addQuadCurve(to: pOut, control: corner)
            let nextIn = rounded[(i + 1) % n].0
            path.addLine(to: nextIn)
        }
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        RadarChartView()
            .background(GBColor.background1.asColor)
            .frame(width: 300, height: 300)
    }
}
#endif


// MARK: 참고 자료: https://eunjin3786.tistory.com/593

