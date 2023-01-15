//
//  DoubleUtility.swift
//  SwiftUtility
//
//  Created by Hyeongkyu on 2020/03/20.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Double {
    func multiply(_ value: Int) -> Double? {
        return self * Double(value)
    }
    
    var asFloat: Float? {
        return Float(self)
    }
    
    var asString: String {
        return String(self)
    }
    
    func asMeterToDistance() -> String {
        if self >= 1000 {
            return String(format: "%.1fkm", self / 1000.0)
        } else {
            return String(format: "%.1fm", self)
        }
    }
}
