//
//  ToolTipView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/12/25.
//

import SwiftUI

struct GBToolTipView: View {
    var description: String
    var arrowAlignment: GBToolTipArrowAlignment = .BottomCenter
    var showCancelButton: Bool
    var padding: UIEdgeInsets
    let backgroundColor: Color
    
    init(
        description: String,
        arrowAlignment: GBToolTipArrowAlignment = .BottomCenter,
        showCancelButton: Bool = false,
        padding: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8),
        backgroundColor: Color = GBColor.black.asColor.opacity(0.8)
    ) {
        self.description = description
        self.arrowAlignment = arrowAlignment
        self.showCancelButton = showCancelButton
        self.padding = padding
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            topLeftView
            topCenterView
            topRightView
            
            midView
            
            switch arrowAlignment {
            case .BottomLeft:
                bottomView(alignment: .leading)
            case .BottomCenter:
                bottomView(alignment: .center)
            case .BottomRight:
                bottomView(alignment: .trailing)
            default:
                EmptyView()
            }
        }
        .contentShape(Rectangle())
    }
    
    private var topLeftView: some View {
        VStack(alignment: .leading, spacing: -0.1) {
            switch arrowAlignment {
            case .TopLeft:
                triangleView()
                    .padding(.leading, 15)
                    .zIndex(20)
                titleView
            default:
                EmptyView()
            }
        }
    }
    
    private var topCenterView: some View {
        VStack(spacing: -0.1) {
            switch arrowAlignment {
            case .TopCenter:
                triangleView()
                    .zIndex(20)
                titleView
            default:
                EmptyView()
            }
        }
    }
    
    private var topRightView: some View {
        VStack(alignment: .trailing, spacing: -0.1) {
            switch arrowAlignment {
            case .TopRight:
                triangleView()
                    .padding(.trailing, 15)
                    .zIndex(20)
                titleView
            default:
                EmptyView()
            }
        }
    }
    
    private var midView: some View {
        HStack(spacing: 0) {
            switch arrowAlignment {
            case .MidLeft:
                triangleView()
                    .offset(x: 1.322, y: 0)
                    .zIndex(20)
                titleView
            case .MidRight:
                titleView
                triangleView()
                    .offset(x: -1.322, y: 0)
                    .zIndex(20)
            default:
                EmptyView()
            }
        }
    }
    
    private func bottomView(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: -0.1) {
            switch arrowAlignment {
            case .BottomLeft:
                titleView
                triangleView()
                    .padding(.leading, 15)
                    .zIndex(20)
            case .BottomCenter:
                titleView
                triangleView()
            case .BottomRight:
                titleView
                triangleView()
                    .padding(.trailing, 15)
                    .zIndex(20)
            default:
                EmptyView()
            }
        }
    }
    
    private func triangleView() -> some View {
        ZStack {
            Triangle()
                .foregroundStyle(self.backgroundColor)
            TriangleBorder()
                .stroke(.white.opacity(0.7), lineWidth: 0.5)
        }
        .frame(width: 8.69, height: 7)
        .rotationEffect(arrowAlignment.degress)
    }
    
    private var titleView: some View {
        ZStack {
        
            BlurView(style: .systemThickMaterialDark)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .opacity(0.9)
                .zIndex(2)
            
            RoundedRectBorder(aligment: arrowAlignment)
                .stroke(.white.opacity(0.7), lineWidth: 0.5)
                .zIndex(1)
            
            Text(description)
                .font(FontHelper.body5.font)
                .lineSpacing(5)
                .foregroundStyle(.white)
                .padding(.horizontal, padding.left)
                .padding(.vertical, padding.top)
                .multilineTextAlignment(.center)
                .zIndex(3)
        }
        .fixedSize()
    }
}


extension GBToolTipView {
    enum GBToolTipArrowAlignment : Sendable{
        case TopLeft
        case TopCenter
        case TopRight
        case MidLeft
        case MidRight
        case BottomLeft
        case BottomCenter
        case BottomRight
        
        
        var degress: Angle {
            switch self {
            case .TopLeft, .TopCenter, .TopRight:
                return .degrees(0)
            case .MidLeft:
                return .degrees(-90)
            case .MidRight:
                return .degrees(90)
            case .BottomLeft, .BottomCenter, .BottomRight:
                return .degrees(180)
            }
        }
    }
}

struct RoundedRectBorder: Shape {
    
    var aligment: GBToolTipView.GBToolTipArrowAlignment
    
    init(aligment: GBToolTipView.GBToolTipArrowAlignment) {
        self.aligment = aligment
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch aligment {
        case .BottomCenter:
            path = bottomCenterView(rect: rect)
        default:
            path = midLeftView(rect: rect)
        }
        
        return path
    }
    
    private func midLeftView(rect: CGRect) -> Path {
        var path = Path()
        
        let centerX = rect.midX
        let bottomY = rect.maxY
        
        path.addArc(center: CGPoint(x: rect.minX + 5, y: rect.minY + 5), radius: 5, startAngle: Angle(degrees: 280), endAngle: Angle(degrees: 180), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX, y: bottomY - 5))
        
        // Exclude the bottom center part from the border
        
        path.addArc(center: CGPoint(x: rect.minX + 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: -180), endAngle: Angle(degrees: 100), clockwise: true)
        
        path.addLine(to: CGPoint(x: centerX, y: bottomY)) // Adjust the value as needed
        path.move(to: CGPoint(x: centerX, y: bottomY)) // Adjust the value as needed
        
        path.addArc(center: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: 100), endAngle: Angle(degrees: 0), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY - 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 5))
        
        path.addArc(center: CGPoint(x: rect.maxX - 5, y: rect.minY + 5), radius: 5, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX + 5.9, y: rect.minY))
        
        return path
    }
    
    private func bottomCenterView(rect: CGRect) -> Path {
        
        var path = Path()
        
        let centerX = rect.midX
        let bottomY = rect.maxY
        
        path.addArc(center: CGPoint(x: rect.minX + 5, y: rect.minY + 5), radius: 5, startAngle: Angle(degrees: 280), endAngle: Angle(degrees: 180), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX, y: bottomY - 5))
        
        // Exclude the bottom center part from the border
        
        path.addArc(center: CGPoint(x: rect.minX + 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: -180), endAngle: Angle(degrees: 100), clockwise: true)
        
        path.addLine(to: CGPoint(x: centerX - 4, y: bottomY)) // Adjust the value as needed
        path.move(to: CGPoint(x: centerX + 4, y: bottomY)) // Adjust the value as needed
        
        path.addArc(center: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5), radius: 5, startAngle: Angle(degrees: 100), endAngle: Angle(degrees: 0), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY - 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 5))
        
        path.addArc(center: CGPoint(x: rect.maxX - 5, y: rect.minY + 5), radius: 5, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX + 5.9, y: rect.minY))
        
        return path
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}


struct TriangleBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

struct BlurView: UIViewRepresentable {
    
    let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        
        let blurEffect = UIBlurEffect(style: style)
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
