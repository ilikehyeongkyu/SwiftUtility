//
//  DateUtility.swift
//  SwiftUtility
//
//  Created by Hank.Lee on 23/03/2020.
//  Copyright © 2020 hyeongkyu. All rights reserved.
//

import Foundation

public extension Date {
    static var localizedTodayZero: TimeInterval {
        let secondsOfDay = Int64(60 * 60 * 24)
        let offset = Int64(TimeZone.current.secondsFromGMT())
        return
            TimeInterval(
                (Int64(Date().timeIntervalSince1970) / secondsOfDay * secondsOfDay) - offset
        )
    }
}

public extension TimeInterval {
    var asHourMinuteString: String {
        let totalMinute = Int(self) / 60
        let hour = totalMinute / 60
        let minute = totalMinute % 60
        return "\(String(hour).lpad(2, "0")):\(String(minute).lpad(2, "0"))"
    }
    
    var asMinuteString: String {
        return String(Int(self) / 60) + "분"
    }
}
