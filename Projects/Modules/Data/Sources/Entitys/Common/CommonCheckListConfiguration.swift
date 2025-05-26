//
//  CommonCheckListConfiguration.swift
//  Data
//
//  Created by Jae hyung Kim on 5/23/25.
//

import Foundation

public struct CommonCheckListConfiguration: Hashable, Identifiable {
    public let id: String
    public var currentState: Bool
    public let checkListTitle: String
    public let subText: String?
    
    public init(id: String = UUID().uuidString, currentState: Bool, checkListTitle: String, subText: String?) {
        self.id = id
        self.currentState = currentState
        self.checkListTitle = checkListTitle
        self.subText = subText
    }
}
