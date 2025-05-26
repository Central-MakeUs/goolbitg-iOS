//
//  Collection+Extension.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/18/25.
//

import Foundation

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map { startIndex in
            let adjustedStart = startIndex + 1 // 1부터 시작
            let adjustedEnd = Swift.min(adjustedStart + size - 1, count)
            return Array(self[(adjustedStart - 1)..<adjustedEnd])
        }
    }
}

public extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values: [T] = []
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}

public extension Collection {
    /// 인덱스 터짐 방지
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
