//
//  LogUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 14/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

open class LogUtility {
    public init() {}
    
    open lazy var dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()
    
    /// debug
    open func d(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("debug:")
        print("\(file)@\(function):\(line)")
        print(message)
    }
    
    /// warning
    open func w(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("warning:")
        print("\(file)@\(function):\(line)")
        print(message)
    }
    
    /// error
    open func e(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("error:")
        print("\(file)@\(function):\(line)")
        print(message)
    }
    
    open func printDate() {
        print(dateFormatter.string(from: Date()))
    }
}
