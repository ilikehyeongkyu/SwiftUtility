//
//  JSONUtility.swift
//  SwiftUtility
//
//  Created by Hyeongkyu on 2020/03/20.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension JSON {
	func hierarchicalString(indent: Bool = false) -> String {
		var result: String = ""
		switch self.type {
		case .dictionary:
			var lines: [String] = []
			let dictionary = self.dictionaryValue
			dictionary.forEach { element in
				let key = element.0
				let value = element.1
				var line = "\(key)"
				switch value.type {
				case .dictionary:
					line += "\n\(value.hierarchicalString(indent: true))"
				default:
					line += ": \(value.hierarchicalString(indent: false))"
				}
				lines.append(line)
			}
			result = lines.joined(separator: "\n")
		case .array:
			result = (self.array?.map { $0.hierarchicalString(indent: false) })?.joined(separator: ", ") ?? ""
		case .null, .unknown:
			result = ""
		default:
			result = self.stringValue
		}
		
		if indent {
			result = result
				.components(separatedBy: "\n")
				.map { "    \($0)" } // indent
				.joined(separator: "\n")
		}
		
		return result
	}
}
