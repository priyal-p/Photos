//
//  ViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

class PhotosViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var photoStore: PhotoStore?
    let photosEndpoint: EndPoint
    init(photosEndpoint: EndPoint = .interestingPhotos) {
        self.photosEndpoint = photosEndpoint
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.photoStore = nil
        self.photosEndpoint = .interestingPhotos
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate Retrieve Photos Request
        photoStore?.retrieve(photos: photosEndpoint) {[weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(photos):
                Logger.log.logDynamic("Successfully Retrieved \(photos.count) Photos")
                if let photo = photos.first {
                    self.updateImageView(for: photo)
                }
            case .failure(let error):
                Logger.log.logDynamic("\(error)")
            }
        }
    }

    func updateImageView(for photo: Photo) {
        photoStore?.retrievePhotoImage(for: photo, completion: { result in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case .failure(let error):
                Logger.log.logDynamic("\(error)")
            }
        })
    }
}
