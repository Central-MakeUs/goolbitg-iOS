//
//  DeepLinkDTO.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/21/25.
//

import Foundation

// MARK: - DeepLinkDTO
struct DeepLinkDTO: DTO {
    let next: Next
}

// MARK: - Next
struct Next: DTO {
    let href: String
    let type: String
}
