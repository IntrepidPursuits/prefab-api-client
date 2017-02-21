//
//  APIClient+Genome.swift
//  APIClient
//
//  Created by Mark Daigneault on 2/16/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid
import Genome

public extension APIClient {

    // MARK: - Void Result Type

    public func sendRequest(_ request: URLRequest, completion: ((Result<Void>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            guard let completion = completion else { return }

            var result: Result<Void>

            switch dataResult {
            case .success(_):
                result = .success()
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    // MARK: - Singular Result Type

    public func sendRequest<T: MappableObject>(_ request: URLRequest, completion: ((Result<T>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            guard let completion = completion else { return }

            var result: Result<T>

            switch dataResult {
            case .success(let data):
                result = .failure(APIClientError.unableToMapResult)
                do {
                    if let node = try data?.makeNode() {
                        result = try .success(T(node: node))
                    }
                } catch {
                    print("Error creating and mapping node: \(error)")
                }
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async{
                completion(result)
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    // MARK: - Array Result Type

    public func sendRequest<T: MappableObject>(_ request: URLRequest, completion: ((Result<[T]>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            guard let completion = completion else { return }

            var result: Result<[T]>

            switch dataResult {
            case .success(let data):
                result = .failure(APIClientError.unableToMapResult)
                do {
                    if let node = try data?.makeNode() {
                        if node.isNull {
                            result = .success([T]())
                        } else {
                            try result = .success([T](node: node))
                        }
                    }
                } catch {
                    print("Error creating and mapping array node: \(error)")
                }
            case .failure(let error):
                result = .failure(error)
            }

            DispatchQueue.main.async{
                completion(result)
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }
}
