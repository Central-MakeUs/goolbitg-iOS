//
//  AppVersionUpdateManager.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 3/3/25.
//

import UIKit
import ComposableArchitecture

public final class AppVersionUpdateManager: Sendable {
    
    /// 현재 앱 버전
    public let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    /// 현재 빌드 버전
    private let currentBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    
    public static let appID = "6741732715"
    public static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/\(appID)"
    
    /// 앱스토어 최신버전 가져옵니다.
    private func fetchAppStoreVersion() async -> String? {
        
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(AppVersionUpdateManager.appID)&country=kr") else {
            Logger.error("AppStore URL Error")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                Logger.error("AppStore json Error")
                return nil
            }
            guard let results = jsonData["results"] as? [[String: Any]],
                  let latestVersion = results.first?["version"] as? String
            else {
                Logger.error("AppStore json results Error")
                return nil
            }
            return latestVersion
        }
        catch {
            Logger.error("AppStore json Error")
            return nil
        }
    }
    
    /// 앱스토어 버전을 가져옵니다.
    /// - Returns: nil로 올경우 확실하지 않음을 말합니다. True 일때 업데이트가 필요합니다.
    public func checkBuildVersionUpdate() async -> Bool? {
        let result = await fetchAppStoreVersion()
        let current = self.appVersion
        guard let result else { return nil }
        Logger.info("앱스토어 버전: " + result)
        Logger.info("현재 버전: " + current)
        let needUpdate = current.compare(result,options: .numeric) == .orderedAscending
        return needUpdate
    }
}

extension AppVersionUpdateManager: DependencyKey {
    public static let liveValue: AppVersionUpdateManager = AppVersionUpdateManager()
}

extension DependencyValues {
    public var appVersionUpdateManager: AppVersionUpdateManager {
        get { self[AppVersionUpdateManager.self] }
        set { self[AppVersionUpdateManager.self] = newValue }
    }
}


