//
//  PhotoCollectionViewCell.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit
class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var cellImageView: UIImageView!
    
    @IBOutlet var cellActivityIndicator: UIActivityIndicatorView!
    
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {
            // Not to be changed
        }
    }
    
    var photoDescription: String?
    
    override var accessibilityLabel: String? {
        get {
            return photoDescription
        }
        set {
            // Not to be changed
        }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            super.accessibilityTraits.union([.image, .button])
        }
        set {
            // Not to be updated
        }
    }
    /// Updated Collection View Cell
    func updateCell(imageDisplayed image: UIImage?) {
        if let image = image {
            self.cellActivityIndicator.stopAnimating()
            self.cellImageView.image = image
        } else {
            self.cellActivityIndicator.startAnimating()
            self.cellImageView.image = nil
        }
    }
}
