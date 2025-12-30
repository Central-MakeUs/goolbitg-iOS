//
//  List+Extension.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/24/25.
//

import SwiftUI

struct ResetRowStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
    }
}

extension View {
    public func resetRowStyle() -> some View {
        self.modifier(ResetRowStyle())
    }
}
