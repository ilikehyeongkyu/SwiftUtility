//
//  SequenceUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 14/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Array {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var isCompactEmpty: Bool {
        return self.compactMap({ $0 }).isEmpty
    }
}

public extension Sequence where Element: Hashable {
    func toSet<Element>() -> Set<Element> {
        // swiftlint:disable force_cast
        return Set(self) as! Set<Element>
    }
}
