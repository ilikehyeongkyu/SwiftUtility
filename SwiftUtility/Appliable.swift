//
//  Appliable.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 15/04/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public protocol Appliable {}

public extension Appliable {
    @discardableResult
    @inlinable func apply(_ block: (_ this: Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
    @inlinable func `let`<T>(_ block: (_ this: Self) throws -> T?) rethrows -> T? {
        return try block(self)
    }
}

extension NSObject: Appliable {}
extension Array: Appliable {}
extension Set: Appliable {}
extension String: Appliable {}
extension Int: Appliable {}
extension Double: Appliable {}
extension Float: Appliable {}
extension Bool: Appliable {}
// 필요에 따라 더 많은 타입을 나열
