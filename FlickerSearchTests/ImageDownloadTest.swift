//
//  ImageDownloadTest.swift
//  FlickerSearchTests
//
//  Created by Yogesh Kumar on 01/05/19.
//  Copyright © 2019 Yogesh Kumar. All rights reserved.
//

import XCTest

fileprivate class ImageFetcherMock: ImageFetchProtocol {
    var isImageDownloaded = false
    func imageFromUrl(_ url: URL) -> UIImage? {
        if url.absoluteString == "https://mypic.jpg" {
            isImageDownloaded = true
            return UIImage(named: "placeholder_cover")
        }
        return nil
    }
}

class ImageDownloadTest: XCTestCase {

    let imageUrl = "https://mypic.jpg"
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchImage() {
        
        let manager = ImageDownloadManager.shared
        let fetcher = ImageFetcherMock()
        let testImageUrl = URL(string: imageUrl)!
        let expectation  = self.expectation(description: "CallBack")

        var mImage: UIImage?
        var mUrl: URL?
        manager.downloadImageWithUrl(testImageUrl, fetcher: fetcher) { (image, url, error) in
            mImage = image
            mUrl = url
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(testImageUrl, mUrl, "URL requested and returned are not same")
        XCTAssertNotNil(mImage, "image not returned")
        XCTAssertTrue(fetcher.isImageDownloaded, "Image not downloaded")
    }
    
    func testImageCaching() {
        let manager = ImageDownloadManager.shared
        let fetcher = ImageFetcherMock()
        let testImageUrl = URL(string: imageUrl)!
        let expectation  = self.expectation(description: "CallBack")

        
        var mImage: UIImage?
        var mUrl: URL?
        manager.downloadImageWithUrl(testImageUrl, fetcher: fetcher) { (image, url, error) in
            mImage = image
            mUrl = url
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertFalse(fetcher.isImageDownloaded, "Image not cached")
        XCTAssertEqual(testImageUrl, mUrl, "URL requested and returned are not same")
        XCTAssertNotNil(mImage, "image not returned")
    }
    
    
    func testImageNotFound() {
        let manager = ImageDownloadManager.shared
        let fetcher = ImageFetcherMock()
        let testImageUrl = URL(string: "https://noimage.jpg")!
        let expectation  = self.expectation(description: "CallBack")
        
        
        var mImage: UIImage?
        var mUrl: URL?
        var mError: ServiceError?
        manager.downloadImageWithUrl(testImageUrl, fetcher: fetcher) { (image, url, error) in
            mImage = image
            mUrl = url
            mError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(testImageUrl, mUrl, "URL requested and returned are not same")
        XCTAssertEqual(mError, ServiceError.responseUnsuccessful)
        XCTAssertNil(mImage)
    }

}
