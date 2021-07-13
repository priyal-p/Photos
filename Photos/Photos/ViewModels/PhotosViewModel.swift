//
//  PhotosViewModel.swift
//  Photos
//
//  Created by Priyal PORWAL on 08/07/21.
//

import Foundation
import UIKit.UIImage

protocol PhotoViewModelDelegate: NSObject {
    func handleSuccess()
    func updateCell(at indexPath: IndexPath, with image: UIImage)
}
class PhotosViewModel {
    
    let photoStore: PhotoStore
    let photosEndpoint: EndPoint
    weak var photoViewModelDelegate: PhotoViewModelDelegate?
    var photos: [Photo] {
        didSet {
            photoViewModelDelegate?.handleSuccess()
        }
    }
    
    init(photosEndpoint: EndPoint = .interestingPhotos,
         photoStore: PhotoStore,
         photoViewModelDelegate: PhotoViewModelDelegate?) {
        self.photosEndpoint = photosEndpoint
        self.photoStore = photoStore
        self.photoViewModelDelegate = photoViewModelDelegate
        self.photos = [Photo]()
    }
    
    func fetchPhotos() {
        // Initiate Retrieve Photos Request
        photoStore.retrieve(photos: photosEndpoint) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(photos):
                Logger.log.logDynamic("Successfully Retrieved \(photos.count) Photos")
                self.photos = photos
            case .failure(let error):
                Logger.log.logDynamic("\(error)")
                
                // Below code is commented to show photos from disk if unable to fetch from API
                //self.photos.removeAll()
            }
        }
    }
    
    func numberOfPhotos() -> Int {
        self.photos.count
    }
    
    func photo(at index: Int) -> Photo? {
        if photos.count >= index {
            return self.photos[index]
        }
        return nil
    }
    
    func updateDataSource() {
        photoStore.fetchAllPhotos(completion: {[weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .success(photos):
                self.photos = photos
            case let .failure(error):
                self.photos.removeAll()
                Logger.log.logDynamic(error.localizedDescription)
            }
        })
    }
    
    func fetchPhotoImage(photo: Photo) {
        photoStore.retrievePhotoImage(for: photo, completion: { result in
            guard let photoIndex = self.photos.firstIndex(of: photo),
                  case let .success(image) = result else {
                return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            self.photoViewModelDelegate?.updateCell(at: photoIndexPath, with: image)
        })
    }
}
