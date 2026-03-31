//
//  SpacingHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

public enum SpacingHelper {
    /// 4
    case xs
    /// 8
    case sm
    /// 16
    case md
    /// 24
    case lg
    /// 40
    case xl
    /// 80
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
