//
//  StringUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 12/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import SwiftyJSON

// swiftlint:disable file_length
public extension String {
    // swiftlint:disable identifier_name
    var ns: NSString {
        return self as NSString
    }
    
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    static func isEmpty(_ string: String?) -> Bool {
        guard let string = string else { return true }
        return string.isEmpty
    }
    
    static func isNotEmpty(_ string: String?) -> Bool {
        return !isEmpty(string)
    }
    
    var isNull: Bool {
        return self.noWhitespaces.lowercased() == "null"
    }
    
    func lpad(_ length: Int, _ padChar: Character) -> String {
        var result = self
        while result.count < length { result = "\(padChar)" + result }
        return result
    }
    
    func rpad(_ targetCount: Int, _ char: Character) -> String {
        var result = self
        while result.count < targetCount { result += "\(char)" }
        return result
    }
    
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
    
    func asJSON() -> JSON? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSON(data: data)
    }
    
    var asInt: Int? {
        if let int = Int(self) { return int }
        if let bool = Bool(self) { return bool ? 1 : 0 }
        if let double = Double(self) { return Int(double)}
        return nil
    }
    
    var asDouble: Double? {
        if let double = Double(self) { return double }
        if let bool = Bool(self) { return bool ? 1 : 0 }
        return nil
    }
    
    var asFloat: Float? {
        if let float = Float(self) { return float }
        if let bool = Bool(self) { return bool ? 1 : 0 }
        return nil
    }
    
    var asBool: Bool? {
        if let bool = Bool(self) { return bool }
        if let int = Int(self) { return int == 0 ? false : true }
        if let double = Double(self) { return double == 0 ? false : true }
        return nil
    }
    
    func removeAll(_ string: String) -> String {
        return self.replacingOccurrences(of: string, with: "")
    }
    
    /// 콜론 구분된 시간 또는 "10시 30분" 등의 문자열을 0시부터의 소요시간 값으로 변환
	/// 예를 들면 "21:30", "09:25", "10시 30분" 등의 시간값을 변환하는데 사용
    var asSeconds: TimeInterval? {
		let string = self.trim()
		var hour = 0
		var minute = 0
		if string.count == 4 || contains(":") {
			let value = string.noWhitespaces.removeAll(":")
			if value.count != 4 { return nil }
			
			guard
				let hourNumber = value.ns.substring(to: 2).asInt,
				let minuteNumber = value.ns.substring(from: 2).asInt else {
					return nil
			}
			
			hour = hourNumber
			minute = minuteNumber
		} else if contains("시") {
			let value = string.noWhitespaces.components(separatedBy: "시")
			guard
				let hourNumber = value.first?.findInt(),
				let minuteNumber = value[1].findInt() else {
					return nil
			}
			
			hour = hourNumber
			minute = minuteNumber
		}
		
        return TimeInterval((hour * 60 * 60) + (minute * 60))
    }
    
    /// "5분", "17 분", "20(분)", "30 (분)"
	/// ...등으로 표기된 시간값을 변환하는데 사용
    func parseToTimeInterval() -> TimeInterval? {
        let text = self.noWhitespaces
		if text == text.matches(pattern: "\\d+\\s*\\(?분\\)?").first {
			if let number = text.findInt() {
				return TimeInterval(number * 60)
			}
        }
        
        // TODO more
        
        return nil
    }
	
    // swiftlint:disable force_try
	private static let patternForFindInt = try! NSRegularExpression(pattern: "[0-9]+", options: [])
	
	func findInt() -> Int? {
		guard let match = String.patternForFindInt.firstMatch(in: self, options: [], range: self.ns.fullRange) else {
			return nil
		}
		
		return Int(self.ns.substring(with: match.range))
	}
    
    func removeEmptyBrackets() -> String {
        let brackets = ["()", "[]", "{}", "\"\"", "''"]
        var result = self
        brackets.forEach {
            let open = $0.ns.substring(to: 1)
            let close = $0.ns.substring(from: 1)
            let substrings = result.substringsInBracket(open, close)
            substrings.forEach {
                if $0.noWhitespaces.isEmpty {
                    result = result.removeAll("\(open)\($0)\(close)")
                }
            }
        }
        return result
    }
    
    func substringsInBracket(_ open: String, _ close: String) -> [String] {
        let ns = self.ns
        var results: [String] = []
        var cursor = 0
        while true {
            let startIndex = ns.indexOf(open, cursor)
            if startIndex < 0 { break }
            let endIndex = ns.indexOf(close, startIndex + open.count)
            if endIndex < 0 { break }
            let substring = ns.substring(startIndex + open.count, endIndex)!
            results.append(substring as String)
            cursor = endIndex + 1
        }
        
        return results
    }
    
    func substringBefore(_ string: String) -> String {
        let ns = self.ns
        let range = ns.range(of: string)
        if range.location == NSNotFound { return self }
        return ns.substring(to: range.location)
    }
    
    func substringAfter(_ string: String) -> String {
        let ns = self.ns
        let range = ns.range(of: string)
        if range.location == NSNotFound { return self }
        return ns.substring(from: range.upperBound)
    }
    
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var indentCount: Int {
        for charIndex in 0 ..< count {
            let isWhiteSpace = self[self.index(startIndex, offsetBy: charIndex)]
                .unicodeScalars
                .allSatisfy { CharacterSet.whitespacesAndNewlines.contains($0)
            }
            
            if !isWhiteSpace {
                return charIndex
            }
        }
        
        return 0
    }
    
    func trimIndent() -> String {
        let lines = self.components(separatedBy: "\n")
        var firstNotEmptyLineIndex: Int?
        var indentCountOfFirstNotEmptyLine: Int?
        for lineIndex in 0 ..< lines.count {
            let line = lines[lineIndex]
            if firstNotEmptyLineIndex == nil {
				if line.trim().count == 0 { // line is empty
                    continue
                }
                firstNotEmptyLineIndex = lineIndex
            }
            
            indentCountOfFirstNotEmptyLine = line.indentCount
            break
        }
        
        // all lines are empty
        if firstNotEmptyLineIndex == nil { return "" }
        
        var resultLines: [String] = []
        for lineIndex in firstNotEmptyLineIndex! ..< lines.count {
            let line = lines[lineIndex]
            let indentCountOfLine = line.indentCount
            let lineStartIndex = line.index(
                line.startIndex,
                offsetBy: min(indentCountOfFirstNotEmptyLine!, indentCountOfLine)
            )
            let resultLine = line[lineStartIndex...]
            resultLines.append(String(resultLine))
        }
        
        return resultLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var noWhitespaces: String {
        return replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
    
    func matches(pattern: String) -> [String] {
        let nsString = self.ns
        let matches = (try? NSRegularExpression(pattern: pattern, options: []))?
            .matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
            .map { match in
                return nsString.substring(with: match.range)
        }
        return matches ?? []
    }
    
    static func isEqualIfNotNil(_ string1: String?, _ string2: String?) -> Bool {
        guard let string1 = string1, let string2 = string2 else { return false }
        return string1 == string2
    }
    
    var hexEscaped: String {
        var result = ns
        var unicodeIndex = -1
        while true {
            unicodeIndex = result.indexOf("\\u")
            if unicodeIndex < 0 { break }
            
            let hexdecimal = (result.substring(unicodeIndex + 2, unicodeIndex + 6) ?? "") as String
            let c = Int(hexdecimal, radix: 16) ?? 0
            var s = ""
            if let unicodeScalar = UnicodeScalar(c) {
                s = String(describing: unicodeScalar)
            }
            result = result.replacingOccurrences(of: "\\u\(hexdecimal)", with: s) as NSString
        }
        
        return result as String
    }
    
    var separatedKorean: String {
        return Jamo.getJamo(self)
    }
    
    var euckrURLEncoded: String {
        let query = self
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: rawEncoding)
        let eucKRStringData = query.data(using: encoding) ?? Data()
        let outputQuery = eucKRStringData.map {byte->String in
            if byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z")
                || byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z")
                || byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
                || byte == UInt8(ascii: "_") || byte == UInt8(ascii: ".") || byte == UInt8(ascii: "-") {
                return String(Character(UnicodeScalar(UInt32(byte))!))
            } else if byte == UInt8(ascii: " ") {
                return "+"
            } else {
                return String(format: "%%%02X", byte)
            }
        }.joined()
        
        return outputQuery
    }
    
    var htmlStripped: String {
        var string = String(self)
        while true {
            if let range = string.range(of: "<[^>]+>", options: .regularExpression, range: nil, locale: nil) {
                string = string.replacingCharacters(in: range, with: "")
            } else {
                break
            }
        }

        return string
    }
    
    // swiftlint:disable identifier_name
    var htmlSpecialCharsRemoved: String {
        var string = self.htmlStripped.trim()
        string = string.replacingOccurrences(of: "&nbsp;", with: " ")
        string = string.replacingOccurrences(of: "&lt;", with: "<")
        string = string.replacingOccurrences(of: "&gt;", with: ">")
        string = string.replacingOccurrences(of: "&amp;", with: "&")
        string = string.replacingOccurrences(of: "\t", with: " ")
        string = string.replacingOccurrences(of: "\r", with: " ")
        string = string.replacingOccurrences(of: "\n", with: " ")
        while string.contains("  ") {
            string = string.replacingOccurrences(of: "  ", with: " ")
        }
        string = string.trim()
        return string
    }
    
    var htmlCommentsRemoved: String {
        var s = self
        while true {
            if let r = s.range(of: "<!--.*?-->", options: .regularExpression, range: nil, locale: nil) {
                s = s.replacingCharacters(in: r, with: "")
            } else {
                break
            }
        }

        return s
    }
}

public extension String.Encoding {
    static let euckr = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
}

public extension CharacterSet {
    static var korean: CharacterSet {
        return CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!))
    }
}

private class Jamo {
    // UTF-8 기준
    static let firstKoreaUnicode: UInt32 = 44032  // "가"
    static let lastKoreanUnicode: UInt32 = 55199    // "힣"
    
    static let cycleCho: UInt32 = 588
    static let cycleJung: UInt32 = 28
    
    static let cho = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    static let jung = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]
    
    static let jong = [
        "", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ",
        "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    static let doubleJong = [
        "ㄳ": "ㄱㅅ", "ㄵ": "ㄴㅈ", "ㄶ": "ㄴㅎ", "ㄺ": "ㄹㄱ", "ㄻ": "ㄹㅁ",
        "ㄼ": "ㄹㅂ", "ㄽ": "ㄹㅅ", "ㄾ": "ㄹㅌ", "ㄿ": "ㄹㅍ", "ㅀ": "ㄹㅎ",
        "ㅄ": "ㅂㅅ"
    ]
    
    // 주어진 "단어"를 자모음으로 분해해서 리턴하는 함수
    class func getJamo(_ input: String) -> String {
        var jamo = ""
        // let word = input
        //     .trimmingCharacters(in: .whitespacesAndNewlines)
        //     .trimmingCharacters(in: .punctuationCharacters)
        for scalar in input.unicodeScalars {
            jamo += getJamoFromOneSyllable(scalar) ?? ""
        }
        return jamo
    }
    
    // 주어진 "코드의 음절"을 자모음으로 분해해서 리턴하는 함수
    // swiftlint:disable identifier_name
    private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String? {
        if CharacterSet.korean.contains(n) {
            let index = n.value - firstKoreaUnicode
            let cho = self.cho[Int(index / cycleCho)]
            let jung = self.jung[Int((index % cycleCho) / cycleJung)]
            var jong = self.jong[Int(index % cycleJung)]
            if let disassembledJong = doubleJong[jong] {
                jong = disassembledJong
            }
            return cho + jung + jong
        } else {
            return String(UnicodeScalar(n))
        }
    }
}

public extension NSString {
    var s: String {
        return self as String
    }
    
    func trim() -> NSString {
        return trimmingCharacters(in: .whitespacesAndNewlines).ns
    }
	
	var fullRange: NSRange {
		return NSRange(location: 0, length: length)
	}
    
    func indexOf(_ string: String, _ startLocation: Int = 0) -> Int {
        let range = self.range(of: string, range: NSRange(location: startLocation, length: self.length - startLocation))
        if range.location == NSNotFound { return -1 }
        return range.location
    }
	
	func lastIndexOf(_ string: String, _ startLocation: Int = 0) -> Int {
		let range = self.range(
			of: string,
			options: .backwards,
			range: NSRange(location: startLocation, length: self.length - startLocation))
		if range.location == NSNotFound { return -1 }
		return range.location
	}
    
    /// startIndex, endIndex는 음수를 설정할 수 있다.
    /// 음수를 설정하면 문자열의 last에서부터의 index로 설정한다.
    func substring(_ startIndex: Int, _ endIndex: Int) -> NSString? {
        var startIndex = startIndex
        var endIndex = endIndex
        if startIndex < 0 { startIndex = length + startIndex }
        if endIndex < 0 { endIndex = length + endIndex }
        if self.length < endIndex { return nil }
        return substring(with: NSRange(location: startIndex, length: endIndex - startIndex)) as NSString
    }
}
