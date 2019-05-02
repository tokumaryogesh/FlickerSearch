//
//  SearchViewModel.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation


class SearchViewModel {
    
    private var response: SearchResponseDTO? {
        didSet {
            if let data = response?.photoList.photo {
                photos = data
            } else {
                photos = [Photo]()
            }
        }
    }
    
    var photos = [Photo]()
    private var lastSessionTask: URLSessionTask?
    private var pretechingPage: Int = -1
    
    var modelDidGetUpdated: ((ServiceError?)->Void)?
    
    func getSearchForText(_ text: String, page: Int = 1, service: FlickerSearchService = FlickerSearchService()) {
        
        if pretechingPage == page {
            // Prefetch Loading In Progress
            return
        }
        
        if page > 1 {
            pretechingPage = page
        }
        
        if let lastSessionTask = self.lastSessionTask {
            lastSessionTask.cancel()
        }
        
        let params = FlickerSearchRequestParameters(searchString: text, page: page)
        let getRequest = GetRequestDTO(queryParameter: params, url: FLICKR.baseUrl)
        lastSessionTask = service.getRequest(requestDto: getRequest, responseDto: SearchResponseDTO.self) { [weak self] result in
            
            var serviceError: ServiceError?
            switch result {
            case .Success(let responseDTO):
                print(responseDTO)
                if responseDTO.photoList.page == 1 {
                    self?.response = responseDTO
                } else {
                    if var photos = self?.response?.photoList.photo {
                        photos += responseDTO.photoList.photo
                        responseDTO.photoList.photo = photos
                    }
                    self?.response = responseDTO
                }
            case .Failure(let error):
                print("error \(error)")
                serviceError = error
            }
            DispatchQueue.main.async {
                self?.modelDidGetUpdated?(serviceError)
            }
            self?.pretechingPage = -1
        }
        
    }
    
    func resetSearch() {
        pretechingPage = -1
        response = nil
        modelDidGetUpdated?(nil)
    }
    
    func isNextPageAvailable() -> Bool {
        if let response = self.response {
            if response.photoList.page < response.photoList.pages {
                return true
            }
        }
        return false
    }
    
    func currentPage() -> Int {
        if let response = self.response {
            return response.photoList.page
        }
        return 1
    }
}
