//
//  NSDate+Additions.swift
//  MonkeyCounter
//
//  Created by AT on 6/13/17.
//  Copyright © 2017 AT. All rights reserved.
//

import Foundation

extension Date {
    /// The day of the week's number.
    ///
    /// - Returns: the day of the week's number
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    /// The day of the week's name (i.e. Monday, Tuesday ...)
    ///
    /// - Returns: the day of the week's name.
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self).localizedCapitalized
    }
    
    /// EEEE MM dd (i.e.: Monday Oct 17)
    ///
    /// - Returns: week's name month day.
    func dayOfWeekMonthDay() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self).localizedCapitalized
    }
    
    /// hh:mm (i.e. 09:54)
    ///
    /// - Returns: hour and minute.
    func hourMinute() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }
}
