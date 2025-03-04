//
//  BuyOrNotRouter.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import Foundation
import Alamofire

enum BuyOrNotRouter {
    /// 살까 말까 포스트 목록 가져오기
    case buyOtNots(page: Int, size: Int, created: Bool)
    /// 살까 말까 포스트 등록하기
    case butOrNotsReg(requestDTO: BuyOrNotRequestModel)
    /// 살까 말까 포스트 수정하기
    case buyOtNotsModify(postID: String, requestDTO: BuyOrNotRequestModel)
    /// 살까말까 포스트 정보 확인
    case buyOrNotDetail(postID: String)
    /// 살까말까 포스트 삭제
    case buyOrNotDelete(postID: String)
    /// 살까말까 투표
    case buyOrNotVote(postID: String, requestDTO: BuyOrNotVoteRequestDTO)
    /// 살까말까 신고
    case buyOrNotReport(postID: String, reason: String)
}

extension BuyOrNotRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .buyOtNots, .buyOrNotDetail:
            return .get
        case .butOrNotsReg, .buyOrNotVote, .buyOrNotReport:
            return .post
        case .buyOtNotsModify:
            return .put
        case .buyOrNotDelete:
            return .delete
        }
    }
    
    var version: String {
        return "/v1"
    }
    
    var path: String {
        switch self {
        case .buyOtNots, .butOrNotsReg:
            return "/buyOrNots"
            
        case let .buyOtNotsModify(postID, _):
            return "/buyOrNots/\(postID)"
            
        case .buyOrNotDetail(let postID):
            return "/buyOrNots/\(postID)"
            
        case .buyOrNotDelete(let postID):
            return "/buyOrNots/\(postID)"
            
        case .buyOrNotVote(let postID, _):
            return "/buyOrNots/\(postID)/vote"
            
        case .buyOrNotReport(let postID, _):
            return "buyOrNots/\(postID)/report"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        return [ "application/json" : "Content-Type" ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .buyOtNots(let page, let size, let created):
            let defaultValue: [String: any Any & Sendable] = [
                "page" : page,
                "size" : size,
                "created" : created
            ]
            return defaultValue
        case .butOrNotsReg, .buyOtNotsModify, .buyOrNotDetail, .buyOrNotDelete, .buyOrNotVote, .buyOrNotReport:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .buyOtNots, .buyOrNotDetail, .buyOrNotDelete:
            return nil
            
        case .butOrNotsReg(let requestDTO):
            return try? CodableManager.shared.jsonEncodingStrategy(requestDTO)
            
        case .buyOtNotsModify(_ , let requestDTO):
            return try? CodableManager.shared.jsonEncodingStrategy(requestDTO)
        
        case .buyOrNotVote(_, let requestDTO):
            return try? CodableManager.shared.jsonEncodingStrategy(requestDTO)
            
        case .buyOrNotReport(_, let reason):
            return try? CodableManager.shared.jsonEncodingStrategy(ReasonRequestDTO(reason: reason))
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .buyOtNots, .buyOrNotDetail, .buyOrNotDelete:
            return .url
        case .butOrNotsReg, .buyOtNotsModify, .buyOrNotVote, .buyOrNotReport:
            return .json
        }
    }
    
    var multipartFormData: MultipartFormData? {
        return nil
    }
}

struct ReasonRequestDTO: Encodable {
    let reason: String
}

