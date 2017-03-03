//
//  AuthenticationTests.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/6/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import XCTest
@testable import APIClient

class AuthenticationTests: XCTestCase {

    let apiClient = MockAPIClient()
    let authClient = MockAuthClient()
    let credentialProvider = MockCredentialProvider()

    var sut: AuthTokenRefresher!

    override func setUp() {
        super.setUp()

        sut = AuthTokenRefresher(apiClient: apiClient, authClient: authClient, credentialProvider: credentialProvider)
    }
    
    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testAuthTokenRefreshSuccess() {
        let testRequest = TestRequest().urlRequest

        apiClient.success = true
        authClient.success = true

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            XCTAssertEqual(self?.credentialProvider.token, "token")
            XCTAssert(result.isSuccess)
        }
    }

    func testAuthTokenRefreshAPIClientFailure() {
        let testRequest = TestRequest().urlRequest

        // Token refresh succeeds, subsequest request fails
        apiClient.success = false
        authClient.success = true

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            XCTAssertEqual(self?.credentialProvider.token, "token")
            XCTAssert(result.isFailure)
        }

        // Token refresh fails
        authClient.success = false

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            XCTAssertNil(self?.credentialProvider.token)
            XCTAssert(result.isFailure)
        }
    }

}
