//
//  APIClient.swift
//  APIClient
//
//  Created by Mark Daigneault on 2/16/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid

public enum APIClientError: Error {
    case httpError(statusCode: Int, response: HTTPURLResponse, data: Data?)
    case dataTaskError(error: Error)
    case unableToMapResult
    case unknown
}

open class APIClient {

    public let session: URLSession
    public let decoder: JSONDecoder
    public var accessCredentialsRefresher: AccessCredentialsRefresher? = nil

    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    public func sendRequest(_ request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        let dataTask = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let welf = self,
                let completion = completion,
                let result  = welf.result(request: request, completion: completion, data: data, response: response, error: error)
            else { return }
            completion(result)
        })
        dataTask.resume()
    }

    internal func result(
        request: URLRequest,
        completion: ((Result<Data?>) -> Void)?,
        data: Data?,
        response: URLResponse?,
        error: Error?) -> Result<Data?>? {

        if let error = error {
            return .failure(APIClientError.dataTaskError(error: error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(APIClientError.unknown)
        }

        let statusCode = httpResponse.statusCode
        
        switch statusCode {
        case 200..<300:
            return .success(data)
        case 401:
            if let accessCredentialsRefresher = accessCredentialsRefresher {
                accessCredentialsRefresher.handleUnauthorizedRequest(request: request, completion: completion)
                return nil
            } else {
                let error = APIClientError.httpError(statusCode: statusCode, response: httpResponse, data: data)
                return .failure(error)
            }
        default:
            let error = APIClientError.httpError(statusCode: statusCode, response: httpResponse, data: data)
            return .failure(error)
        }
    }
}
