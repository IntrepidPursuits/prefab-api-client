//
//  Request.swift
//
//  Created by Mark Daigneault on 5/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Genome

enum HTTPMethod: String {
    case GET
    case POST
    case PATCH
    case PUT
    case DELETE
}

enum Request {
    static let baseURLString = "https://<your-server-here>.herokuapp.com"
    static let version = "1"
    static var authToken: String?

    // MARK: - Request Types

    //case getTestObject(TestObject)

    // MARK: - NSURLRequest Construction

    var method: HTTPMethod {
        switch self {
        /*
        case .getTestObject:
            return .GET
        */
        default:
            return .GET
        }
    }

    var path: String {
        switch self {
        /*
        case .getTestObject(let object):
            return "objects/\(object.identifier)"
        */
        default:
            return ""
        }
    }

    var authenticated: Bool {
        switch self {
        /*
        case .getTestObject:
            return true
        */
        default:
            return false
        }
    }

    var queryParameters: [String : AnyObject]? {
        switch self {
            // Serialize query/body parameters
        default:
            return nil
        }
    }
    
    var bodyParameters: [String : AnyObject]? {
        switch self {
        // Serialize query/body parameters
        default:
            return nil
        }
    }

    var URLRequest: URLRequest {
        let baseURL = Foundation.URL(string: Request.baseURLString)!
        let URL = baseURL.appendingPathComponent(path)
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = method.rawValue

        request.setValue("application/<your-server-here>; version=\(Request.version)", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated {
            if let token = Request.authToken {
                request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
            } else {
                print("Error: authenticated request missing token: %@", request)
            }
        }

        encodeQueryParameters(request: request, parameters: queryParameters)
        encodeHTTPBody(request: request, parameters: bodyParameters)
        return request as URLRequest
    }

    // MARK: - Parameters

    fileprivate func encodeQueryParameters(request: NSMutableURLRequest, parameters: [String : AnyObject]?) {
        guard let URL = request.url,
            var components = URLComponents(url: URL, resolvingAgainstBaseURL: false),
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
    
    
    fileprivate func encodeHTTPBody(request: NSMutableURLRequest, parameters: [String : AnyObject]?) {
        guard let parameters = parameters else { return }

        do {
            let node = Node(any: parameters)
            let json = try Data(node: node)
            request.httpBody = json
        } catch {
            print("Error creating JSON paramters")
        }
    }
}
