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
    
    /// info
    open func i(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("info:")
        print(message)
        print("\(file)@\(function):\(line)")
    }
    
    /// debug
    open func d(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("debug:")
        print(message)
        print("\(file)@\(function):\(line)")
    }
    
    /// warning
    open func w(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("warning:")
        print(message)
        print("\(file)@\(function):\(line)")
    }
    
    /// error
    open func e(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("error:")
        print(message)
        print("\(file)@\(function):\(line)")
    }
    
    /// error
    open func e(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        printDate()
        print("error:")
        print(error.localizedDescription)
        print("\(file)@\(function):\(line)")
    }
    
    open func printDate() {
        print(dateFormatter.string(from: Date()))
    }
}
