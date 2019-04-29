//
//  DataLoaderTest.swift
//  FlickerSearchTests
//
//  Created by Yogesh Kumar on 28/04/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import XCTest

class DataLoaderTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testLoadingData() {

        class NetworkEngineMock: NetworkEngine {

            typealias Handler = NetworkEngine.Handler
            
            func response(_ url: String, method: HTTPMethod, completionHandler: @escaping Handler) -> URLSessionDataTask {
                completionHandler("helloWorld".data(using: .utf8), nil, nil)
                return URLSessionDataTask.init()
            }
        }
        
        let engine = NetworkEngineMock()
        let loader = DataLoader(engine: engine)
        
        var rData: Data?
        var rError: Error?
        let _ = loader.responseGet("hi") { (data, response, error) in
           rData = data
           rError = error
        }
        
        XCTAssertNil(rError)
        XCTAssertEqual(rData, "helloWorld".data(using: .utf8))
    }

}
