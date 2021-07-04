//
//  PhotoStore.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

enum PhotosError: Error {
    case imageCreationError
    case invalidPhotoURL
}

class PhotoStore {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    func retrieve(photos endpointPhotos: EndPoint, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let url = FlickrAPI().getURL(for: endpointPhotos) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            Logger.log.logDynamic("""
                🛫 ************************************** \(#function)
                                \n\(response.debugDescription)
                """)
            let result = self.handlePhotosResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func handlePhotosResponse(data: Data?, error: Error?) -> Result<[Photo], Error> {
        guard  let jsonData = data else {
            return .failure(error ?? FlickrAPIError.unexpectedError)
        }
        return FlickrAPI().handleFlikrResponse(fromJson: jsonData)
    }
    
    func retrievePhotoImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotosError.invalidPhotoURL))
            return
        }
        
        let photoDownloadRequest = URLRequest(url: photoURL)
        let task = session.dataTask(with: photoDownloadRequest) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            Logger.log.logDynamic("""
                🛫 ************************************** \(#function)
                                \n\(response.debugDescription)
                """)
            
            let result = self.handlePhotoImageDownload(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func handlePhotoImageDownload(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error ?? PhotosError.imageCreationError)
            }
            return .failure(PhotosError.imageCreationError)
        }
        return .success(image)
    }
}
