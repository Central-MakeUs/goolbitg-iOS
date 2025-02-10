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
    
    // MARK: Challenge Group
    /// 챌린지 그룹 목록 가져오기
    ///
    /// searchText: 챌린지 제목 혹은 해시태그 / created: 본인 생성만 여부
    case challengeGroups(
        page: Int = 0,
        size: Int = 10,
        searchText: String? = nil, // 챌린지 제목 혹은 해시태그
        created: Bool = false // 본인 생성만 여부
    )
    
    
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
            
        // MARK: Challenge Group
        case .challengeGroups:
            return .get
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
            
        case .challengeGroups:
            return "/challengeGroups"
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
            
            // MARK: 챌린지 그룹
        case let .challengeGroups(page, size, searchText, created):
            var defaultValue: [String : Any] = [
                "page" : page,
                "size" : size,
                "created" : created
            ]
            
            if let searchText {
                defaultValue["search"] = searchText
            }
            
            return defaultValue
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
                .challengeRecordDelete,
                .challengeGroups:
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
                .challengeRecordDelete,
                .challengeGroups:
            return .url
        }
    }
    
}
