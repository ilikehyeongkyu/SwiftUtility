//
//  StringUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 12/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension String {
    // swiftlint:disable identifier_name
    var ns: NSString {
        return self as NSString
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func lpad(_ targetCount: Int, _ char: Character) -> String {
        var result = self
        while result.count < targetCount { result = "\(char)" + result }
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
    
    func asJSON(encoding: String.Encoding = .utf8) -> JSON? {
        guard let data = self.data(using: encoding) else { return nil }
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
	
	private static let patternForFindInt = try! NSRegularExpression(pattern: "[0-9]+", options: [])
	
	func findInt() -> Int? {
		guard let match = String.patternForFindInt.firstMatch(in: self, options: [], range: self.ns.fullRange) else {
			return nil
		}
		
		return Int(self.ns.substring(with: match.range))
	}
    
    func substringsInBracket() -> [String] {
		return matches(pattern: "\\([^\\).]*\\)")
			.map {
				let ns = $0.ns
				return ns.substring(1, ns.length - 2)! as String
		}
    }
    
    func substringBefore(_ string: String) -> String {
        let nsString = self as NSString
        let range = nsString.range(of: string)
        if range.location == NSNotFound { return self }
        return nsString.substring(to: range.location)
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
    
    var separatedKorean: String {
        return Jamo.getJamo(self)
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
	
	var fullRange: NSRange {
		return NSRange(location: 0, length: length)
	}
    
    func indexOf(_ string: String, startLocation: Int = 0) -> Int? {
        let range = self.range(of: string, range: NSRange(location: startLocation, length: self.length - startLocation))
        if range.location == NSNotFound { return nil }
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
