//
//  Combine+Extension.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/10/25.
//

import Combine

extension Publisher where Failure == Never {
    
    func sinkTask(receiveValue: @escaping (Self.Output) async throws -> Void) -> AnyCancellable {
        sink { value in
            Task {
                try await receiveValue(value)
            }
        }
    }
}

extension Publisher {
    
    // MARK: [weak self] Streaming
    func guardSelf<ob: AnyObject>(
        _ object: ob
    ) -> Publishers.CompactMap
    <Self, (ob,Self.Output)> {
        
        return compactMap { [weak object] output in
            guard let object else {
                return nil
            }
            return (object, output)
        }
    }
    
    // MARK: [unownedSelf] Streaming
    func guardUnownedSelf<ob: AnyObject> (
        _ object: ob
    ) -> Publishers.Map
    <Self, (ob,Self.Output)> {
        
        return map { [unowned object] output in
            return ( object, output )
        }
    }
}
