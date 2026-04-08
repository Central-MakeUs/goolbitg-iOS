//
//  RealmActor.swift
//  Data
//
//  Created by Atlas on 4/7/26.
//

import Foundation
import RealmSwift

/// Realm 접근을 직렬화하는 글로벌 액터
/// - 모든 Realm read/write 는 이 액터 컨텍스트에서 수행한다.
/// - 외부에는 Sendable value 타입만 노출한다.
@globalActor
public actor RealmActor {
    public static let shared = RealmActor()
    private init() {}
}
