//
//  SQLUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 16/04/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SubSQL {
    public let string: String
    public init(_ string: String) {
        self.string = string
    }
}

public extension String {
    func sqlBinded(_ bindings: [String: Any?]) -> String {
        var sqlBinded = self

        // SubSQL 먼저 처리한다. SubSQL이 다른 binding을 가질수 있기 때문.
        bindings.forEach { key, value in
            let bindingKey = ":\(key)"
            if let subSQL = value as? SubSQL {
                sqlBinded = sqlBinded.replacingOccurrences(of: bindingKey, with: subSQL.string)
            }
        }

        // 나머지를 처리한다.
        bindings.forEach { key, value in
            let bindingKey = ":\(key)"

            guard let value = value else {
                sqlBinded = sqlBinded.replacingOccurrences(of: bindingKey, with: "NULL")
                return
            }

            if let string = value as? String {
                let string = string.replacingOccurrences(of: "'", with: "''")
                sqlBinded = sqlBinded.replacingOccurrences(of: bindingKey, with: "'\(string)'")
                return
            }

            if let json = value as? JSON,
                let string = json.rawString()?.replacingOccurrences(of: "'", with: "''") {
                sqlBinded = sqlBinded.replacingOccurrences(of: bindingKey, with: "'\(string)'")
                return
            }

            sqlBinded = sqlBinded.replacingOccurrences(of: bindingKey, with: "\(value)")
        }

        return sqlBinded
    }
}
