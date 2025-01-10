//
//  GBReducer.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

protocol GBReducer {
    associatedtype ViewCycleType
    
    associatedtype ViewEventType
    
    associatedtype DataTransType
}
