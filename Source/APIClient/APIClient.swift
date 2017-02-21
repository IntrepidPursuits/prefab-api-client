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

public class APIClient {

    public let session: URLSession

    public convenience init() {
        self.init(session: .shared)
    }

    public init(session: URLSession) {
        self.session = session
    }

    public func sendRequest(_ request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let completion = completion else { return }

            if let error = error {
                completion(.failure(APIClientError.dataTaskError(error: error)))
            } else if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200..<300:
                    completion(.success(data))
                default:
                    let error = APIClientError.httpError(statusCode: statusCode, response: httpResponse, data: data)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(APIClientError.unknown))
            }
        })
        dataTask.resume()
    }
}
