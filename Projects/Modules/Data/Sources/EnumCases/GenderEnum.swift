//
//  GenderEnum.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

public enum GenderType: Equatable, Hashable {
    case male
    case female
    
    public var formattedString: String {
        switch self {
        case .male:
            return "MALE"
        case .female:
            return "FEMALE"
        }
    }
}
