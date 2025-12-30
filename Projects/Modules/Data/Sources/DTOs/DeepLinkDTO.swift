//
//  DeepLinkDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/21/25.
//

import Foundation
import Domain

// MARK: - DeepLinkDTO
public struct DeepLinkDTO: DTO {
    let next: Next
}

// MARK: - Next
public struct Next: DTO {
    let href: String
    let type: String
}
