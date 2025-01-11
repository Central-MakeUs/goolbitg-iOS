//
//  NickNameValidateEnum.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

enum NickNameValidateEnum {
    /// 비활성
    case none
    /// 검사 통과
    case active
    /// 이미 사용중일때
    case alreadyUse
    /// 형식에 어긋 났을때
    case denied
    /// 정해진 길이를 지키지 않았을때
    case limitOverOrUnder
}
