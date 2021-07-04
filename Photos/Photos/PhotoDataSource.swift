//
//  PhotoDataSource.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

/// Photo Collection Data Source
class PhotoDataSource: NSObject, UICollectionViewDataSource {
    var photos = [Photo]()
    enum Constants: String {
        case collectionCellIdentifier = "PhotoCollectionViewCell"
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = Constants.collectionCellIdentifier.rawValue
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell
        cell?.updateCell(imageDisplayed: nil)
        return cell ?? UICollectionViewCell()
    }
}
