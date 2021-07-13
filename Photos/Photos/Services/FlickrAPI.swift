//
//  FlickrAPI.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import Foundation

enum EndPoint: String {
    case interestingPhotos
    case recentPhotos = "getRecent"
}

struct FlickrResponse: Codable {
    let photosInfo: FlickrPhotosResponse
    
    enum CodingKeys: String, CodingKey {
        case photosInfo = "photos"
    }
}

struct FlickrPhotosResponse: Codable {
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}

enum FlickrAPIError: Error {
    case unexpectedError
    case apiRequestError
}

/// Handles Flickr API URL creation and response
class FlickrAPI {
    // MARK:- FlickrAPI Initializer
    let dateFormatterUtility : DateFormatterUtility
    init(dateFormatterUtility : DateFormatterUtility = DateFormatterUtility()) {
        self.dateFormatterUtility = dateFormatterUtility
    }
    
    lazy var propertyListData: [String: AnyObject]? = {
        return PropertyListHandling().getAPIPropertyListData()
    }()
    
    // MARK:- Constants
    enum PropertyListConstants {
        static let queryParams = "queryParams"
        static let resources = "flickrResource"
        static let proxy = "proxy"
        static let host = "host"
    }
    
    enum BaseParamsConstants {
        static let method = "method"
        static let apiKey = "api_key"
        #warning("Add API Key Value")
        static let apiKeyValue = ""
    }
    
    // MARK:- Create API URL
    func getURL(for resource: EndPoint,
                additionalParams: [String: String] = [:]) -> URL? {
        if let commonParams = propertyListData?[PropertyListConstants.queryParams] as? [String: String],
           let resources = propertyListData?[PropertyListConstants.resources] as? [String: Any],
           let proxy = resources[PropertyListConstants.proxy] as? [String: String],
           let path = proxy[resource.rawValue],
           let host = resources[PropertyListConstants.host] as? String {
            var components = URLComponents(string: host)
            var queryParams = [URLQueryItem]()
            
            let baseParams = [
                BaseParamsConstants.method : path,
                BaseParamsConstants.apiKey: BaseParamsConstants.apiKeyValue
            ]
            
            for (key, value) in baseParams {
                let item = URLQueryItem(name: key, value: value)
                queryParams.append(item)
            }
            for (key, value) in commonParams {
                let item = URLQueryItem(name: key, value: value)
                queryParams.append(item)
            }
            
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryParams.append(item)
            }
            
            components?.queryItems = queryParams
            Logger.log.logDynamic(components?.url?.debugDescription ?? String())
            return components?.url
        }
        return nil
    }
    
    // MARK:- Handle Flickr Response
    func handleFlikrResponse(fromJson data: Data) -> Result<[FlickrPhoto], Error> {
        Logger.log.logDynamic("\(data.prettyPrintedJSONData ?? "")")
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatterUtility.dateFormatter)
            let flikrResponse = try jsonDecoder.decode(FlickrResponse.self, from: data)
            
            // To avoid sharing photos with no url
            let photos = flikrResponse.photosInfo.photos.filter { photo in
                photo.remoteURL != nil
            }
            
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
}
