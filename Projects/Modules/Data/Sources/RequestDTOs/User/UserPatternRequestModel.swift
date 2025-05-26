//
//  UserPatternRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

public struct UserPatternRequestModel: Encodable {
    /*
     primeUseDay
     다음 요소중 하나:

     monday
     tuesday
     wednesday
     thursday
     friday
     saturday
     sunday
     primeUseTime
     hh:mm:ss 형식의 스트링. 초 부분은 무시됩니다.
     */
    public let primeUseDay: String
    public let primeUseTime: String
    
    public init(primeUseDay: String, primeUseTime: String) {
        self.primeUseDay = primeUseDay
        self.primeUseTime = primeUseTime
    }
}
