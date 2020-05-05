//
//  CollectionUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 16/04/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Collection {
    @inlinable func forEachIndexed(_ body: (_ index: Int, _ element: Element) throws -> Void) rethrows {
        var index = 0
        try forEach { element in
            try body(index, element)
            index += 1
        }
    }
    
    @inlinable func mapIndexed<T>(_ body: (_ index: Int, _ element: Element) throws -> T) rethrows -> [T] {
        var index = 0
        return try map { element in
            let result = try body(index, element)
            index += 1
            return result
        }
    }
}

public extension Array {
    var lastIndex: Int {
        return count - 1
    }
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    @inlinable func indexOf(_ where: (_ element: Element) throws -> Bool) rethrows -> Int? {
        // swiftlint:disable identifier_name
        let i = try firstIndex(where: `where`)
        return i
    }
    
    func nextOrFirst(of index: Int) -> Element? {
        if isEmpty { return nil }
        var index = index + 1
        if index >= self.count { index = 0 }
        return self[index]
    }
    
    func prevOrLast(of index: Int) -> Element? {
        if isEmpty { return nil }
        var index = index - 1
        if index < 0 { index = count - 1 }
        return self[index]
    }
}
