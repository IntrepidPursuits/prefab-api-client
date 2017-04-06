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
            DispatchQueue.main.async {
                completion?(self.voidResult(dataResult: dataResult))
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    internal func voidResult(dataResult: Result<Data?>) -> Result<Void> {
        switch dataResult {
        case .success(_):
            return .success()
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Singular Result Type

    public func sendRequest<T: NodeInitializable>(_ request: URLRequest, keyPath: String? = nil, completion: ((Result<T>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            DispatchQueue.main.async{
                completion?(self.nodeInitializableResult(keyPath: keyPath, dataResult: dataResult))
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    internal func nodeInitializableResult<T: NodeInitializable>(keyPath: String?, dataResult: Result<Data?>) -> Result<T> {
        var result: Result<T>

        switch dataResult {
        case .success(let data):
            result = .failure(APIClientError.unableToMapResult)
            do {
                if let node = try data?.makeNode() {
                    if let keyPath = keyPath, let subNode = node[keyPath] {
                        result = try .success(T(node: subNode))
                    } else {
                        result = try .success(T(node: node))
                    }
                }
            } catch {
                print("Error creating and mapping node: \(error)")
            }
        case .failure(let error):
            result = .failure(error)
        }

        return result
    }

    // MARK: - Array Result Type

    public func sendRequest<T: NodeInitializable>(_ request: URLRequest, keyPath: String? = nil, completion: ((Result<[T]>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            DispatchQueue.main.async{
                completion?(self.nodeInitializableArrayResult(keyPath: keyPath, dataResult: dataResult))
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    internal func nodeInitializableArrayResult<T: NodeInitializable>(keyPath: String?, dataResult: Result<Data?>) -> Result<[T]> {
        var result: Result<[T]>

        switch dataResult {
        case .success(let data):
            result = .failure(APIClientError.unableToMapResult)
            do {
                if let node = try data?.makeNode() {
                    if node.isNull {
                        result = .success([T]())
                    } else if let keyPath = keyPath, let subNode = node[keyPath] {
                        result = try .success([T](node: subNode))
                    } else {
                        result = try .success([T](node: node))
                    }
                }
            } catch {
                print("Error creating and mapping array node: \(error)")
            }
        case .failure(let error):
            result = .failure(error)
        }

        return result
    }
}
