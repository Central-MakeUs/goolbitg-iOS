//
//  AnyIdentifier.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/25/25.
//

import Foundation

/// Identifier 구조체로 변환 시킵니다.
public struct AnyIdentifier<T: Hashable>: Identifiable, Hashable, RawRepresentable {
    public typealias ID = T
    public typealias RawValue = T

    public let rawValue: T

    public var id: T { rawValue }

    public init(_ rawValue: T) {
        self.rawValue = rawValue
    }

    public init(rawValue: T) {
        self.rawValue = rawValue
    }
}

extension AnyIdentifier: Codable where T: Codable {}
extension AnyIdentifier: Sendable where T: Sendable {}

extension AnyIdentifier: CustomStringConvertible {
    public var description: String { String(describing: rawValue) }
}
