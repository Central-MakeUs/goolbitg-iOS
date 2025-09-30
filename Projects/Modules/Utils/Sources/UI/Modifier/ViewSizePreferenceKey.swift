//
//  ViewSizePreferenceKey.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/28/25.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static let defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}
