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
        return "http://www.intrepid.io"
    }

    static var acceptHeader: String? {
        return "application/json"
    }

    static var authToken: String? {
        return "test-token"
    }

    static var authTokenHeader: String? {
        return ""
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
            "param1" : "1",
            "param2" : "2"
        ]
    }

    var bodyParameters: [String : Any]? {
        return [
            "object" : [
                "id" : "1",
                "name" : "test"
            ]
        ]
    }

    var contentType: String {
        return "application/json"
    }
}

class RequestTests: XCTestCase {

    let testRequest = TestRequest()
    lazy var sut: URLRequest = self.testRequest.urlRequest

    func testURL() {
        let url = URL(string: "http://www.intrepid.io/test?param1=1&param2=2")
        XCTAssertEqual(sut.url, url)
    }

    func testHTTPMethod() {
        XCTAssertEqual(sut.httpMethod, testRequest.method.rawValue)
    }

    func testBody() {
        guard let httpBody = sut.httpBody else {
            XCTFail("HTTP body data nil")
            return
        }
        do {
            guard
                let json = try JSONSerialization.jsonObject(with: httpBody, options: []) as? [String : Any],
                let jsonObject = json["object"] as? [String : String],
                let bodyParameterObject = testRequest.bodyParameters?["object"] as? [String : String]
            else {
                XCTFail("Unable to get dictionary object from HTTP body json")
                return
            }
            XCTAssertEqual(jsonObject, bodyParameterObject)
        } catch {
            XCTFail("Unable to deserialize HTTP body data")
        }
    }

    func testHTTPHeaderValues() {
        let headers = sut.allHTTPHeaderFields
        XCTAssertEqual(headers?["Accept"], TestRequest.acceptHeader)
        XCTAssertEqual(headers?["Content-Type"], testRequest.contentType)
        XCTAssertEqual(headers?["Authorization"], "\(TestRequest.authTokenHeader!)"+"\(TestRequest.authToken!)")
    }
}
