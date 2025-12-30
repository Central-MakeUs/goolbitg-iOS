//
//  FireBaseLog.swift
//  Domain
//
//  Created by Jae hyung Kim on 6/24/25.
//

import Foundation

public protocol FireBaseLog: Sendable {
    var eventName: String { get }
    var parameters: [String: any Sendable] { get }
    var userID: String? { get }
    var logType: FireBaseLogType { get }
}

public enum FireBaseLogType: Sendable {
    case login
}
