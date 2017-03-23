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

public struct MediaType {
    public static let json = "application/json"
    public static let javascript = "application/javascript"
    public static let xml = "application/xml"
    public static let zip = "application/zip"
    public static let urlEncodedForm = "application/x-www-form-urlencoded"
    public static let multipartForm = "multipart/form-data"
    public static let png = "image/png"
    public static let jpeg = "image/jpeg"
    public static let gif = "image/gif"
    public static let mpeg = "audio/mpeg"
    public static let vorbis = "audio/vorbis"
    public static let css = "text/css"
    public static let html = "text/html"
    public static let plainText = "text/plain"
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
