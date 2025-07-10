//
//  ChallengeRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import Foundation
import Alamofire
import Domain

public enum ChallengeRouter {
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
    
    // MARK: GroupChallenge
    case groupChallengeList(
        page: Int = 0,
        size: Int = 10,
        searchText: String?,
        created: Bool = false,
        participating: Bool = false
    )
    /// GroupChallenge DETAIL
    case groupChallengeDetail(groupID: String)
    /// GroupChallenge Create
    case groupChallengeCreate(requestDTO: ChallengeGroupCreateRequestDTO)
    /// GroupChallenge Delete
    case groupChallengeDelete(groupID: String)
    /// GroupChallenge Modify (PUT)
    case groupChallengeModify(groupID: String, requestDTO: ChallengeGroupCreateRequestDTO)
    /// ChallengeGroup Join (Post)
//    case groupChallengeJoin(groupID: String)
}

extension ChallengeRouter: Router {
    public var method: HTTPMethod {
        switch self {
        case .challengeList, .challengeRecords, .challengeTripple, .groupChallengeList, .groupChallengeDetail:
            return .get
        case .challengeEnroll, .challengeRecordCheck, .groupChallengeCreate:
            return .post
        case .challengeRecordDelete, .groupChallengeDelete:
            return .delete
        case .groupChallengeModify:
            return .put
        }
    }
    
    public var version: String {
        return "/v1"
    }
    
    public var path: String {
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
            
            // MARK: Group
        case .groupChallengeList:
            return "/challengeGroups"
            
        case let .groupChallengeDetail(groupID):
            return "/challengeGroups/\(groupID)"
            
        case .groupChallengeCreate:
            return "/challengeGroups"
            
        case let .groupChallengeDelete(groupID):
            return "/challengeGroups/\(groupID)"
            
        case let .groupChallengeModify(groupID, _):
            return "/challengeGroups/\(groupID)"
        }
    }
    
    public var optionalHeaders: HTTPHeaders? {
        return [ "application/json" : "Content-Type" ]
    }
    
    public var parameters: Parameters? {
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
            var defaultValue: [String: any Any & Sendable] = [
                "page" : page,
                "size" : size,
                "date" : date
            ]
            if let state {
                defaultValue["status"] = state
            }
            
            return defaultValue
            
        case let .groupChallengeList(page, size, searchText, created, participating):
            var defaultValue: [String: any Any & Sendable] = [
                "page" : page,
                "size" : size,
                "created" : created,
                "participating": participating
            ]
            
            if let searchText {
                defaultValue["search"] = searchText
            }
            
            return defaultValue
            
        case
                .challengeEnroll,
                .challengeTripple,
                .challengeRecordCheck,
                .challengeRecordDelete,
                .groupChallengeDetail,
                .groupChallengeCreate,
                .groupChallengeDelete,
                .groupChallengeModify :
            
            return nil
        }
    }
    
    public var body: Data? {
        switch self {
        case
                .challengeList,
                .challengeEnroll,
                .challengeRecords,
                .challengeTripple,
                .challengeRecordCheck,
                .challengeRecordDelete,
                .groupChallengeList,
                .groupChallengeDetail ,
                .groupChallengeDelete :
            
            return nil
            
        case let .groupChallengeCreate(requestDTO):
            let data = try? CodableManager.shared.jsonEncodingStrategy(requestDTO)
            return data
            
        case let .groupChallengeModify(_, requestDTO):
            let data = try? CodableManager.shared.jsonEncodingStrategy(requestDTO)
            return data
        }
    }
    
    public var encodingType: EncodingType {
        switch self {
        case
                .challengeList,
                .challengeEnroll,
                .challengeRecords,
                .challengeTripple,
                .challengeRecordCheck,
                .challengeRecordDelete,
                .groupChallengeList,
                .groupChallengeDetail,
                .groupChallengeDelete:
            
            return .url
            
        case .groupChallengeCreate, .groupChallengeModify:
            return .json
        }
    }
  
    public var multipartFormData: MultipartFormData? {
        return nil
    }
}
