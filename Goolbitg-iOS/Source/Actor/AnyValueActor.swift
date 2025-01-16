//
//  AnyValueActor.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation

/// 어떤 타입이든 Actor화 시킵니다.
final actor AnyValueActor<Value> {
    private let defaultValue: Value
    private var value: Value
    
    init(_ value: @autoclosure @Sendable () throws -> Value)  rethrows {
        let value = try value()
        self.defaultValue = value
        self.value = value
    }
}

extension AnyValueActor {
    /// withValue: 값을 inout 을 통해 외부에서 수정하게 합니다. ( discardableResult )
    @discardableResult
    func withValue<T: Sendable>(
        _ operation: @Sendable (inout Value) throws -> T
    ) rethrows -> T {
        var value = self.value
        defer { self.value = value }
        return try operation(&value)
    }
    
    /// setValue: 새로운 값을 지정합니다. ( 단, 타입일치 )
    func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
        self.value = try newValue()
    }
    
    /// resetValue: 처음 지정한 값으로 초기화 합니다.
    func resetValue() {
        value = defaultValue
    }
}
