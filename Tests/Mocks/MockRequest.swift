//
//  MockRequest.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/6/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
@testable import APIClient

struct TestRequest: Request {

    static var baseURL: String {
        return "http://www.intrepid.io"
    }

    static var acceptHeader: String? {
        return "application/json"
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

    var accessCredentials: AccessCredentials? {
        return MockToken()
    }
}

class MockCredentialProvider: AccessCredentialProviding {
    var accessCredentials: AccessCredentials? = MockToken()
}
