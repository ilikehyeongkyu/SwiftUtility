//
//  IntUtility.swift
//  SwiftUtility
//
//  Created by Hyeongkyu on 2020/03/20.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Int {
	var asMinutesSeconds: String {
		var components: [String] = []
		
		let minutes = self / 60
		if minutes != 0 {
			components.append("\(minutes)분")
		}
		
		let seconds = self % 60
		if seconds != 0 || components.isEmpty {
			components.append("\(seconds)초")
		}
		
		return components.joined(separator: " ")
	}
    
    func lpadIfOverZero(_ length: Int, _ padChar: Character) -> String? {
        guard self > 0 else { return nil }
        return String(self).lpad(length, padChar)
    }
}
