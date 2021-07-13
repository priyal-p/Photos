//
//  PhotoDataSource.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

/// Photo Collection Data Source
class PhotoDataSource: NSObject, UICollectionViewDataSource {
    enum Constants: String {
        case collectionCellIdentifier = "PhotoCollectionViewCell"
    }
    
    let viewModel: PhotosViewModel
    
    init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = Constants.collectionCellIdentifier.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell
        cell?.updateCell(imageDisplayed: nil)
        cell?.photoDescription = viewModel.photo(at: indexPath.row)?.photoTitle
        return cell ?? UICollectionViewCell()
    }
}
