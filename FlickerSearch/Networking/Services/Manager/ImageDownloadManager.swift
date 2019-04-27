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


class ImageDownloadManager {
    
    static let shared = ImageDownloadManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private var imageSownloadTask = [String: URLSessionTask]()
    
    private init() {
        
        cache.countLimit = ImageDownloaderConfig.maxObjectsToHold
        cache.totalCostLimit = ImageDownloaderConfig.cacheSize
        
    }
    private var urlSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 8
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func downloadImageWithUrl(_ url: URL, priority: DownloadPriority = .medium, completionHandler: @escaping(UIImage?,URL,Error?) -> Void) {
        
        let urlString = url.absoluteString as NSString
       
        if let image = cache.object(forKey: urlString) {
            // Image exist in cache, return
            completionHandler(image, url, nil)
            return
        }
        
        if let _ = imageSownloadTask[url.absoluteString] {
            // Task is in progress
            return
        }
        
        let sessionTask = urlSession.dataTask(with: url) { [weak self] data, response, error in
            self?.imageSownloadTask.removeValue(forKey: url.absoluteString)
            if let error = error {
                completionHandler(nil, url, error)
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completionHandler(image, url, nil)
                }
                self?.cache.setObject(image, forKey: urlString)
            }
        }
        sessionTask.priority = priority.rawValue
        imageSownloadTask[url.absoluteString] = sessionTask
        sessionTask.resume()
        
    }

}
