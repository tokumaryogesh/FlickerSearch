//
//  SearchViewModelTest.swift
//  FlickerSearchTests
//
//  Created by Yogesh Kumar on 29/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import XCTest

class SearchViewModelTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModelError() {
        
        class FlickerSearchServiceMocker: FlickerSearchService {
            
            override func getRequest(requestDto: GetRequestDTO<FlickerSearchRequestParameters>, responseDto: SearchResponseDTO.Type, manager: DataLoader, completion: @escaping (Result<SearchResponseDTO>) -> Void) -> URLSessionTask {
                
                 completion(Result.Failure(.invalidData))
                return URLSessionDataTask()
            }
        }
        
        let expectation  = self.expectation(description: "CallBack")
        var rError: ServiceError?
        let viewModel = SearchViewModel()
        viewModel.modelDidGetUpdated = { error in
            rError = error
            expectation.fulfill()
        }
        viewModel.getSearchForText("test", page: 2, service: FlickerSearchServiceMocker())
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(rError, ServiceError.invalidData)
    }

    func testSucessResult() {
        
        class FlickerSearchServiceMocker: FlickerSearchService {
            
            override func getRequest(requestDto: GetRequestDTO<FlickerSearchRequestParameters>, responseDto: SearchResponseDTO.Type, manager: DataLoader, completion: @escaping (Result<SearchResponseDTO>) -> Void) -> URLSessionTask {
                
                if let path = Bundle.main.path(forResource: "SearchResult", ofType: "json")
                {
                    if let jsonData = NSData(contentsOfFile: path)
                    {
                        if let genericModel = try? JSONDecoder().decode(responseDto, from: jsonData as Data) {
                            completion(Result.Success(genericModel))
                        }
                    }
                }
                return URLSessionDataTask()
            }
        }
        
        let viewModel = SearchViewModel()

        viewModel.getSearchForText("test", page: 2, service: FlickerSearchServiceMocker())
        
        XCTAssertEqual(viewModel.photos.count, 99)
    }
        
    
}
