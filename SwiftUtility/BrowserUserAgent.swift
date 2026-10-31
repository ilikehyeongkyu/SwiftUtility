//
//  BrowserUserAgent.swift
//  SwiftUtility
//

import Foundation

/// 실제 iOS 모바일 브라우저와 비슷한 User-Agent.
/// 브라우저가 아닌 요청을 막는 사이트(예: 대전 BIS)에 요청할 때 쓴다.
///
/// 한 번 실행되는 동안(프로세스 수명)에는 같은 값을 쓰고, 앱을 다시 실행하면
/// 여러 사용자의 실제 환경처럼 비슷한 다른 값으로 바뀐다.
/// 브라우저 버전 범위는 시간이 지나면 낡으므로 가끔 최신 버전에 맞춰 올린다.
public enum BrowserUserAgent {
    /// 이번 실행 세션 동안 유지되는 User-Agent.
    public static let session: String = generate()

    /// User-Agent 의 OS 표기와 Safari 버전. iOS 26 부터 OS 표기는 18_6 으로 고정된다.
    private static let safariVersions: [(os: String, version: String)] = [
        ("18_5", "18.5"),
        ("18_6", "18.6"),
        ("18_6", "26.0"),
        ("18_6", "26.1"),
        ("18_6", "26.2"),
        ("18_6", "26.3")
    ]

    private static let chromeMajorVersions = 146...151

    /// 새 User-Agent 를 하나 만든다.
    ///
    /// - Returns: Safari 또는 iOS 용 Chrome 의 iPhone User-Agent
    public static func generate() -> String {
        let safari = safariVersions.randomElement()!
        if Bool.random() {
            return "Mozilla/5.0 (iPhone; CPU iPhone OS \(safari.os) like Mac OS X) AppleWebKit/605.1.15 "
                + "(KHTML, like Gecko) Version/\(safari.version) Mobile/15E148 Safari/604.1"
        }

        let chromeMajor = Int.random(in: chromeMajorVersions)
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(safari.os) like Mac OS X) AppleWebKit/605.1.15 "
            + "(KHTML, like Gecko) CriOS/\(chromeMajor).0.0.0 Mobile/15E148 Safari/604.1"
    }
}
