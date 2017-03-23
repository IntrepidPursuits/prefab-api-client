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

public enum MediaType: String {
    case json = "application/json"
    case javascript = "application/javascript"
    case xml = "application/xml"
    case zip = "application/zip"
    case urlEncodedForm = "application/x-www-form-urlencoded"
    case multipartForm = "multipart/form-data"
    case png = "image/png"
    case jpeg = "image/jpeg"
    case gif = "image/gif"
    case mpeg = "audio/mpeg"
    case vorbis = "audio/vorbis"
    case css = "text/css"
    case html = "text/html"
    case plainText = "text/plain"
}

public protocol Request {
    static var baseURL: String { get }
    static var acceptHeader: String? { get }
    static var credentialProvider: CredentialProviding? { get }

    var method: HTTPMethod { get }
    var path: String { get }
    var authenticated: Bool { get }
    var queryParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    // Should content type be string or MediaType? Making it MediaType means being locked into one our cases.
    var contentType: String { get }
}

public extension Request {

    var urlRequest: URLRequest {
        let baseURL = Foundation.URL(string: Self.baseURL)!
        let url = Foundation.URL(string: path, relativeTo: baseURL) ?? baseURL

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue(Self.acceptHeader, forHTTPHeaderField: "Accept")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        if authenticated {
            Self.credentialProvider?.authorizeRequest(&request)
        }

        encodeQueryParameters(request: &request, parameters: queryParameters)

        // If we want MutltipartFormRequest to inherit urlRequest behavior from Request, then optional casting like below
        // is the only way I got it to work consistently.
        if let form = self as? MultipartFormRequest {
            form.encodeFormBody(request: &request)
        } else {
            encodeHTTPBody(request: &request, parameters: bodyParameters)
        }

        return request as URLRequest
    }

    func encodeQueryParameters(request: inout URLRequest, parameters: [String : Any]?) {
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

    func encodeHTTPBody(request: inout URLRequest, parameters: [String : Any]?) {
        guard let parameters = parameters else { return }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data
        } catch {
            print("Error creating JSON paramters")
        }
    }
}
