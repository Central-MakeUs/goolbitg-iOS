//
//  RevokeCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/6/25.
//

import Foundation
import Utils

public enum RevokeCase: Equatable, CaseIterable {
    case inconvenientToUse
    case notUsedOften
    case errorOccurred
    case wantNewAccount
    case other
    
    public var title: String {
        switch self {
        case .inconvenientToUse:
            return TextHelper.revokeFirstTitle
        case .notUsedOften:
            return TextHelper.revokeSecondTitle
        case .errorOccurred:
            return TextHelper.revokeThirdTitle
        case .wantNewAccount:
            return TextHelper.revokeFourthTitle
        case .other:
            return TextHelper.revokeFifthTitle
        }
    }
}
