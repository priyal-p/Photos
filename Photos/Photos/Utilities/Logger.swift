//
//  Logger.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation
struct Logger {
    static let log = Logger()
    func logDynamic(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}
