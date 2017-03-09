//
//  Data+APIClient.swift
//  APIClient
//
//  Created by Christopher Shea on 3/8/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation

public extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
