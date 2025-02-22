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
    
    /// 챌린지 그룹 생성하기
    case challengeGroupCreate(request: ChallengeGroupCreateRequestDTO)
    
    /// 챌린지 그룹정보 가져오기
    case getChallengeGroupData(groupID: String)
    
    /// 챌린지 그룹 정보를 수정합니다.
    case modifyChallengeGroupData(groupID: String, requestDTO: ChallengeGroupCreateRequestDTO)
    
    /// 챌린지 그룹 삭제합니다. ( 내가 만든 챌린지만 삭제할 수 있습니다. )
    case deleteChallengeGroup(groupID: String)
    
    /// 챌린지 그룹 참여합니다.
    case joinChallengeGroup(groupID: String)
    
    /// 참여중인 챌린지 그룹 기록 보기
    case challengeGroupRecord(
        page: Int = 0,
        size: Int = 10,
        date: String? = nil, // 기록을 확인할 날짜입니다. 제공되지 않으면 오늘 기록을 가져옵니다. yyyy-MM-dd 형식입니다.
        status: String? = nil, // 필터링할 챌린지 상태입니다. 제공되지 않으면 모든 상태를 가져옵니다.
        created: Bool = false // 본인 생성만 여부
    )
    
    /// 참여중인 챌린지 그룹의 기록을 확인
    case challengeGroupRecordData(recordID: String, date: String?)
    
    /// 챌린지 그룹 기록 체크
    case challengeGroupRecordCheck(recordID: String)
    
    /// 특정 챌린지 그룹 참여 통계 확인
    case challengeGroupRecordStatus(groupID: String)
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
        case
                .challengeGroups,
                .getChallengeGroupData,
                .challengeGroupRecord,
                .challengeGroupRecordData,
                .challengeGroupRecordStatus:
            return .get
            
        case .challengeGroupCreate, .joinChallengeGroup, .challengeGroupRecordCheck:
            return .post
            
        case .modifyChallengeGroupData:
            return .put
            
        case .deleteChallengeGroup:
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
            
    // ChallengeGroup
        case .challengeGroups:
            return "/challengeGroups"
            
        case .challengeGroupCreate:
            return "/challengeGroups"
            
        case let .getChallengeGroupData(groupID):
            return "/challengeGroups/\(groupID)"
            
        case let .modifyChallengeGroupData(groupID, _):
            return "/challengeGroups/\(groupID)"
            
        case let .deleteChallengeGroup(groupID):
            return "/challengeGroups/\(groupID)"
            
        case let .joinChallengeGroup(groupID):
            return "/challengeGroups/\(groupID)/enroll"
            
        case .challengeGroupRecord:
            return "/challengeGroupRecords"
            
        case let .challengeGroupRecordData(recordID, _):
            return "/challengeGroupRecords/\(recordID)"
            
        case let .challengeGroupRecordCheck(recordID):
            return "/challengeGroupRecords/\(recordID)/check"
            
        case let .challengeGroupRecordStatus(groupID):
            return "/challengeGroupStat/\(groupID)"
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
            
        case let .challengeGroupRecord(page, size, date, status, created):
            var defaultValue: [String : Any] = [
                "page" : page,
                "size" : size,
                "date" : date ?? NSNull(),
                "status" : status ?? NSNull(),
                "created" : created,
            ]
            
            return defaultValue
            
        case let .challengeGroupRecordData(_, date):
            return ["date" : date ?? NSNull()]
            
        case .challengeGroupCreate,
                .getChallengeGroupData,
                .modifyChallengeGroupData,
                .deleteChallengeGroup,
                .joinChallengeGroup,
                .challengeGroupRecordCheck,
                .challengeGroupRecordStatus:
            
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
                .challengeRecordDelete,
                .challengeGroups,
                .getChallengeGroupData,
                .deleteChallengeGroup,
                .joinChallengeGroup,
                .challengeGroupRecord,
                .challengeGroupRecordData,
                .challengeGroupRecordCheck,
                .challengeGroupRecordStatus:
            
            return nil
            
        case let .challengeGroupCreate(request):
            return try? CodableManager.shared.jsonEncodingStrategy(request)
            
        case let .modifyChallengeGroupData(_, request):
            return try? CodableManager.shared.jsonEncodingStrategy(request)
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
            
            // ChallengeGroup
                .challengeGroups,
                .getChallengeGroupData,
                .deleteChallengeGroup,
                .joinChallengeGroup,
                .challengeGroupRecord,
                .challengeGroupRecordData,
                .challengeGroupRecordCheck,
                .challengeGroupRecordStatus:
            
            return .url
            
        case .challengeGroupCreate, .modifyChallengeGroupData:
            return .json
        }
    }
  
    var multipartFormData: MultipartFormData? {
        return nil
    }
}
