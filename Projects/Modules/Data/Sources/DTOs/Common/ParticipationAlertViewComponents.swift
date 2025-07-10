//
//  ParticipationAlertViewComponents.swift
//  Data
//
//  Created by Jae hyung Kim on 7/10/25.
//

import Foundation

public struct ParticipationAlertViewComponents: Equatable, Hashable {
    public let title: String
    public let hashTags: [String]
    public let isHidden: Bool
    public let minMaxText: String
    
    public init(
        title: String,
        hashTags: [String],
        isHidden: Bool,
        minMaxText: String
    ) {
        self.title = title
        self.hashTags = hashTags
        self.isHidden = isHidden
        self.minMaxText = minMaxText
    }
}
