//
//  PhotoStore.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit
import CoreData
enum PhotosError: Error {
    case imageCreationError
    case invalidPhotoURL
}

class PhotoStore {
    let imageStore = ImageStore()
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photos")
        container.loadPersistentStores { description, error in
            if let error = error {
                Logger.log.logDynamic("Error occured while setting up Core Data \(error)")
            }
        }
        return container
    }()
    
    /// Retrieval of Photos from Flickr API response
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
            self.handlePhotosResponse(data: data, error: error) { result in
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
        }
        task.resume()
    }
    
    func fetchAllPhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDate = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func handlePhotosResponse(data: Data?, error: Error?, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard  let jsonData = data else {
            completion(.failure(error ?? FlickrAPIError.unexpectedError))
            return
        }
        persistentContainer.performBackgroundTask { context in
            switch FlickrAPI().handleFlikrResponse(fromJson: jsonData) {
            case let .success(flickrPhotos):
                let photos: [Photo] = flickrPhotos.compactMap { flickrPhoto -> Photo? in
                    let fetchReuest: NSFetchRequest<Photo> = Photo.fetchRequest()
                    fetchReuest.predicate = NSPredicate(format: "\(#keyPath(Photo.photoId)) == \(flickrPhoto.photoId)")
                    var fetchedPhotos: [Photo]?
                    context.performAndWait {
                        do {
                            fetchedPhotos = try fetchReuest.execute()
                        } catch {
                            Logger.log.logDynamic("\(error)")
                        }
                    }
                    
                    if let existingPhoto = fetchedPhotos?.first {
                        return existingPhoto
                    }
                    
                    var photo: Photo?
                    context.performAndWait {
                        photo = Photo(context: context)
                        photo?.photoId = flickrPhoto.photoId
                        photo?.dateTaken = flickrPhoto.dateTaken
                        photo?.photoTitle = flickrPhoto.photoTitle
                        photo?.remoteURL = flickrPhoto.remoteURL
                    }
                    return photo
                }
                do {
                    try context.save()
                    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    Logger.log.logDynamic("Documents Directory Path \(paths[0])")
                } catch {
                    print("Error saving to Core Data \(error)")
                    completion(.failure(error))
                    return
                }
                
                let photoIds = photos.map({$0.objectID})
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos = photoIds.compactMap { viewContext.object(with: $0)} as? [Photo]
                return completion(.success(viewContextPhotos ?? []))
            case let .failure(error):
                return completion(.failure(error))
            }
        }
    }
}

/// Retrieval of Image from Photos
extension PhotoStore {
    func retrievePhotoImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let photoKey = photo.photoId else {
            preconditionFailure("Photo is expected to have photoId")
        }
        if let imageInCache = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(imageInCache))
            }
            return
        }
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
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
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

// Support for Tags
extension PhotoStore {
    func fetchAllTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        let viewContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Tag.fetchRequest()
        let sortByName: NSSortDescriptor = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        viewContext.perform {
            do {
                let tags = try fetchRequest.execute()
                completion(.success(tags))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
