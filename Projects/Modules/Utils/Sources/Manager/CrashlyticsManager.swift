//
//  CrashlyticsManager.swift
//  Data
//
//  Created by Jae hyung Kim on 6/23/25.
//

import FirebaseCrashlytics

public let CrashlyticsManager = _CrashlyticsManager.shared

public final class _CrashlyticsManager: Sendable {
    
    public func sendMessage(message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    public func record(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    private init() {}
}

extension _CrashlyticsManager {
    static let shared: _CrashlyticsManager = _CrashlyticsManager()
}
