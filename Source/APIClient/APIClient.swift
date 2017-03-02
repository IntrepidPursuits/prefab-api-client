//
//  APIClient.swift
//  APIClient
//
//  Created by Mark Daigneault on 2/16/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid

enum APIClientError: Error {
    case httpError(statusCode: Int, response: HTTPURLResponse, data: Data?)
    case dataTaskError(error: Error)
    case unableToMapResult
    case unknown
}

open class APIClient {

    public let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func sendRequest(_ request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        let dataTask = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let welf = self,
                let completion = completion
            else { return }
            completion(welf.result(data: data, response: response, error: error))
        })
        dataTask.resume()
    }

    internal func result(data: Data?, response: URLResponse?, error: Error?) -> Result<Data?> {
        if let error = error {
            return .failure(APIClientError.dataTaskError(error: error))
        } else if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200..<300:
                return .success(data)
            default:
                let error = APIClientError.httpError(statusCode: statusCode, response: httpResponse, data: data)
                return .failure(error)
            }
        } else {
            return .failure(APIClientError.unknown)
        }
    }
}
