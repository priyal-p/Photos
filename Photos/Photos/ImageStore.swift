//
//  ImageStore.swift
//  Photos
//
//  Created by Priyal PORWAL on 04/07/21.
//

import UIKit

/// Handled Image Caching in User Documents Directory
class ImageStore {
    let cache = NSCache<NSString, UIImage>()
    
    /// To save image
    /// - Parameters:
    ///   - image: Image to be save
    ///   - key: Image Key to uniquely identify image
    func setImage(_ image: UIImage, forKey key: String ) {
        cache.setObject(image, forKey: key as NSString)
        let imageURL = getImageURL(forKey: key)
        if let data = image.jpegData(compressionQuality: 0.5), let url = imageURL {
            try? data.write(to: url)
        }
        
    }
    
    
    /// Retrieve Image
    /// - Parameter key: To uniquely identify image
    /// - Returns: Optional(UIImage)
    func image(forKey key: String) -> UIImage? {
        if let imageInCache = cache.object(forKey: key as NSString) {
            return imageInCache
        }
        guard let url = getImageURL(forKey: key),
              let imageInDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        cache.setObject(imageInDisk, forKey: key as NSString)
        return imageInDisk
    }
    
    /// Remove Image from Cache and Disk
    /// - Parameter key: To uniquely identify image
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        if let url = getImageURL(forKey: key) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                Logger.log.logDynamic("Error removing data from disk \(error)")
            }
        }
    }
    
    /// To obtain image url
    /// - Parameter key: To uniquely identify image
    /// - Returns: Image URL
    func getImageURL(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        let documentDirectories = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let path = documentDirectories.first
        return path?.appendingPathComponent(key)
    }
}
