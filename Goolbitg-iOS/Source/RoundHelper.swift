//
//  RoundHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

enum RoundHelper {
    case xs
    case sm
    case md
    case lg
    case full
    
    var pixel: CGFloat {
        switch self {
        case .xs:
            return 4
        case .sm:
            return 8
        case .md:
            return 16
        case .lg:
            return 24
        case .full:
            return 100
        }
    }
}
