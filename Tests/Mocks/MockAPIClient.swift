//
//  MockAPIClient.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/6/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid
@testable import APIClient

class MockAPIClient: APIClient {

    var success: Bool = true

    override func sendRequest(_ request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        if success {
            completion?(.success(nil))
        } else {
            completion?(.failure(APIClientError.unknown))
        }
    }
}
