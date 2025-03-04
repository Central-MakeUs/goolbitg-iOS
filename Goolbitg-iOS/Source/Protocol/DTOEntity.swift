//
//  DTOEntity.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation

protocol DTO: Decodable, Sendable {}

protocol Entity: Equatable, Hashable {}
