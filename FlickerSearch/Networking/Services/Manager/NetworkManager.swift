//
//  NetworkManager.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get   = "GET"
    case post  = "POST"
}


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private var urlSession: URLSession = {
            let session = URLSession(configuration: .default)
            return session
    }()
    
    
    func responseGet(_ url: String,
                  completionHandler:@escaping(Data?,URLResponse?,Error?)->Void) -> URLSessionDataTask {
        return response(url, method: .get, completionHandler: completionHandler)
    }
    
    private func response(_ url: String,
                          method: HTTPMethod = .get,
                          completionHandler:@escaping(Data?,URLResponse?,Error?)->Void) -> URLSessionDataTask {
        
        let url = URL(string: url)!
        let sessionTask = urlSession.dataTask(with: url) { (data, response, error) in
            //completionHandler(data, response, error)
        }
        sessionTask.resume()
        
        return sessionTask
    }
    
}
