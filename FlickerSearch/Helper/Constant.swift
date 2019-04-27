//
//  Constant.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation
import CoreGraphics

struct FLICKR {
    static let apikey = "3e7cc266ae2b0e0d78e279ce8e361736" //API_KEY_FLICKR"
    static let baseUrl = "https://api.flickr.com/services/rest/?"
    
    struct QueryParams {
        static let format = "json"
        static let noJsonCallBack = 1
        static let safeSearch = 1
        static let method = "flickr.photos.search"
    }
}


struct ImageDownloaderConfig {
    static let maxConnectionPerHost = 8
    static let maxObjectsToHold = 400
    static let MB = 1024*1024
    static let cacheSize = 200 * ImageDownloaderConfig.MB
}

struct SearchScreenConfig {
    static let noOfItemsHorizontally: CGFloat = 3
    static let interItemSpacing: CGFloat = 10
}
