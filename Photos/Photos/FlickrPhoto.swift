//
//  Photo.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation
/// Supports JSON
class FlickrPhoto: Codable, Equatable {
    let photoId: String
    let photoTitle: String
    let remoteURL: URL?
    let dateTaken: Date
    
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case photoTitle = "title"
        case remoteURL = "url_z"
        case dateTaken = "datetaken"
    }
    
    init(photoId: String,photoTitle: String,remoteURL: URL,dateTaken: Date) {
        self.photoId = photoId
        self.photoTitle = photoTitle
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
}

// MARK:- Conforms Equatable
extension FlickrPhoto {
    static func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
        lhs.photoId == rhs.photoId
    }
}
