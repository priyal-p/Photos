//
//  Data+Extension.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation
extension Data {
    var prettyPrintedJSONData: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        return prettyPrintedString
    }
}
