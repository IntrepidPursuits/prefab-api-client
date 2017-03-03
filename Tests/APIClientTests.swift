//
//  APIClientTests.swift
//  APIClientTests
//
//  Created by Mark Daigneault on 1/17/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import XCTest
import Intrepid
import Genome
@testable import APIClient

class APIClientTests: XCTestCase {

    let testURL = URL(string: "intrepid.io")!
    let testRequest = TestRequest().urlRequest

    var sut: APIClient!

    override func setUp() {
        super.setUp()
        sut = APIClient()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Core

    func testDataTaskErrorResult() {
        let error = NSError()
        let result = sut.result(request: testRequest, completion: nil, data: nil, response: nil, error: error)
        XCTAssert(result!.isFailure)
    }

    func testSuccessResult() {
        let response = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let result = sut.result(request: testRequest, completion: nil, data: nil, response: response, error: nil)
        XCTAssert(result!.isSuccess)
    }

    func testStatusCodeErrorResult() {
        let response = HTTPURLResponse(url: testURL, statusCode: 400, httpVersion: nil, headerFields: nil)
        let result = sut.result(request: testRequest, completion: nil, data: nil, response: response, error: nil)
        XCTAssert(result!.isFailure)
    }

    // MARK: - Genome

    func testVoidResult() {
        let success = sut.voidResult(dataResult: .success(nil))
        XCTAssert(success.isSuccess)
    }

    func testSingluarMappableResult() {
        let json = ["identifier" : "1", "name" : "test"]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let success: Result<MockMappableObject> = sut.mappableObjectResult(keyPath: nil, dataResult: .success(data))
            let mappedObject = success.value
            XCTAssertEqual(mappedObject?.identifier, "1")
            XCTAssertEqual(mappedObject?.name, "test")
        } catch {
            XCTFail("Unable to create or deserialize data")
        }
    }

    func testArrayMappableResult() {
        let json = [
            ["identifier" : "1", "name" : "test"],
            ["identifier" : "2", "name" : "another_test"]
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let success: Result<[MockMappableObject]> = sut.mappableArrayResult(keyPath: nil, dataResult: .success(data))
            let array = success.value
            XCTAssertEqual(array?[0].identifier, "1")
            XCTAssertEqual(array?[0].name, "test")
            XCTAssertEqual(array?[1].identifier, "2")
            XCTAssertEqual(array?[1].name, "another_test")
        } catch {
            XCTFail("Unable to create or deserialize data")
        }
    }
}
