//
//  APIClientTests.swift
//  APIClientTests
//
//  Created by Mark Daigneault on 1/17/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import XCTest
@testable import APIClient

class APIClientTests: XCTestCase {

    let testURL = URL(string: "intrepid.io")!
    var sut: APIClient!

    override func setUp() {
        super.setUp()
        sut = APIClient()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDataTaskErrorResult() {
        let error = NSError()
        let result = sut.result(data: nil, response: nil, error: error)
        XCTAssert(result.isFailure)
    }

    func testSuccessResult() {
        let response = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let result = sut.result(data: nil, response: response, error: nil)
        XCTAssert(result.isSuccess)
    }

    func testStatusCodeErrorResult() {
        let response = HTTPURLResponse(url: testURL, statusCode: 400, httpVersion: nil, headerFields: nil)
        let result = sut.result(data: nil, response: response, error: nil)
        XCTAssert(result.isFailure)
    }
}
