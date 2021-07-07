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
        imageView.accessibilityLabel = photo?.photoTitle
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

extension PhotoInfoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags":
            let navigationViewController = segue.destination as? UINavigationController
            
            let tagsViewController = navigationViewController?.topViewController as? TagsViewController
            
            tagsViewController?.photo = photo
            tagsViewController?.photoStore = photoStore
            
        default:
            preconditionFailure("Unidentified Segue Identifier")
        }
    }
}
