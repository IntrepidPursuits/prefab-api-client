//
//  AuthTokenRefresher.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/3/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid

public protocol LoginClientDelegate: class {
    func loginClient(_ client: LoginClient, didFinishLoginWithResult result: Result<AccessCredentials>)
    func loginClientDidDisconnect(_ client: LoginClient)
}

public protocol LoginClient {
    var delegate: LoginClientDelegate? { get set }

    func login()
    func logout()

    func refreshLogin(completion: ((Result<AccessCredentials>) -> Void)?)
}

public protocol LoginCredentials {
    func httpBodyParameters() -> [String: Any]
}

public protocol AccessCredentials {
    var expirationDate: Date? { get set }
    func authorize(_ request: inout URLRequest)
}

public protocol AccessCredentialProviding {
    var accessCredentials: AccessCredentials? { get set }
}

public enum AccessCredentialsRefresherError: Error {
    case MissingCredentials
    case AuthenticationError(Error)
}

public class AccessCredentialsRefresher {

    let apiClient: APIClient
    let loginClient: LoginClient
    var accessCredentialsProvider: AccessCredentialProviding

    public init(apiClient: APIClient, loginClient: LoginClient, accessCredentialsProvider: AccessCredentialProviding) {
        self.apiClient = apiClient
        self.loginClient = loginClient
        self.accessCredentialsProvider = accessCredentialsProvider
    }

    func handleUnauthorizedRequest(request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        loginClient.refreshLogin { [weak self] result in
            switch result {
            case .success(let accessCredentials):
                var mutableRequest = request

                self?.accessCredentialsProvider.accessCredentials = accessCredentials

                accessCredentials.authorize(&mutableRequest)
                self?.apiClient.sendRequest(mutableRequest, completion: completion)
            case .failure(let error):
                self?.accessCredentialsProvider.accessCredentials = nil
                completion?(.failure(AccessCredentialsRefresherError.AuthenticationError(error)))
            }
        }
    }
}
