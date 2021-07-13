//
//  ViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var viewModel: PhotosViewModel?
    var dataSource: PhotoDataSource?
    var photoStore: PhotoStore?
    
    enum Constants {
        static let showPhoto = "showPhoto"
        static let numberOfPhotosInRow: CGFloat = 4.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            return
        }
        viewModel.photoViewModelDelegate = self
        photosCollectionView.delegate = self
        self.dataSource = PhotoDataSource(viewModel: viewModel)
        photosCollectionView.dataSource = dataSource
        viewModel.updateDataSource()
        viewModel.fetchPhotos()
    }
}

extension PhotosViewController: PhotoViewModelDelegate {
    func updateCell(at indexPath: IndexPath, with image: UIImage) {
        if let cell = self.photosCollectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            cell.updateCell(imageDisplayed: image)
        }
    }
    
    func handleSuccess() {
        self.photosCollectionView.reloadSections(IndexSet(integer: 0))
    }
}

extension PhotosViewController {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photo = viewModel?.photo(at: indexPath.row) {
            viewModel?.fetchPhotoImage(photo: photo)
        }
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = photosCollectionView.bounds.width / Constants.numberOfPhotosInRow
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension PhotosViewController {
    enum SegueIdentifierConstants {
        static let showPhotoInfoViewController = Constants.showPhoto
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifierConstants.showPhotoInfoViewController:
            if let selectedPhotoIndex = photosCollectionView.indexPathsForSelectedItems?.first {
                let photo = viewModel?.photo(at: selectedPhotoIndex.row)
                let destinationViewController = segue.destination as? PhotoInfoViewController
                destinationViewController?.photo = photo
                if let photoStore = photoStore {
                    destinationViewController?.viewModel = PhotoInfoViewModel(photoStore: photoStore, delegate: nil)
                }
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
