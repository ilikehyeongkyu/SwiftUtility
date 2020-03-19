//
//  DictionaryUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 14/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AdvancedDictionary {
    private var dictionary: [String: Any?] = [:]
    
    public init(_ dictionary: [String: Any?]) {
        self.dictionary = dictionary
    }
    
    open subscript<T: Any>(index: String) -> T? {
        get {
            guard let optionalValue = dictionary[index] else {
                return nil
            }
            
            guard let value = optionalValue else {
                return nil
            }
            
            let stringValue = "\(value)"
            
            let type = T.self
            var result: Any?
            if type == String.self {
                result = value as? String ?? stringValue
            } else if type == Bool.self {
                result = value as? Bool
                    ?? stringValue.asBool
            } else if type == Int.self {
                result = value as? Int
                    ?? stringValue.asInt
            } else if type == Double.self {
                result = value as? Double
                    ?? stringValue.asDouble
            } else if type == Float.self {
                result = value as? Float
                    ?? stringValue.asFloat
            } else if type == JSON.self {
                result = value as? JSON
                    ?? stringValue.asJSON()
            } else {
                print("AdvancedDictionary is not support type: \(T.self)")
            }
            
            if result != nil {
                // swiftlint:disable force_cast
                return (result as! T)
            }
            
            return nil
        }
        set(newValue) {
            dictionary[index] = newValue
        }
    }
}

public extension Dictionary where Key == String, Value == Any {
    func advanced() -> AdvancedDictionary {
        return AdvancedDictionary(self)
    }
}

public extension Dictionary where Key == String, Value == Any? {
    func advanced() -> AdvancedDictionary {
        return AdvancedDictionary(self)
    }
}
