//
//  FireBaseLogModel.swift
//  Data
//
//  Created by Jae hyung Kim on 6/24/25.
//

import Foundation
import Domain

public struct FireBaseLogModel: FireBaseLog {
    public var eventName: String
    
    public var parameters: [String : any Sendable]
    
    public var userID: String?
    
    public var logType: FireBaseLogType
    
    public init(
        eventName: String,
        parameters: [String : any Sendable],
        userID: String? = nil,
        logType: FireBaseLogType
    ) {
        self.eventName = eventName
        self.parameters = parameters
        self.userID = userID
        self.logType = logType
    }
}
