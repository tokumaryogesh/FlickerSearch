//
//  FlickerSearchService.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation

class SearchResponseDTO: Decodable {
    
    var photoList: PhotoList
    
    enum Codingkeys: String, CodingKey {
        case photoList = "photos"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkeys.self)
        photoList = try container.decode(PhotoList.self, forKey: .photoList)
    }
}

class PhotoList: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    var photo: [Photo]
}

class Photo: PhotoResultProtocol, Decodable {
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
    let page: Int
    
    init(searchString text: String,
                     page: Int,
                     apiKey: String = FLICKR.apikey,
                     format: String = FLICKR.QueryParams.format,
                     noJsonCallBack: Int = FLICKR.QueryParams.noJsonCallBack,
                     safeSearch: Int = FLICKR.QueryParams.safeSearch,
                     method: String = FLICKR.QueryParams.method) {
        
        self.apiKey = apiKey
        self.format = format
        self.noJsonCallBack = noJsonCallBack
        self.safeSearch = safeSearch
        self.text = text
        self.method = method
        self.page = page
    }
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case format
        case noJsonCallBack = "nojsoncallback"
        case safeSearch = "safe_search"
        case text
        case method
        case page
        
    }
    
}

class FlickerSearchService: GetBaseService<GetRequestDTO<FlickerSearchRequestParameters>, SearchResponseDTO>  {
    
}
