//
//  CommonDTOBody.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/23/25.
//

import Foundation

struct CommonDTOBody<T: DTO>: DTO {
    
    var code: String?
    var message: String?
    var data: T?
    var success: Bool?
    
    enum CodingKeys: CodingKey {
        case code
        case message
        case data
        case success
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CommonDTOBody<T>.CodingKeys> = try decoder.container(keyedBy: CommonDTOBody<T>.CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: CommonDTOBody<T>.CodingKeys.code)
        self.message = try container.decodeIfPresent(String.self, forKey: CommonDTOBody<T>.CodingKeys.message)
        self.data = try container.decodeIfPresent(T.self, forKey: CommonDTOBody<T>.CodingKeys.data)
        self.success = try container.decodeIfPresent(Bool.self, forKey: CommonDTOBody<T>.CodingKeys.success)
    }
}
