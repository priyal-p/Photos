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
