//
//  ParticipationAlertView.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 7/10/25.
//

import SwiftUI
import Utils
import Data

public struct ParticipationAlertView: View {
    
    private let components: ParticipationAlertViewComponents
    @Binding public var password: String
    public let onClose: () -> Void
    public let onJoin: () -> Void
    
    public init(
        components: ParticipationAlertViewComponents,
        textBinding: Binding<String>,
        onClose: @escaping () -> Void,
        onJoin: @escaping () -> Void
    ) {
        self.components = components
        self._password = textBinding
        self.onClose = onClose
        self.onJoin = onJoin
    }
    
    public var body: some View {
        content
    }
}

extension ParticipationAlertView {
    private var content: some View {
        VStack(spacing: 0) {
            
            titleView
                .padding(.top, SpacingHelper.sm.pixel)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            VStack(spacing: 0) {
                FlowLayout(spacing: 4, lineSpacing: 4) {
                    ForEach(components.hashTags, id: \.self) { item in
                        hashTagElementView(text: item)
                    }
                }
            }
            
            bottomSectionView
                .padding(.top, SpacingHelper.sm.pixel)
            
            if components.isHidden {
                passwordView
                    .frame(height: 50)
                    .padding(.top, SpacingHelper.md.pixel)
                    .padding(.bottom, 20)
            }
            
            buttonsView
                .padding(.top, SpacingHelper.md.pixel + 4)
        }
        .padding(16)
        .frame(maxWidth: 300)
        .background(GBColor.background1.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
                .foregroundStyle(GBColor.grey400.asColor)
        }
    }
}

extension ParticipationAlertView {
    
    
    private var titleView: some View {
        HStack(spacing: 0) {
            Text(components.title)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            Spacer()
            
            if components.isHidden {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        ImageHelper.secretRoomLogo
                            .asImage
                            .resizable()
                            .frame(width: 12, height: 12)
                        
                        Text("비밀방")
                            .foregroundStyle(GBColor.white.asColor)
                            .font(FontHelper.body5.font)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 9)
                }
                .background(GBColor.grey400.asColor)
                .clipShape(Capsule())
            }
        }
    }
    
    private var bottomSectionView: some View {
        HStack(alignment: .center, spacing: 0) {
            ImageHelper.group
                .asImage
                .resizable()
                .frame(width: 12, height: 12)
                .padding(.trailing, 4)
            
            Text(components.minMaxText)
                .font(FontHelper.body3.font)
                .foregroundStyle(GBColor.main.asColor)
            
            Text("참여중")
                .font(FontHelper.body3.font)
                .foregroundStyle(GBColor.main.asColor)
                .padding(.horizontal, 4)

            Spacer()
        }
    }
    
    /// 해시태그 자식뷰
    /// - Parameters:
    ///   - text: 해시태그
    /// - Returns: View
    private func hashTagElementView(text: String) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .font(FontHelper.body5.font)
                .foregroundStyle(GBColor.grey200.asColor)
                .padding(.trailing, SpacingHelper.xs.pixel)
            
        }
        .padding(.horizontal, SpacingHelper.sm.pixel)
        .padding(.vertical, SpacingHelper.xs.pixel)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(GBColor.grey400.asColor, lineWidth: 1)
        }
    }
    
    private var buttonsView: some View {
        HStack(spacing: SpacingHelper.md.pixel) {
            VStack {
                Text("취소")
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .font(FontHelper.btn2.font)
            .foregroundStyle(GBColor.white.asColor)
            .background(GBColor.grey400.asColor)
            .clipShape(Capsule())
            .asButton {
                onClose()
            }
            
            VStack {
                Text("참여")
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .font(FontHelper.btn2.font)
            .foregroundStyle(GBColor.white.asColor)
            .background(GBColor.main.asColor)
            .clipShape(Capsule())
            .asButton {
                onJoin()
            }
        }
    }
    
    private var passwordView: some View {
        let padding = SpacingHelper.md.pixel
        
        return VStack {
            DisablePasteTextField(
                text: $password,
                placeholder: "숫자 4자리를 입력해주세요",
                placeholderColor: GBColor.grey400.asColor,
                isSecureTextEntry: true,
                edge: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding),
                keyboardType: .numberPad) {
                    endTextEditing()
                }
                .background(GBColor.grey800.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(GBColor.grey600.asColor)
                }
        }
    }
}


#if DEBUG
@available(iOS 17, *)
#Preview {
    @Previewable @State var testText = ""
    
    ParticipationAlertView(
        components: ParticipationAlertViewComponents(
            title: "커피 값 모아 태산",
            hashTags: [
                "#배달줄이기",
                "#배민",
                "#야식맛나겠따",
                "#맛남",
                "#길어져라"
            ],
            isHidden: true,
            minMaxText: "2/10"
        ), textBinding: $testText
    ) {
        
    } onJoin: {
        
    }

}
#endif
