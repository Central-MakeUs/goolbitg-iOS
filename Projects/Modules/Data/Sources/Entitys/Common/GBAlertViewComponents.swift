//
//  GBAlertViewComponents.swift
//  Data
//
//  Created by Jae hyung Kim on 5/23/25.
//

import Foundation

public struct GBAlertViewComponents: Equatable {
    public let ifNeedID: String
    public let title: String
    public let message: String
    public let cancelTitle: String?
    public let okTitle: String
    public let style: AlertStyle
    
    public enum AlertStyle: Equatable {
        case warning
        case normal
        case inTextFieldPassword
        case checkWithNormal
        case warningWithWarning
    }
    
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
