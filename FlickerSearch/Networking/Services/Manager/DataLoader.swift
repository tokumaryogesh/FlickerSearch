//
//  DataLoader.swift
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


protocol NetworkEngine {
    
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    func response(_ url: String, method: HTTPMethod, completionHandler:@escaping Handler) -> URLSessionDataTask
}

extension URLSession: NetworkEngine {
   
    typealias Handler = NetworkEngine.Handler
    
    func response(_ url: String,
                  method: HTTPMethod = .get,
                  completionHandler:@escaping Handler) -> URLSessionDataTask {
        let url = URL(string: url)!
        let sessionTask = self.dataTask(with: url) { (data, response, error) in
            completionHandler(data, response, error)
        }
        sessionTask.resume()
        
        return sessionTask
    }
}


class DataLoader {
    
    private let engine: NetworkEngine
    
    init(engine: NetworkEngine = URLSession.shared) {
        self.engine = engine
    }
    
    func responseGet(_ url: String,
                  completionHandler:@escaping(Data?,URLResponse?,Error?)->Void) -> URLSessionDataTask {
        return engine.response(url, method: .get, completionHandler: completionHandler)
    }
}
