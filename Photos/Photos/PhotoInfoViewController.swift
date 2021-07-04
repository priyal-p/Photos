//
//  PhotoInfoViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit
class PhotoInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var photo: Photo? {
        didSet {
            navigationItem.title = photo?.photoTitle
        }
    }
    var photoStore: PhotoStore?
    
    override func viewDidLoad() {
        if let photo = photo {
            retrievePhoto(photo: photo)
        }
    }
    
    /// Retrieve and display selected Photo Information
    /// - Parameter photo: Selected Photo
    func retrievePhoto(photo: Photo) {
        photoStore?.retrievePhotoImage(for: photo, completion: { result in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case .failure(let error):
                Logger.log.logDynamic("Error fetching image for photo: \(error)")
            }
        })
    }
}
