//
//  RouterError.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/15/25.
//

import Foundation

enum RouterError: Error {
    case urlFail(url: String = "")
    case decodingFail
    case encodingFail
    case retryFail
    case timeOut
    case serverMessage(APIErrorEntity)
    case unknown
}
