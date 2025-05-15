//
//  GenderEnum.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

enum GenderType: Equatable {
    case male
    case female
    
    var formattedString: String {
        switch self {
        case .male:
            return "MALE"
        case .female:
            return "FEMALE"
        }
    }
}
