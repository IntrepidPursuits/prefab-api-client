//
//  APIClient.swift
//
//  Created by Mark Daigneault on 5/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid
import Genome

enum APIClientError: Error {
    case keyPathNotFound
    case unableToMapResult
    case unauthorized
    case unknown
}

/**
 Defines the interface for which API client objects must conform.
 
 All general API client responsibilities are implemented internally by a protocol extension,
 so classes adopting this protocol should only expose application-specific functions
 (e.g. `getSomeObjects()`, `createUser()`, etc.)
 */
protocol APIClient: class {
    var session: URLSession { get }

    func sendRequest(_ request: URLRequest, targetPath: String, completion: ((Result<Void>) -> Void)?)
    func sendRequest<T: MappableObject>(_ request: URLRequest, targetPath: String, completion: ((Result<T>) -> Void)?)
    func sendRequest<T: MappableObject>(_ request: URLRequest, targetPath: String, completion: ((Result<[T]>) -> Void)?)
    
    // TODO: this shouldn't need to be implemented by conforming objects
    var requestURLRetryCountMapping: [URL : Int] { get set }
}

extension APIClient {

    // MARK: - Void Result Type

    func sendRequest(_ request: URLRequest, targetPath: String = "", completion: ((Result<Void>) -> Void)?) {
        sendDataTask(request: request, targetPath: targetPath) { jsonResult in
            guard let completion = completion else { return }

            var result: Result<Void>

            switch jsonResult {
            case .success(_):
                result = .success()
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Singular Result Type

    func sendRequest<T: MappableObject>(_ request: URLRequest, targetPath: String = "", completion: ((Result<T>) -> Void)?) {
        sendDataTask(request: request, targetPath: targetPath) { jsonResult in
            guard let completion = completion else { return }

            var result: Result<T>

            switch jsonResult {
            case .success(let json):
                do {
                    try result = .success(T(node: json))
                } catch {
                    result = .failure(APIClientError.unableToMapResult)
                }
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async{
                completion(result)
            }
        }
    }

    // MARK: - Array Result Type

    func sendRequest<T: MappableObject>(_ request: URLRequest, targetPath: String = "", completion: ((Result<[T]>) -> Void)?) {
        sendDataTask(request: request, targetPath: targetPath) { jsonResult in
            guard let completion = completion else { return }

            var result: Result<[T]>

            switch jsonResult {
            case .success(let json):
                do {
                    if json.isNull {
                        result = .success([T]())
                    } else {
                        try result = .success([T](node: json))
                    }
                } catch {
                    result = .failure(APIClientError.unableToMapResult)
                }
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Shared

    fileprivate func sendDataTask(request: URLRequest, targetPath: String = "", completion: ((Result<Node>) -> Void)?) {
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let completion = completion else { return }

            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                var json: Node = .null
                if let data = data, data.count > 0 {
                    do {
                        json = try data.makeNode()
                        if let boolValue = json.bool {
                            json = try ["value" : boolValue].makeNode()
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }

                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200..<300:
                    self.handleSuccess(request: request, targetPath: targetPath, repsonseJson: json, completion: completion)
                case 401:
                    self.handleUnauthorizedError(request: request, targetPath: targetPath, completion: completion)
                default:
                    self.handleError(request: request, responseJson: json, statusCode: statusCode, completion: completion)
                }
            } else {
                completion(.failure(APIClientError.unknown))
            }
        }) 
        dataTask.resume()
    }

    fileprivate func handleSuccess(request: URLRequest, targetPath: String, repsonseJson json: Node, completion: (Result<Node>) -> Void) {
        self.resetRetryCount(request: request)

        if json.isNull { // Assume no data is expected, e.g. POST/PATCH
            completion(.success(json))
        } else if let nestedJson = json[targetPath] {  // Found specified key path in JSON
            completion(.success(nestedJson))
        } else {    // Data exists but key path not found
            completion(.failure(APIClientError.keyPathNotFound))
        }
    }

    fileprivate func handleUnauthorizedError(request: URLRequest, targetPath: String, completion: @escaping (Result<Node>) -> Void) {
        let URL = request.url!  // If we get a specific status code, URL should not be nil
        let currentRetryCount = self.requestURLRetryCountMapping[URL] ?? 0

        if currentRetryCount > 0 {
            // If request fails repeatedly for some reason, don't retry infinitely
            self.resetRetryCount(request: request)
            completion(.failure(APIClientError.unauthorized))
        } else {
            self.requestURLRetryCountMapping[URL] = currentRetryCount + 1
            self.authorizationFailed(request: request) { result in
                switch result {
                case .success(let updatedRequest):
                    self.sendDataTask(request: updatedRequest, targetPath: targetPath, completion: completion)
                case .failure(let error):
                    // Saved credentials are no longer valid, log out
                    completion(.failure(error))
                }
            }
        }
    }

    fileprivate func handleError(request: URLRequest, responseJson json: Node, statusCode: Int, completion: (Result<Node>) -> Void) {
        self.resetRetryCount(request: request)

        let errorMessage = json["errors"]?.string ?? "Encountered an error communicating with the server"
        let error = NSError(domain: NSURLErrorDomain, code: statusCode, userInfo: [NSLocalizedDescriptionKey : errorMessage])
        completion(.failure(error))
    }

    // MARK: - Unauthorized Retry Handling

    func authorizationFailed(request: URLRequest, authCompletion: @escaping (Result<URLRequest>) -> ()) {
        authCompletion(.failure(APIClientError.unauthorized))
    }

    func resetRetryCount(request: URLRequest) {
        guard let URL = request.url else { return }
        requestURLRetryCountMapping[URL] = 0
    }
}
