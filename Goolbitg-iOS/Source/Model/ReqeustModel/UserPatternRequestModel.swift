//
//  UserPatternRequestModel.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation

struct UserPatternRequestModel: Encodable {
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
    let primeUseDay: String
    let primeUseTime: String
    
}
