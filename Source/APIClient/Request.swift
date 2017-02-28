//
//  Request.swift
//
//  Created by Mark Daigneault on 5/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PATCH
    case PUT
    case DELETE
}

public protocol Request {
    static var baseURL: String { get }
    static var version: String { get }
    static var serverAddress: String? { get }
    static var authToken: String? { get set }

    var method: HTTPMethod { get }
    var path: String { get }
    var authenticated: Bool { get }
    var queryParameters: [String: AnyObject]? { get }
    var bodyParameters: [String: AnyObject]? { get }
    var contentType: String { get }

    var urlRequest: URLRequest { get }

    func encodeQueryParameters(request: NSMutableURLRequest, parameters: [String : AnyObject]?)
    func encodeHTTPBody(request: NSMutableURLRequest, parameters: [String : AnyObject]?)
}

public extension Request {

    var contentType: String {
        switch self {
        default:
            return "application/json"
        }
    }

    var urlRequest: URLRequest {
        let baseURL = Foundation.URL(string: Self.baseURL)!
        let url = Foundation.URL(string: path, relativeTo: baseURL) ?? baseURL

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("application/\(Self.serverAddress ?? ""); version=\(Self.version)", forHTTPHeaderField: "Accept")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        if authenticated {
            if let token = Self.authToken {
                request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
            } else {
                print("Error: authenticated request missing token: %@", request)
            }
        }

        encodeQueryParameters(request: request, parameters: queryParameters)
        encodeHTTPBody(request: request, parameters: bodyParameters)

        return request as URLRequest
    }

    func encodeQueryParameters(request: NSMutableURLRequest, parameters: [String : AnyObject]?) {
        guard let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let stringParameters = parameters as? [String : String]
            else { return }

        let queryParameterStringComponents: [String] = stringParameters.map { parameter in
            let key = parameter.0
            let value = parameter.1
            return "\(key)=\(value)"
        }
        let queryParameterString = queryParameterStringComponents.joined(separator: "&")

        let percentEncondedQuery = components.percentEncodedQuery.map { $0 + "&" } ?? "" + queryParameterString
        components.percentEncodedQuery = percentEncondedQuery
        request.url = components.url
    }

    func encodeHTTPBody(request: NSMutableURLRequest, parameters: [String : AnyObject]?) {
        guard let parameters = parameters else { return }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data
        } catch {
            print("Error creating JSON paramters")
        }
    }
}
