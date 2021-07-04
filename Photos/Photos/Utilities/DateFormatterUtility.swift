//
//  DateFormatterUtility.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation
struct DateFormatterUtility {
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
}
