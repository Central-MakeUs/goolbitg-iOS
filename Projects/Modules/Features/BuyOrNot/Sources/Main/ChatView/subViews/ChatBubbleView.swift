//
//  ChatBubbleView.swift
//  FeatureBuyOrNot
//
//  Created by Jae hyung Kim on 3/31/26.
//

import SwiftUI
import Utils

public enum ChatBubbleType: Sendable {
    case left
    case right
}

public struct ChatBubbleView: View {
    public let type: ChatBubbleType
    public let text: String
    public let timeStr: String
    public let userName: String?
    
    public init(
        type: ChatBubbleType,
        text: String,
        timeStr: String,
        userName: String? = nil
    ) {
        self.type = type
        self.text = text
        self.timeStr = timeStr
        self.userName = userName
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if type == .left {
                leftBubble
                timeView
                Spacer()
            } else {
                Spacer()
                timeView
                rightBubble
            }
        }
    }
    
    private var timeView: some View {
        Text(timeStr)
            .font(FontHelper.body5.font)
            .foregroundStyle(GBColor.grey300.asColor)
    }
    
    private var leftBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let userName = userName {
                Text(userName)
                    .font(FontHelper.body3.font)
                    .foregroundStyle(GBColor.white.asColor)
            }
            Text(text)
                .font(FontHelper.body4.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(GBColor.grey600.asColor)
                .clipShape(ChatBubbleShape(type: type))
                .overlay {
                    if type == .left {
                        ChatBubbleShape(type: type)
                            .stroke(GBColor.grey500.asColor, lineWidth: 1)
                    }
                }
        }
    }
    
    private var rightBubble: some View {
        Text(text)
            .font(FontHelper.body4.font)
            .foregroundStyle(GBColor.white.asColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(GBColor.main.asColor)
            .clipShape(ChatBubbleShape(type: type))
    }
}

fileprivate struct ChatBubbleShape: Shape {
    let type: ChatBubbleType
    
    func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner
        if type == .left {
            corners = [.bottomLeft, .topRight, .bottomRight]
        } else {
            corners = [.topLeft, .bottomLeft, .bottomRight]
        }
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 8, height: 8)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    VStack {
        ChatBubbleView(type: .left, text: "지금 네이버 쇼핑에서 파는게 더 저렴함 https:/asdasdasdasdasdasdsad.com/", timeStr: "오전 11:38", userName: "거지굴비")
            .padding(.horizontal, 4)
        ChatBubbleView(type: .right, text: "오 좋은 정보 감사합니다 :D ", timeStr: "오전 11:38", userName: "TEST USER")
            .padding(.horizontal, 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
    
}
