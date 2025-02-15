//
//  ChallengeRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Alamofire

enum ChallengeRouter {
    /// 챌린지 리스트
    case challengeList(page: Int = 0, size: Int = 10, spendingTypeID: Int? = nil)
    /// 챌린지 등록
    case challengeEnroll(challengeID: String)
    /// 참여중인 챌린지 기록 목록
    case challengeRecords(page: Int = 0, size: Int = 10, date: String, state: String? = nil)
    /// 3일치 작심삼일 기록 확인
    case challengeTripple(challengeID: String)
    /// 오늘의 챌린지 체크 성공 처리
    case challengeRecordCheck(challengeID: String)
    /// 챌린지 취소하기
    case challengeRecordDelete(ChallengeID: String)
}

extension ChallengeRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .challengeList, .challengeRecords, .challengeTripple:
            return .get
        case .challengeEnroll, .challengeRecordCheck:
            return .post
        case .challengeRecordDelete:
            return .delete
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .challengeList:
            return "/challenges"
            
        case let .challengeEnroll(challengeID):
            return "/challenges/\(challengeID)/enroll"
            
        case .challengeRecords:
            return "/challengeRecords"
            
        case let .challengeTripple(challengeID):
            return "/challengeTripple/\(challengeID)"
            
        case let .challengeRecordCheck(challengeID):
            return "/challengeRecords/\(challengeID)/check"
            
        case let .challengeRecordDelete(challengeID):
            return "/challengeRecords/\(challengeID)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        return [ "application/json" : "Content-Type" ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .challengeList(let page, let size, let spendingTypeID):
            var defaultValue = [
                "page" : page,
                "size" : size
            ]
            if let spendingTypeID {
                defaultValue["spendingTypeId"] = spendingTypeID
            }
            return defaultValue
            
        case let .challengeRecords(page, size, date, state):
            var defaultValue: [String : Any] = [
                "page" : page,
                "size" : size,
                "date" : date
            ]
            if let state {
                defaultValue["status"] = state
            }
            return defaultValue
            
        case .challengeEnroll, .challengeTripple, .challengeRecordCheck, .challengeRecordDelete:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case
                .challengeList,
                .challengeEnroll,
                .challengeRecords,
                .challengeTripple,
                .challengeRecordCheck,
                .challengeRecordDelete:
            return nil
            
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case
                .challengeList,
                .challengeEnroll,
                .challengeRecords,
                .challengeTripple,
                .challengeRecordCheck,
                .challengeRecordDelete:
            return .url
        }
    }
  
    var multipartFormData: MultipartFormData? {
        return nil
    }
}
