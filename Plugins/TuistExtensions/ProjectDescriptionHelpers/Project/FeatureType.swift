//
//  FeatureType.swift
//  TuistExtensions
//
//  Created by Jae hyung Kim on 5/19/25.
//

import Foundation

public enum FeatureType: String, CaseIterable {
    case Common
    case Tab
    case Intro
    case Home
    case Challenge
    case BuyOrNot
    case MyPage
    
    public var leadingPath: String {
        return Self.leadingPathString
    }
    
    public static let leadingPathString = "Projects/Modules/Features/"
}
