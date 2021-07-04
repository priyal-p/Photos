//
//  PropertyListHandling.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation
struct PropertyListHandling {
    
    enum Error: Swift.Error {
        case loadingAPIResouces
    }
    
    // MARK:- Property Lists in Project
    enum Constants: String {
        case resourcesPlistFile = "API"
    }
    
    // MARK:- Get API Property List Data
    func getAPIPropertyListData() -> [String:AnyObject]? {
        let bundle = Bundle.main
        do {
            guard let url = bundle.url(forResource: Constants.resourcesPlistFile.rawValue, withExtension: ".plist"),
                let plistData = NSDictionary(contentsOf: url) as? [String: AnyObject] else {
                throw Error.loadingAPIResouces
            }
            return plistData
        } catch Error.loadingAPIResouces {
            print(Error.loadingAPIResouces)
        } catch {
            print("An error occured \(error)")
        }
        return nil
    }
}
