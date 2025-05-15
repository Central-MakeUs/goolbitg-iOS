//
//  AgreeListCase.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/26/25.
//

import Foundation

enum AgreeListCase: Equatable, CaseIterable {
    case fourTeen
    case serviceAgree
    case privateAgree
    case adAgree
    
    var title: String {
        return switch self {
        case .fourTeen:
            TextHelper.overFourTeenText
        case .serviceAgree:
            TextHelper.serviceAgreementText
        case .privateAgree:
            TextHelper.privacyPolicyText
        case .adAgree:
            TextHelper.adAgreementText
        }
    }
}
