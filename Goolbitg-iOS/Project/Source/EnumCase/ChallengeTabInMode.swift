//
//  ChallengeTabInMode.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import Foundation

enum ChallengeTabInMode {
    case individuals
    case groups
    
    
    var title: String {
        switch self {
        case .groups:
            return "그룹"
        case .individuals:
            return "개인"
        }
    }
}
