//
//  String+Extension.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/11/25.
//

import Foundation

extension String {
    
    var removeNextLine: String {
        self.replacingOccurrences(of: "\n", with: "")
    }
    
    var removeSpacing: String {
        self.replacingOccurrences(of: " ", with: "")
    }
    
}
