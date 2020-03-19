//
//  SwiftUtilityTests.swift
//  SwiftUtilityTests
//
//  Created by Hank.Lee on 12/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import XCTest
@testable import SwiftUtility

class SwiftUtilityTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // swiftlint:disable function_body_length
    func testAdvancedDictionary() {
        let dictionary: [String: Any?] = [
            "key1": "value1",
            "key2": 12345,
            "key3": 123.45,
            "key4": false,
            "key5": nil,
            "key6": 0,
            "key7": "1"
        ]
        
        let advancedDictionary = dictionary.advanced()
        let string1: String? = advancedDictionary["key1"]
        let string2: String? = advancedDictionary["key2"]
        let string3: String? = advancedDictionary["key3"]
        let string4: String? = advancedDictionary["key4"]
        let string5: String? = advancedDictionary["key5"]
        let int1: Int? = advancedDictionary["key1"]
        let int2: Int? = advancedDictionary["key2"]
        let int3: Int? = advancedDictionary["key3"]
        let int4: Int? = advancedDictionary["key4"]
        let int5: Int? = advancedDictionary["key5"]
        let double1: Double? = advancedDictionary["key1"]
        let double2: Double? = advancedDictionary["key2"]
        let double3: Double? = advancedDictionary["key3"]
        let double4: Double? = advancedDictionary["key4"]
        let double5: Double? = advancedDictionary["key5"]
        let bool1: Bool? = advancedDictionary["key1"]
        let bool2: Bool? = advancedDictionary["key2"]
        let bool3: Bool? = advancedDictionary["key3"]
        let bool4: Bool? = advancedDictionary["key4"]
        let bool5: Bool? = advancedDictionary["key5"]
        let bool6: Bool? = advancedDictionary["key6"]
        let bool7: Bool? = advancedDictionary["key7"]
        
        XCTAssert(
            string1 == "value1"
                && string2 == "12345"
                && string3 == "123.45"
                && string4 == "false"
                && string5 == nil
                && int1 == nil
                && int2 == 12345
                && int3 == 123
                && int4 == 0
                && int5 == nil
                && double1 == nil
                && double2 == 12345
                && double3 == 123.45
                && double4 == 0
                && double5 == nil
                && bool1 == nil
                && bool2 == true
                && bool3 == true
                && bool4 == false
                && bool5 == nil
                && bool6 == false
                && bool7 == true, "advanced dictionary type conversion result is not expected.")
    }
    
    func testHTTPRequestSync() {
        let googleHTML = String.fromContentsOf("https://www.google.com")
        XCTAssert(
            googleHTML?.contains("<!doctype html>") ?? false,
            "contents of https://www.google.com is not contains html tag"
        )
    }
    
    func testStringIndentCount() {
        let string = "     5 space"
        XCTAssert(string.indentCount == 5, "\"\(string)\" indent count is not 5")
        
        let longText = """
            
            
            
            Hahahahohoho
                Hihihihahahaha
                    Ohohohoho
                Hihihihahahaha
            Hihihihahahaha

        """
        
        let result = longText.trimIndent()
        // swiftlint:disable line_length
        XCTAssert(result == "Hahahahohoho\n    Hihihihahahaha\n        Ohohohoho\n    Hihihihahahaha\nHihihihahahaha", "string trim indent result is not expected.")
    }
    
    func testSeparatedKorea() {
        let separatedKorean = "이것은한글입니다.뛞똚핛슗.ㄱㄴㄷ.ㅏㅑㅓㅘ.123abc".separatedKorean
        XCTAssert(
            separatedKorean == "ㅇㅣㄱㅓㅅㅇㅡㄴㅎㅏㄴㄱㅡㄹㅇㅣㅂㄴㅣㄷㅏ.ㄸㅞㄹㅁㄸㅗㄹㅁㅎㅏㄱㅅㅅㅠㄹㅎ.ㄱㄴㄷ.ㅏㅑㅓㅘ.123abc",
            "separated korean is unexpcted."
        )
    }
    
    func testStringPad() {
        let string = "12345"
        let lPaddedString = string.lpad(10, "0")
        let rPaddedString = string.rpad(10, "0")
        XCTAssert(
            lPaddedString == "0000012345" && rPaddedString == "1234500000",
            "padded string is not expected."
        )
    }
    
    func testStringSubstringsInBracket() {
        let string = "123(괄호)하하하호호호호(bracket) and empty bracket()"
        XCTAssert(
            string.substringsInBracket() == ["괄호", "bracket", ""],
            "string.substringsInBracket result is not expected."
        )
    }
    
    func testStringSubstringBefore() {
        let string = "123(괄호)하하하호호호호(bracket) and empty bracket()"
        XCTAssert(
            string.substringBefore("(") == "123",
            "string.substringBefore result is not expected."
        )
    }
}
