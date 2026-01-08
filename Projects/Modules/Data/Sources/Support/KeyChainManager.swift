//
//  KeyChainManager.swift
//  Data
//
//  Created by Jae hyung Kim on 1/9/26.
//

//
//  KeyChainManager.swift
//  Data
//
//  Created by Jae hyung Kim on 1/9/26.
//

import Foundation
import Security

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case invalidData
    case itemNotFound
    case duplicateItem
}

public enum KeychainSync {
    case localOnly        // iCloud 동기화 안 함
    case iCloudSync       // iCloud Keychain 동기화
}

struct KeyChainManager {
    
    /// Keychain의 네임스페이스
    private static let service = Bundle.main.bundleIdentifier ?? "app"
    
    static func save(
        value: String,
        for account: String,
        isForce: Bool = false,
        sync: KeychainSync = .localOnly
    ) throws(KeychainError) {
        
        guard let data = value.data(using: .utf8) else {
            throw .invalidData
        }
        try save(value: data, for: account, isForce: isForce, sync: sync)
    }
    
    static func save(
        value: Data,
        for account: String,
        isForce: Bool = false,
        sync: KeychainSync = .localOnly
    ) throws(KeychainError) {
        
        // 강제 제거후 추가
        if isForce {
            try? delete(for: account, sync: sync)
            
            let addQuery = makeQuery(account: account, value: value, sync: sync)
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw .unexpectedStatus(addStatus) }
            return
        }
        
        // 업데이트 우선: 있으면 update, 없으면 add
        let baseQuery = makeBaseQuery(account: account, sync: sync)
        
        // 업데이트할 값
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: value
        ]
        
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributesToUpdate as CFDictionary)
        
        if updateStatus == errSecSuccess { return }
        
        if updateStatus != errSecItemNotFound { throw .unexpectedStatus(updateStatus) }
        
        // 없으면 새로 추가
        let addQuery = makeQuery(account: account, value: value, sync: sync)
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw .unexpectedStatus(addStatus) }
    }
    
    // MARK: - Read
    
    static func readData(
        for account: String,
        sync: KeychainSync = .localOnly
    ) throws(KeychainError) -> Data {
        
        var query: [String: Any] = makeBaseQuery(account: account, sync: sync)
        
        // 값 돌려주는 옵션들
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound { throw.itemNotFound }
        guard status == errSecSuccess else { throw .unexpectedStatus(status) }
        
        guard let data = item as? Data else { throw .invalidData }
        return data
    }
    
    static func readString(
        for account: String,
        sync: KeychainSync = .localOnly
    ) throws(KeychainError) -> String {
        
        let data = try readData(for: account, sync: sync)
        guard let value = String(data: data, encoding: .utf8) else { throw .invalidData }
        
        return value
    }
    
    // MARK: - Delete
    
    static func delete(
        for account: String,
        sync: KeychainSync = .localOnly
    ) throws(KeychainError) {
        
        let query: [String: Any] = makeBaseQuery(account: account, sync: sync)
        let status = SecItemDelete(query as CFDictionary)
        
        // 이미 없으면(errSecItemNotFound) 삭제 성공
        if status != errSecSuccess && status != errSecItemNotFound {
            throw .unexpectedStatus(status)
        }
    }
}

// MARK: - Query Builders
extension KeyChainManager {
    
    /// iCloud 동기화 여부를 Keychain Query에 반영하는 값
    private static func synchronizableValue(_ sync: KeychainSync) -> CFBoolean {
        switch sync {
        case .localOnly: return kCFBooleanFalse
        case .iCloudSync: return kCFBooleanTrue
        }
    }
    
    /// Add용 Query(저장할 value 포함)
    private static func makeQuery(account: String, value: Data, sync: KeychainSync) -> [String: AnyObject] {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword as AnyObject, // "generic password" 항목
            kSecAttrService as String: service as AnyObject,           // 네임스페이스
            kSecAttrAccount as String: account as AnyObject,           // 키 이름(식별자)
            kSecValueData as String: value as AnyObject,               // 실제 저장 값(Data)
            
            // iCloud Keychain 동기화 여부
            // Add/Update/Read/Delete 모두 동일 조건으로 넣어야 "같은 아이템"을 찾음
            kSecAttrSynchronizable as String: synchronizableValue(sync)
        ]
        return query
    }
    
    /// Update/Read/Delete용 Query(값 제외: "어떤 항목인지"만 지정)
    private static func makeBaseQuery(account: String, sync: KeychainSync) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            
            // iCloud Keychain 동기화 여부 (검색 조건에 포함)
            kSecAttrSynchronizable as String: synchronizableValue(sync)
        ]
    }
}
