//
//  SearchViewModel.swift
//  FlickerSearch
//
//  Created by Yogesh Kumar on 27/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import Foundation


class SearchViewModel {
    
    var dataSource: SearchResponseDTO?
    private var lastSessionTask: URLSessionTask?
    private var pretechingPage: Int = -1
    
    var modelDidGetUpdated: ((ServiceError?)->Void)?
    
    func getSearchForText(_ text: String, page: Int = 1) {
        
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
        
        let params = FlickerSearchRequestParameters(searchString: text, _page: page)
        let getRequest = GetRequestDTO(queryParameter: params, url: FLICKR.baseUrl)
        let service = FlickerSearchService()
        lastSessionTask = service.getRequest(requestDto: getRequest, responseDto: SearchResponseDTO.self) { [weak self] result in
            
            var serviceError: ServiceError?
            switch result {
            case .Success(let responseDTO):
                print(responseDTO)
                if responseDTO.photos.page == 1 {
                    self?.dataSource = responseDTO
                } else {
                    if var photos = self?.dataSource?.photos.photo {
                        photos += responseDTO.photos.photo
                        responseDTO.photos.photo = photos
                    }
                    self?.dataSource = responseDTO
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
        dataSource = nil
        modelDidGetUpdated?(nil)
    }
}
