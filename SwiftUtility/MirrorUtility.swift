//
//  MirrorUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 14/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Mirror {
    var compactProperties: [String: Any] {
        var properties: [String: Any] = [:]
        children.forEach { (child) in
            guard let label = child.label else { return }
            let value = child.value
            switch value {
            // swiftlint:disable syntactic_sugar
            case Optional<Any>.none:
                break
            // swiftlint:disable syntactic_sugar
            case Optional<Any>.some(let someValue):
                properties[label] = someValue
            default:
                break
            }
        }
        if let superclassMirror = superclassMirror {
            properties.merge(
                superclassMirror.compactProperties,
                uniquingKeysWith: { current, _ in current }
            )
        }
        return properties
    }
    
    var jsonSupportedProperties: [String: Any] {
        var properties = self.compactProperties
        properties = properties.compactMapValues { (value) -> Any? in
            if let dictionary = value as? [String: MirroringSupport] {
                if dictionary.isEmpty { return nil }
                return dictionary.mapValues { Mirror(reflecting: $0).jsonSupportedProperties }
            } else if let array = value as? [MirroringSupport] {
                if array.isEmpty { return nil }
                return array.map { Mirror(reflecting: $0).jsonSupportedProperties }
            } else if let value = value as? MirroringSupport {
                return Mirror(reflecting: value).jsonSupportedProperties
            } else {
                return value as? String
                    ?? value as? Int
                    ?? value as? Double
                    ?? value as? Float
                    ?? value as? Bool
                    ?? "\(value)"
            }
        }
        return properties
    }
    
    var jsonStringFromProperties: String {
        let data = (try? JSONSerialization.data(
            withJSONObject: self.jsonSupportedProperties,
            options: .prettyPrinted)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? "\(#function) error."
        return "\(self.subjectType)@\(jsonString)"
    }
}

public protocol MirroringSupport: CustomStringConvertible {}

public extension MirroringSupport {
    var description: String {
        return Mirror(reflecting: self).jsonStringFromProperties
    }
}
