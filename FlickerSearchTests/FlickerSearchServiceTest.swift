//
//  FlickerSearchServiceTest.swift
//  FlickerSearchTests
//
//  Created by Yogesh Kumar on 01/05/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import XCTest

class FlickerSearchServiceTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchServiceSuccessfullParsing() {
        
        class NetworkEngineMock: NetworkEngine {
            
            typealias Handler = NetworkEngine.Handler
            
            func response(_ url: String, method: HTTPMethod, completionHandler: @escaping Handler) -> URLSessionDataTask {
                if let path = Bundle.main.path(forResource: "SearchResult", ofType: "json")
                {
                    if let jsonData = NSData(contentsOfFile: path)
                    {
                        let response = HTTPURLResponse(url: URL(string: FLICKR.baseUrl)!, statusCode: 200, httpVersion: "1.1", headerFields: [:])
                            completionHandler(jsonData as Data, response, nil)
                    }
                }
               
                return URLSessionDataTask.init()
            }
        }
        
        let engine = NetworkEngineMock()
        let loader = DataLoader(engine: engine)
        
        let expectation  = self.expectation(description: "CallBack")

        let service = FlickerSearchService()
        let params = FlickerSearchRequestParameters(searchString: "kitten", page: 1)
        let getRequest = GetRequestDTO(queryParameter: params, url: FLICKR.baseUrl)
        var rResponse: SearchResponseDTO?
        var rError: ServiceError?
        let _ = service.getRequest(requestDto: getRequest, responseDto: SearchResponseDTO.self, manager: loader) { result in
            
            switch result {
            case .Success(let response):
                print("success")
                rResponse = response
            case .Failure(let error):
                print("error")
                rError = error
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertNotNil(rResponse)
        XCTAssertNil(rError)
    }
    
    func testQueryBuilderWithoutParams() {
        let service = FlickerSearchService()
        let urlString = service.makeUrl(url: "my/url", queryParmaters: [:])
        
        XCTAssertEqual("my/url", urlString)
    }
    
    func testQueryBuilderWithParams() {
        let params = ["apiKey": "api_key", "format": "json", "text": "kitten"]
        let service = FlickerSearchService()
        let urlString = service.makeUrl(url: "my/url", queryParmaters: params)
        
        var allParamsAdded: Bool = true
        for value in params.values {
            if !urlString.contains(value) {
                allParamsAdded = false
            }
        }
        
        XCTAssertTrue(allParamsAdded, "All params are not added")
    }
    
    func testSearchServiceFailureParsing() {
        
        class NetworkEngineMock: NetworkEngine {
            
            typealias Handler = NetworkEngine.Handler
            
            func response(_ url: String, method: HTTPMethod, completionHandler: @escaping Handler) -> URLSessionDataTask {
                if let path = Bundle.main.path(forResource: "SearchResult", ofType: "json")
                {
                    if let jsonData = NSData(contentsOfFile: path)
                    {
                        completionHandler(jsonData as Data, nil, nil)
                    }
                }
                
                return URLSessionDataTask()
            }
        }
        
        let engine = NetworkEngineMock()
        let loader = DataLoader(engine: engine)
        
        let expectation  = self.expectation(description: "CallBack")
        
        let service = FlickerSearchService()
        let params = FlickerSearchRequestParameters(searchString: "kitten", page: 1)
        let getRequest = GetRequestDTO(queryParameter: params, url: FLICKR.baseUrl)
        var rError: ServiceError?
        let _ = service.getRequest(requestDto: getRequest, responseDto: SearchResponseDTO.self, manager: loader) { result in
            
            switch result {
            case .Success( _):
                print("success")
            case .Failure(let error):
                print("error")
                rError = error
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertNotNil(rError)
        XCTAssertEqual(rError, ServiceError.requestFailed)
    }
}
