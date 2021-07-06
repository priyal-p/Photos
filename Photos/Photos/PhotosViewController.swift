//
//  ViewController.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet var photosCollectionView: UICollectionView!
    var photoCollectionViewDataSource: PhotoDataSource?
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
        
        photosCollectionView.dataSource = photoCollectionViewDataSource
        photosCollectionView.delegate = self
        
        updateDataSource()
        
        // Initiate Retrieve Photos Request
        photoStore?.retrieve(photos: photosEndpoint) {[weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(photos):
                Logger.log.logDynamic("Successfully Retrieved \(photos.count) Photos")
                self.photoCollectionViewDataSource?.photos = photos
            case .failure(let error):
                Logger.log.logDynamic("\(error)")
                
                // Below code is commented to show photos from disk if unable to fetch from API
                //self.photoCollectionViewDataSource?.photos.removeAll()
            }
            self.photosCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

extension PhotosViewController {
    func updateDataSource() {
        photoStore?.fetchAllPhotos(completion: {[weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .success(photos):
                self.photoCollectionViewDataSource?.photos = photos
            case let .failure(error):
                self.photoCollectionViewDataSource?.photos.removeAll()
                Logger.log.logDynamic(error.localizedDescription)
            }
            self.photosCollectionView.reloadSections(IndexSet(integer: 0))
        })
    }
}

extension PhotosViewController {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photo = photoCollectionViewDataSource?.photos[indexPath.row] {
            photoStore?.retrievePhotoImage(for: photo, completion: { result in
                guard let photoIndex = self.photoCollectionViewDataSource?.photos.firstIndex(of: photo), case let .success(image) = result else {
                    return
                }
                let photoIndexPath = IndexPath(item: photoIndex, section: 0)
                if let cell = self.photosCollectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateCell(imageDisplayed: image)
                }
            })
        }
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = photosCollectionView.bounds.width / 4.0
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension PhotosViewController {
    enum SegueIdentifierConstants {
        static let showPhotoInfoViewController = "showPhoto"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifierConstants.showPhotoInfoViewController:
            if let selectedPhotoIndex = photosCollectionView.indexPathsForSelectedItems?.first {
                let photo = photoCollectionViewDataSource?.photos[selectedPhotoIndex.row]
                let destinationViewController = segue.destination as? PhotoInfoViewController
                destinationViewController?.photo = photo
                destinationViewController?.photoStore = photoStore
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
