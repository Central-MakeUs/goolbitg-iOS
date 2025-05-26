//
//  SpacingHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

public enum SpacingHelper {
    case xs
    case sm
    case md
    case lg
    case xl
    case xxl
    
    public var pixel: CGFloat {
        switch self {
        case .xs:
            return 4
        case .sm:
            return 8
        case .md:
            return 16
        case .lg:
            return 24
        case .xl:
            return 40
        case .xxl:
            return 80
        }
    }
}
