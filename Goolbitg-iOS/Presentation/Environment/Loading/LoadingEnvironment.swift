//
//  LoadingEnvironment.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import SwiftUI
import Combine
import ComposableArchitecture

final class LoadingEnvironment: @unchecked Sendable {
    
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    
    func loading(_ bool: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading.send(bool)
        }
    }
}

extension LoadingEnvironment {
    static let shared = LoadingEnvironment()
}

//extension LoadingEnvironment: EnvironmentKey {
//    static let defaultValue = LoadingEnvironment.shared
//}
//
//extension LoadingEnvironment: DependencyKey {
//    static let liveValue = LoadingEnvironment.shared
//}
//
//extension EnvironmentValues {
//    var loadingEnvironment: LoadingEnvironment {
//        get { self[LoadingEnvironment.self] }
//        set { self[LoadingEnvironment.self] = newValue }
//    }
//}
//
//extension DependencyValues {
//    var loadingEnvironment: LoadingEnvironment {
//        get { self[LoadingEnvironment.self] }
//        set { self[LoadingEnvironment.self] = newValue }
//    }
//}
