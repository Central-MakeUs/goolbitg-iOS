//
//  UserRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/25/25.
//

import Foundation
import Alamofire

enum UserRouter {
    /// 현재 로그인한 유저 정보 반환
    case currentUserInfos
    /// 닉네임 중복 체크
    case nickNameCheck(reqeustModel: UserNickNameCheckReqeustModel)
    /// 사용자 개인정보 등록
    case userInfoRegist(reqeustModel: UserInfoRegistReqeustModel)
    /// 소비중독 체크 리스트 정보 등록
    case userCheckList(reqeustModel: CheckPayload)
    /// 소비습관 정보 등록
    case userHabit(reqeustModel: UserHabitRequestModel)
    /// 사용자 소비습관 패턴 등록
    case userPatternRegist(requestModel: UserPatternRequestModel)
    /// 회원정보 입력 상태 반환
    case userRegisterStatus
    /// 약관동의 정보 등록
    case agreement(requestModel: UserAgreeMentRequestModel)
    /// 주간 기록 보기 ( yyyy-MM-dd)
    case weeklyStatus(dateString: String? = nil)
    /// 푸시 알림 동의
    case agreePushNotification
}

extension UserRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .currentUserInfos, .userRegisterStatus, .weeklyStatus:
            return .get
            
        case .nickNameCheck, .userInfoRegist, .userCheckList, .userHabit, .userPatternRegist, .agreement, .agreePushNotification:
            return .post
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .currentUserInfos:
            return "/users/me"
        case .nickNameCheck:
            return "/users/nickname/check"
        case .userInfoRegist:
            return "/users/me/info"
        case .userCheckList:
            return "/users/me/checklist"
        case .userHabit:
            return "/users/me/habit"
        case .userPatternRegist:
            return "/users/me/pattern"
        case .userRegisterStatus:
            return "/users/me/registerStatus"
        case .agreement:
            return "/users/me/agreement"
        case .agreePushNotification:
            return "/challenges"
        case .weeklyStatus:
            return "/users/me/weeklyStatus"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .currentUserInfos, .userRegisterStatus, .agreePushNotification, .weeklyStatus:
            return [ "application/json" : "Content-Type" ]
        case .nickNameCheck, .userInfoRegist, .userCheckList, .userHabit, .userPatternRegist, .agreement:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .currentUserInfos, .nickNameCheck, .userInfoRegist, .userCheckList, .userHabit, .userPatternRegist, .userRegisterStatus, .agreement, .agreePushNotification:
            return nil
        case let .weeklyStatus(dateString):
            if let dateString {
                return [
                    "date" : dateString
                ]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .currentUserInfos, .userRegisterStatus, .agreePushNotification, .weeklyStatus:
            return nil
        case .nickNameCheck(let requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        case .userInfoRegist(let requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        case .userCheckList(let requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        case .userHabit(let requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        case .userPatternRegist(let requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        case let .agreement(requestModel):
            return try? CodableManager.shared.jsonEncodingStrategy(requestModel)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .currentUserInfos, .userRegisterStatus, .agreePushNotification, .weeklyStatus:
            return .url
        case .nickNameCheck, .userInfoRegist, .userCheckList, .userHabit, .userPatternRegist, .agreement:
            return .json
        }
    }
    
}
