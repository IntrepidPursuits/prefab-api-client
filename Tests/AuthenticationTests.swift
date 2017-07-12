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
    let loginClient = MockLoginClient()
    let credentialProvider = MockCredentialProvider()

    var sut: AccessCredentialsRefresher!

    override func setUp() {
        super.setUp()

        sut = AccessCredentialsRefresher(apiClient: apiClient, loginClient: loginClient, accessCredentialsProvider: credentialProvider)
    }
    
    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testAuthTokenRefreshSuccess() {
        let testRequest = TestRequest().urlRequest

        apiClient.success = true
        loginClient.success = true

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            guard let token = self?.credentialProvider.accessCredentials as? MockToken else {
                XCTFail("Expected MockToken value")
                return
            }

            XCTAssertEqual(token.value, "new-token")
            XCTAssert(result.isSuccess)
        }
    }

    func testAuthTokenRefreshAPIClientFailure() {
        let testRequest = TestRequest().urlRequest

        // Token refresh succeeds, subsequest request fails
        apiClient.success = false
        loginClient.success = true

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            guard let token = self?.credentialProvider.accessCredentials as? MockToken else {
                XCTFail("Expected MockToken value")
                return
            }

            XCTAssertEqual(token.value, "new-token")
            XCTAssert(result.isFailure)
        }

        // Token refresh fails
        loginClient.success = false

        sut.handleUnauthorizedRequest(request: testRequest) { [weak self] result in
            XCTAssertNil(self?.credentialProvider.accessCredentials)
            XCTAssert(result.isFailure)
        }
    }

    func testCredentialProviderAuthorizedRequest() {
        var testRequest = TestRequest().urlRequest
        credentialProvider.accessCredentials?.authorize(&testRequest)
        XCTAssertEqual(testRequest.value(forHTTPHeaderField: "Authorization"), "Token token=token")
    }
}
