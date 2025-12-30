//
//  GBAlertViewComponents.swift
//  Data
//
//  Created by Jae hyung Kim on 5/23/25.
//

import Foundation

/// 공용 굴비잇기 팝업의 컴포넌트
public struct GBAlertViewComponents: Equatable, Hashable {
    
    /// ID가 필요하실 경우 이용해주세요
    public let ifNeedID: String

    /// 팝업 제목
    public let title: String
    
    /// 팝업 메시지
    public let message: String
    
    /// 팝업 취소 (좌측) 타이틀
    public let cancelTitle: String?
    
    /// 팝업 확인 (우측) 타이틀
    public let okTitle: String
    
    /// 팝업 스타일을 정의하세요
    public let style: AlertStyle
    
    public enum AlertStyle: Equatable, Hashable {
        case warning
        case normal
        case inTextFieldPassword
        case checkWithNormal
        case warningWithWarning
    }
    
    /// 공용 굴비잇기 팝업의 컴포넌트
    /// - Parameters:
    ///   - title: 팝업 제목
    ///   - message: 팝업 메시지
    ///   - cancelTitle: 팝업 취소 (좌측) 타이틀
    ///   - okTitle: 팝업 확인 (우측) 타이틀
    ///   - alertStyle: 팝업 스타일을 정의하세요
    ///   - ifNeedID: ID가 필요하실 경우 이용해주세요
    public init(
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
