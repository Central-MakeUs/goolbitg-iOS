//
//  ThreadCheckable.swift
//  Network
//
//  Created by Jae hyung Kim on 5/21/25.
//

import Foundation

public protocol ThreadCheckable {}

public extension ThreadCheckable {
    func checkedMainThread() {
        print(Thread.current)
        if OperationQueue.current == OperationQueue.main {
            print(#function, "OperationQueue: Running on the main thread")
        } else {
            print(#function, "OperationQueue: Running on a background thread")
        }
    }
}
