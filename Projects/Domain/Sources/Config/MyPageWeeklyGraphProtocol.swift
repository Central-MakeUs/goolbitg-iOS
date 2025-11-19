//
//  MyPageWeeklyGraphProtocol.swift
//  Domain
//
//  Created by Jae hyung Kim on 11/19/25.
//

import Foundation

public protocol MyPageWeeklyGraphProtocol {
    var title: String { get }
    var count: Int { get }
    var isRecommend: Bool { get }
    var barStyle: GraphBarStyle { get }
}

public enum GraphBarStyle: Equatable, Hashable {
    case grey
    case mainColor
    case dotStyleForRecommend
}
