//
//  ChallengeStatusCaseDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import Foundation
import Domain

public enum ChallengeStatusCaseDTO: String, DTO {
    case wait = "WAIT"
    case success = "SUCCESS"
    case fail = "FAIL"
}
