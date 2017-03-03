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

    var credentialProvider: CredentialProviding {
        return MockCredentialProvider()
    }
}

class MockCredentialProvider: CredentialProviding {
    var email: String? {
        get {
            return "markd@intrepid.io"
        }
        set {

        }
    }

    var password: String? {
        get {
            return "Intrepid11!"
        }
        set {

        }
    }

    private var _token: String?

    var token: String? {
        get {
            return _token
        }
        set {
            _token = newValue
        }
    }

    var formattedToken: String? {
        if let token = token {
            return "Token token=\(token)"
        } else {
            return nil
        }
    }
}
