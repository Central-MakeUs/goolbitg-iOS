//
//  RouterError.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation

public enum RouterError: Error {
    case urlFail(url: String = "")
    case decodingFail
    case encodingFail
    case retryFail
    case timeOut
    case serverMessage(APIErrorEntity)
    case unknown(errorCode: String)
    case cancel
    case errorModelDecodingFail
    case refreshFailGoRoot
}
