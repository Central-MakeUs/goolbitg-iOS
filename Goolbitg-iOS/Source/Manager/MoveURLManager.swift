//
//  MoveURLManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/1/25.
//

import UIKit
import ComposableArchitecture

final class MoveURLManager: Sendable {
    
    enum MoveURLCase {
        case inquiry
        case privacy
        case service
        
        var url: URL? {
            switch self {
            case .inquiry:
                URL(string: "https://deep-twine-18f.notion.site/18b5dccdfca280ad8c49c5a75766dc64")
            case .privacy:
                URL(string: "https://deep-twine-18f.notion.site/18b5dccdfca2805986d4ff2aa8eff647?pvs=4")
            case .service:
                URL(string: "https://deep-twine-18f.notion.site/18b5dccdfca280128c3cc79c516a5b9d?pvs=4")
            }
        }
    }
    @discardableResult
    func moveURL(caseOf: MoveURLCase) -> Bool {
        guard let url = caseOf.url else { return false }
            return moveToSafari(url: url)
    }
    
    /// 사파리 로 이동합니다.
    /// - Parameter url: 이동할 URL
    /// - Returns: 성공여부
    @discardableResult
    func moveToSafari(url: URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        } else {
            return false
        }
    }
}

extension MoveURLManager: DependencyKey {
    static let liveValue: MoveURLManager = MoveURLManager()
}

extension DependencyValues {
    var moveURLManager: MoveURLManager {
        get { self[MoveURLManager.self] }
        set { self[MoveURLManager.self] = newValue }
    }
}
