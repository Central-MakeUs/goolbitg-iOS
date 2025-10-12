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
struct PieSlice: Shape {
    /// 시작각도
    var startAngle: Angle
    /// 끝 각도
    var endAngle: Angle
    /// 호 방향 (true: 시계 방향, false: 시계 반대 방향)
    var clockwise: Bool = false

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)        // 사각형의 중심점
        let r = min(rect.width, rect.height) / 2                // 반지름
        var p = Path()                                         // 경로 객체 생성
        
        p.move(to: center)
        p.addArc(center: center,
                 radius: r,
                 startAngle: startAngle,
                 endAngle: endAngle,
                 clockwise: clockwise)
        p.closeSubpath()                                        // 시작점과 끝점을 연결
        return p
    }
}
