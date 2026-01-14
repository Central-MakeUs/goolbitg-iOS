//
//  CryptoRepository.swift
//  Data
//
//  Created by Jae hyung Kim on 1/9/26.
//

import Foundation
import CryptoKit

struct CryptoRepository {
    /// MakeSymmetricKey
    /// default: 256 bits Key
    /// - Returns: SymmetricKey
    static func createKey(_ size: SymmetricKeySize = .bits256) -> SymmetricKey {
        return SymmetricKey(size: size)
    }
    
    /// Copy Data From Key
    /// - Parameter key: SymmetricKey
    /// - Returns: Data
    static func exportRawKey(_ key: SymmetricKey) -> Data {
        return key.withUnsafeBytes { Data($0) }
    }
    
    /// Raw key Data -> CryptoKit_SymmetricKey
    /// - Parameter data: Data
    /// - Returns: SymmetricKey
    static func importRawKey(_ data: Data) -> SymmetricKey {
        return SymmetricKey(data: data)
    }
}
