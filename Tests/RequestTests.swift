//
//  RequestTests.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/2/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import XCTest
@testable import APIClient

struct TestRequest: Request {

    static var baseURL: String {
        return "http://intrepid.io"
    }

    static var acceptHeader: String? {
        return "application/json"
    }

    static var authToken: String? {
        return "test-token"
    }

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "test"
    }

    var authenticated: Bool {
        return true
    }

    var queryParameters: [String : Any]? {
        return [
            "param1" : 1,
            "param2" : 2
        ]
    }

    var bodyParameters: [String : Any]? {
        return [
            "object" : [
                "id" : 1,
                "name" : "test"
            ]
        ]
    }

    var contentType: String {
        return "application/json"
    }
}

class RequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
