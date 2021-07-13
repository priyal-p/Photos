//
//  PhotoInfoViewModel.swift
//  Photos
//
//  Created by Priyal PORWAL on 08/07/21.
//

import Foundation
import UIKit.UIImage
protocol PhotoInfoViewDelegate: NSObject {
    func showImage(_ image: UIImage)
}
class PhotoInfoViewModel {
    let photoStore: PhotoStore
    weak var delegate: PhotoInfoViewDelegate?
    init(photoStore: PhotoStore,
         delegate: PhotoInfoViewDelegate?) {
        self.photoStore = photoStore
        self.delegate = delegate
    }
    
    func fetchImage(for photo: Photo) {
        photoStore.retrievePhotoImage(for: photo) { result in
            switch result {
            case .success(let image):
                self.delegate?.showImage(image)
            case .failure(let error):
                Logger.log.logDynamic("Error retrieving image for photo \(error)")
            }
        }
    }
}
