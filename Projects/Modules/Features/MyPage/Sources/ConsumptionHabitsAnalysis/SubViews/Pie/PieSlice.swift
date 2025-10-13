//
//  PieSlice.swift
//  FeatureMyPage
//
//  Created by Jae hyung Kim on 10/12/25.
//

import SwiftUI

/// 파이 차트의 한 조각을 그리는 Shape
/// - startAngle: 조각이 시작되는 각도 (오른쪽을 기준으로 시계 반대 방향이 양수)
/// - endAngle: 조각이 끝나는 각도
/// - clockwise: true이면 시계 방향으로 호(arc)를 그립니다. 기본값은 false(시계 반대 방향).
/// 이 도형은 InsettableShape를 구현하여 strokeBorder로 이너 스트로크를 지원합니다.
struct PieSlice: InsettableShape {
    /// 시작각도
    var startAngle: Angle
    /// 끝 각도
    var endAngle: Angle
    /// 호 방향 (true: 시계 방향, false: 시계 반대 방향)
    var clockwise: Bool = false
    private var insetAmount: CGFloat = 0
    
    init(startAngle: Angle, endAngle: Angle, clockwise: Bool, insetAmount: CGFloat = 0) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockwise = clockwise
        self.insetAmount = insetAmount
    }

    func path(in rect: CGRect) -> Path {
        // insetAmount 만큼 안쪽으로 줄인 사각형을 기준으로 경로를 계산합니다.
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let center = CGPoint(x: insetRect.midX, y: insetRect.midY) // 사각형의 중심점
        let r = min(insetRect.width, insetRect.height) / 2         // 반지름
        var p = Path()                                             // 경로 객체 생성

        p.move(to: center)
        p.addArc(center: center,
                 radius: r,
                 startAngle: startAngle,
                 endAngle: endAngle,
                 clockwise: clockwise)
        p.closeSubpath()                                           // 시작점과 끝점을 연결
        return p
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}
