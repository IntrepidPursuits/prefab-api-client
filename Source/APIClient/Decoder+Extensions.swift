//
//  Decoder+Extensions.swift
//  APIClient
//
//  Created by Litteral, Maximilian on 10/26/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation

enum CodingError: Error {
    case RuntimeError(String)
}

extension Decodable {
    init(data: Data, keyPath: String? = nil, decoder: JSONDecoder) throws {
        if let keyPath = keyPath {
            let topLevel = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            guard let nestedJson = (topLevel as AnyObject).value(forKeyPath: keyPath) else { throw CodingError.RuntimeError("Cannot decode data to object")  }
            let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
            let value = try decoder.decode(Self.self, from: nestedData)
            self = value
            return
        }
        let value = try decoder.decode(Self.self, from: data)
        self = value
    }
}
