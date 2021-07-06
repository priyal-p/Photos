//
//  Photo+CoreDataProperties.swift
//  Photos
//
//  Created by Priyal PORWAL on 05/07/21.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var remoteURL: URL?
    @NSManaged public var dateTaken: Date?
    @NSManaged public var photoTitle: String?
    @NSManaged public var photoId: String?

}

extension Photo : Identifiable {

}
