//
//  After.swift
//  Utils
//
//  Created by Jae hyung Kim on 9/13/25.
//

import UIKit

protocol After {}

extension After where Self: Any {
    
    @inlinable
    func after(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}


extension NSObject: After {}
extension UIEdgeInsets: After {}
extension UIOffset: After {}
extension UIRectEdge: After {}
