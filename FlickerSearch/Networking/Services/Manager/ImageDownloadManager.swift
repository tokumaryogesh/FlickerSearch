//
//  ImageDownloadManager.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation
import UIKit


enum DownloadPriority: Float {
    case low = 0.0
    case medium = 0.5
    case high = 1.0
}

protocol ImageFetchProtocol {
    func imageFromUrl(_ url: URL) -> UIImage?
}

class ImageFetcher: ImageFetchProtocol {
    func imageFromUrl(_ url: URL) -> UIImage? {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
}

class ImageDownloadManager {
    
    static let shared = ImageDownloadManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private var imageDownloadTask = [String: Operation]()
    let imageOperationQueue = OperationQueue()

    
    private init() {
        
        cache.countLimit = ImageDownloaderConfig.maxObjectsToHold
        cache.totalCostLimit = ImageDownloaderConfig.cacheSize
        imageOperationQueue.maxConcurrentOperationCount = ImageDownloaderConfig.maxConnectionPerHost
        
    }
    
    func downloadImageWithUrl(_ url: URL, priority: Operation.QueuePriority = .normal, fetcher: ImageFetchProtocol = ImageFetcher() ,completionHandler: @escaping(UIImage?,URL,ServiceError?) -> Void) {
        
        let urlString = url.absoluteString as NSString
    
        if let image = cache.object(forKey: urlString) {
            // Image exist in cache, return
            DispatchQueue.main.async {
                 completionHandler(image, url, nil)
            }
            return
        }
        
        if let _ = imageDownloadTask[url.absoluteString] {
            // Task is in progress
            return
        }
        
        let operation = BlockOperation(block: { [weak self] in
                if let image = fetcher.imageFromUrl(url){
                    self?.imageDownloadTask.removeValue(forKey: url.absoluteString)
                    self?.cache.setObject(image, forKey: url.absoluteString as NSString)
                    
                    DispatchQueue.main.async {
                       completionHandler(image, url, nil)
                    }
                } else {
                    self?.imageDownloadTask.removeValue(forKey: url.absoluteString)
                    completionHandler(nil, url, ServiceError.responseUnsuccessful)
            }
        })
        
        operation.queuePriority = priority
        imageOperationQueue.addOperation(operation)
        imageDownloadTask[url.absoluteString] = operation
        
    }
    
    func updatePriority(_ priority: Operation.QueuePriority, forURL url: URL) {
        if let operation = imageDownloadTask[url.absoluteString] {
            operation.queuePriority = priority
        }
    }

}
