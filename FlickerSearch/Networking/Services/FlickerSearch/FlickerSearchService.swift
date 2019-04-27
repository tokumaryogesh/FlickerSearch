//
//  FlickerSearchService.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation

class SearchResponseDTO: Decodable {
    
    var photos: PhotoList
}

class PhotoList: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

class Photo: Decodable {
    let farm: Int
    let server: String
    let secret: String
    let id: String
}

class FlickerSearchRequestParameters: Encodable{

//https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens
    let apiKey: String
    let format: String
    let noJsonCallBack: Int
    let safeSearch: Int
    let text: String
    let method: String
    
    init(searchString _text: String,
                     _apiKey: String = FLICKR.apikey,
                     _format: String = FLICKR.QueryParams.format,
                     _noJsonCallBack: Int = FLICKR.QueryParams.noJsonCallBack,
                     _safeSearch: Int = FLICKR.QueryParams.safeSearch,
                     _method: String = FLICKR.QueryParams.method) {
        
        apiKey = _apiKey
        format = _format
        noJsonCallBack = _noJsonCallBack
        safeSearch = _safeSearch
        text = _text
        method = _method
    }
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case format
        case noJsonCallBack = "nojsoncallback"
        case safeSearch = "safe_search"
        case text
        case method
    }
    
}

class FlickerSearchService: GetBaseService<GetRequestDTO<FlickerSearchRequestParameters>, SearchResponseDTO>  {
    
}
