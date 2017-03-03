//
//  AuthTokenRefresher.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/3/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Intrepid

public protocol AuthClient {
    func login(email: String, password: String, completion: ((Result<String>) -> Void)?)
}

public protocol CredentialProviding {
    var email: String? { get set }
    var password: String? { get set }
    var token: String? { get set }

    var formattedToken: String? { get }
}

public enum AuthTokenRefreshError: Error {
    case MissingCredentials
    case AuthenticationError(Error)
}

public class AuthTokenRefresher {

    let apiClient: APIClient
    let authClient: AuthClient
    var credentialProvider: CredentialProviding

    init(apiClient: APIClient, authClient: AuthClient, credentialProvider: CredentialProviding) {
        self.apiClient = apiClient
        self.authClient = authClient
        self.credentialProvider = credentialProvider
    }

    func handleUnauthorizedRequest(request: URLRequest, completion: ((Result<Data?>) -> Void)?) {
        guard
            let email = credentialProvider.email,
            let password = credentialProvider.password
        else {
            completion?(.failure(AuthTokenRefreshError.MissingCredentials))
            return
        }

        authClient.login(email: email, password: password) { [weak self] result in
            guard let welf = self else { return }
            switch result {
            case .success(let token):
                welf.credentialProvider.token = token
                var mutableRequest = request
                mutableRequest.setValue(welf.credentialProvider.formattedToken, forHTTPHeaderField: "Authorization")
                welf.apiClient.sendRequest(mutableRequest, completion: completion)
            case .failure(let error):
                welf.credentialProvider.token = nil
                completion?(.failure(AuthTokenRefreshError.AuthenticationError(error)))
            }
        }
    }
}
