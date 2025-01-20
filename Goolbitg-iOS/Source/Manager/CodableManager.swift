//
//  CodableManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/7/25.
//

import Foundation

final class CodableManager: Sendable {
    
    static let shared = CodableManager()
    
    private init () {}
    
    private let encoder = JSONEncoder()
    private let strategy = JSONEncoder()
    private let decoder = JSONDecoder()
}

extension CodableManager {
    
    func jsonEncoding<T: Encodable>(from value: T) throws -> Data {
        return try encoder.encode(value)
    }
    
    func jsonEncodingStrategy(_ target: Encodable) throws -> Data? {
        strategy.keyEncodingStrategy = .useDefaultKeys
        return try encoder.encode(target)
    }
    
    func jsonDecoding<T:Decodable>(model: T.Type, from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
    
    func toJSONSerialization(data: Data?) -> Any? {
        do {
            guard let data else {
                return nil
            }
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            return nil
        }
    }
}
