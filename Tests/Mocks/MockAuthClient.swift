//
//  MockAuthClient.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/6/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid
@testable import APIClient

class MockLoginClient: LoginClient {

    var success: Bool = true

    var delegate: LoginClientDelegate?

    func login() {
        if success {
            let token = MockToken()
            delegate?.loginClient(self, didFinishLoginWithResult: .success(token))
        } else {
            delegate?.loginClient(self, didFinishLoginWithResult: .failure(APIClientError.unknown))
        }
    }

    func logout() {
        delegate?.loginClientDidDisconnect(self)
    }

    func refreshLogin(completion: ((Result<AccessCredentials>) -> Void)?) {
        if success {
            let token = MockToken(value: "new-token")
            completion?(.success(token))
        } else {
            completion?(.failure(APIClientError.unknown))
        }
    }
}
