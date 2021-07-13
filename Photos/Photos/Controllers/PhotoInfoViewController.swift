//
//  PhotoInfoViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit
class PhotoInfoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var photo: Photo? {
        didSet {
            navigationItem.title = photo?.photoTitle
        }
    }
    
    var viewModel: PhotoInfoViewModel?
    
    enum Constants {
        static let showTags = "showTags"
    }
    
    override func viewDidLoad() {
        viewModel?.delegate = self
        if let photo = photo {
            retrievePhoto(photo: photo)
        }
        imageView.accessibilityLabel = photo?.photoTitle
    }
    
    /// Retrieve image for selected photo
    /// - Parameter photo: Selected Photo
    func retrievePhoto(photo: Photo) {
        viewModel?.fetchImage(for: photo)
    }
}

extension PhotoInfoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.showTags:
            let navigationViewController = segue.destination as? UINavigationController
            let tagsViewController = navigationViewController?.topViewController as? TagsViewController
            tagsViewController?.photo = photo
        default:
            preconditionFailure("Unidentified Segue Identifier")
        }
    }
}

extension PhotoInfoViewController: PhotoInfoViewDelegate {
    func showImage(_ image: UIImage) {
        self.imageView.image = image
    }
}
