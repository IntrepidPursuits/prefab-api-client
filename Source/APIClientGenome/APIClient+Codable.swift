//
//  APIClient+Codable.swift
//  APIClient
//
//  Created by Mark Daigneault on 2/16/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid

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
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Singular Result Type

    public func sendRequest<T: Codable>(_ request: URLRequest, keyPath: String? = nil, completion: ((Result<T>) -> Void)?) {
        let dataRequestCompletion: (Result<Data?>) -> Void = { dataResult in
            DispatchQueue.main.async{
                completion?(self.nodeInitializableResult(keyPath: keyPath, dataResult: dataResult))
            }
        }
        sendRequest(request, completion: dataRequestCompletion)
    }

    internal func nodeInitializableResult<T: Codable>(keyPath: String?, dataResult: Result<Data?>) -> Result<T> {
        var result: Result<T>

        switch dataResult {
        case .success(let data):
            result = .failure(APIClientError.unableToMapResult)
            guard let data = data else {
                return result
            }
            do {
                let decoder = JSONDecoder()

                if let keyPath = keyPath,
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
                    let objectAtKeyPath = jsonObject[keyPath] as? T {
                    result = .success(objectAtKeyPath)
                } else {
                    let object = try decoder.decode(T.self, from: data)
                    result = .success(object)
                }
            } catch {
                print("Error creating and mapping node: \(error)")
            }
        case .failure(let error):
            result = .failure(error)
        }

        return result
    }
}
