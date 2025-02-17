//
//  GBAlertView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/19/25.
//

import SwiftUI

struct GBAlertViewComponents: Equatable {
    let ifNeedID: String
    let title: String
    let message: String
    let cancelTitle: String?
    let okTitle: String
    let style: AlertStyle
    
    enum AlertStyle: Equatable {
        case warning
        case normal
        case inTextFieldPassword
        case checkWithNormal
        case warningWithWarning
    }
    
    init(
        title: String,
        message: String,
        cancelTitle: String? = nil,
        okTitle: String,
        alertStyle: AlertStyle = .normal,
        ifNeedID: String = ""
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.okTitle = okTitle
        self.style = alertStyle
        self.ifNeedID = ifNeedID
    }
}

struct GBAlertView: View {
    
    let model: GBAlertViewComponents
    let cancelTouch: (() -> Void)?
    let okTouch: (() -> Void)?
    
    @State
    private var passWordText = ""
    @State
    private var passWordFocus = false
    
    var body: some View {
        content
            .onChange(of: passWordText) { newValue in
                if newValue.count > 4 {
                    var text = newValue
                    text.removeLast()
                    passWordText = text
                }
            }
    }
    
    init(
        model: GBAlertViewComponents,
        cancelTouch: (() -> Void)?,
        okTouch: (() -> Void)?)
    {
        self.model = model
        self.cancelTouch = cancelTouch
        self.okTouch = okTouch
    }
}

extension GBAlertView {
    private var content: some View {
        VStack(spacing: 0) {
            contentInBoxView
                .padding(.all, SpacingHelper.md.pixel)
                
        }
        .background(GBColor.background1.asColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: min(UIScreen.main.bounds.width * 0.75, 320))
    }
    private var contentInBoxView: some View {
        VStack(spacing: 0) {
            
            topImageView
            
            Text(model.title)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
                .padding(.bottom, SpacingHelper.sm.pixel)
            
            Text(model.message)
                .multilineTextAlignment(.center)
                .font(FontHelper.caption2.font)
                .foregroundStyle(GBColor.grey100.asColor)
                .padding(.bottom, SpacingHelper.lg.pixel)
            
            if model.style == .inTextFieldPassword {
                DisablePasteTextField(
                    text: $passWordText,
                    isFocused: $passWordFocus,
                    placeholder: "숫자 4자리를 입력해주세요",
                    placeholderColor: GBColor.grey400.asColor,
                    isSecureTextEntry: true,
                    edge: UIEdgeInsets(
                        top: SpacingHelper.md.pixel,
                        left: SpacingHelper.md.pixel,
                        bottom: SpacingHelper.md.pixel,
                        right: SpacingHelper.md.pixel
                    ),
                    keyboardType: .numberPad) {
                        
                    }
                    .frame(height: 48)
                    .background(GBColor.grey600.asColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.bottom, SpacingHelper.lg.pixel)
            }
            
            bottomButtonsView
        }
    }
    
    private var bottomButtonsView: some View {
        HStack(spacing: SpacingHelper.md.pixel) {
            if let cancel =  model.cancelTitle {
                Text(cancel)
                    .font(FontHelper.btn2.font)
                    .foregroundStyle(GBColor.white.asColor)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(GBColor.grey400.asColor)
                    .clipShape(Capsule())
                    .asButton {
                        cancelTouch?()
                    }
            }
            
            Text(model.okTitle)
                .font(FontHelper.btn2.font)
                .foregroundStyle(GBColor.white.asColor)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(okButtonColor)
                .clipShape(Capsule())
                .asButton {
                    okTouch?()
                }
        }
    }
    
    private var topImageView: some View {
        VStack(spacing: 0) {
            if model.style == .checkWithNormal {
                Image(uiImage: ImageHelper.checkPop.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 55.5)
                    .padding(.vertical, SpacingHelper.md.pixel)
                
            } else if model.style == .warningWithWarning {
                Image(uiImage: ImageHelper.warningPop.image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 55.5)
                    .padding(.vertical, SpacingHelper.md.pixel)
                
            }
        }
    }
    
    private var okButtonColor: Color {
        switch model.style {
        case .warning, .warningWithWarning:
            return GBColor.error.asColor
        case .normal, .inTextFieldPassword, .checkWithNormal:
            return GBColor.main.asColor
        }
    }
}

#Preview {
    GBAlertView(model: GBAlertViewComponents(
        title: "챌린지 중간",
        message: "중단하면 지금까지의 기록이 사라져요.\n정말 중단하시겠습니까?",
        cancelTitle: "취소",
        okTitle: "중단",
        alertStyle: .inTextFieldPassword)) {
            
        } okTouch: {
            
        }
}

