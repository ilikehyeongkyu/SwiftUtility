//
//  Error.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 23/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
private let SwiftUtilityErrorDomain = "SwiftUtility"

// swiftlint:disable identifier_name
public func MalformedURLError() -> Error { NSError() }

public class JSONError: NSError {
    init() {
        super.init(domain: SwiftUtilityErrorDomain,
                   code: 0,
                   userInfo: [NSLocalizedDescriptionKey: "\(JSONError.self)"])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class DocumentError: NSError {
    init() {
        super.init(domain: SwiftUtilityErrorDomain,
                   code: 0,
                   userInfo: [NSLocalizedDescriptionKey: "\(DocumentError.self)"])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public func UnsupportedTypeError() -> Error { NSError() }
