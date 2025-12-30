//
//  UserAgreeMentRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/26/25.
//

import Foundation

public struct UserAgreeMentRequestModel: Encodable {
    public let agreement1: Bool
    public let agreement2: Bool
    public let agreement3: Bool
    public let agreement4: Bool
    
    public init(agreement1: Bool, agreement2: Bool, agreement3: Bool, agreement4: Bool) {
        self.agreement1 = agreement1
        self.agreement2 = agreement2
        self.agreement3 = agreement3
        self.agreement4 = agreement4
    }
}
