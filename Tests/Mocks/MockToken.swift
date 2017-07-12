//
//  MockToken.swift
//  APIClient
//
//  Created by Mark Daigneault on 7/12/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
@testable import APIClient

struct MockToken: AccessCredentials {
    let value: String

    init(value: String = "token") {
        self.value = value
    }

    func authorize(_ request: inout URLRequest) {
        request.setValue("Token token=\(value)", forHTTPHeaderField: "Authorization")
    }
}
