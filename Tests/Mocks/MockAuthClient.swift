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

class MockAuthClient: AuthClient {
    var success: Bool = true

    func login(email: String, password: String, completion: ((Result<String>) -> Void)?) {
        if success {
            completion?(.success("token"))
        } else {
            completion?(.failure(APIClientError.unknown))
        }
    }
}
