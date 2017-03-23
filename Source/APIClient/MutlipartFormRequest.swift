//
//  MutlipartFormRequest.swift
//  APIClient
//
//  Created by Christopher Shea on 3/23/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation

public protocol MultipartFormRequest: Request {
    // Boundary can't have a default value defined in extension or else it will be re-generated each time it's called.
    // It would be nice, hoewever, to provide a default implementation because it will often/always be formatted the same way.
    static var boundary: String { get }

    var unnamedBodyParameters: [String: Any]? { get }
    var formDataParameters: [String: Any]? { get }

    func encodeFormBody(request: inout URLRequest)
}

public extension MultipartFormRequest {

    var contentType: String {
        return "multipart/form-data; boundary=\(Self.boundary)"
    }

    func encodeFormBody(request: inout URLRequest) {

        var body = Data()

        unnamedBodyParameters?.forEach {
            body.append("--\(Self.boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\($0.key)\"")
            body.append("\r\n\r\n")
            body.append("\($0.value)")
            body.append("\r\n")
            body.append("--\(Self.boundary)--\r\n")
        }

        // Create type that wraps data params below so that we can provide MIME type and filename?

        formDataParameters?.forEach {
            body.append("--\(Self.boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\($0.key)\"")
            // User-specified filename would go in line below.
            body.append("; filename=\"untitled\"")
            // Following two lines would add MIME type for each param
            //            body.append("\r\n")
            //            body.append("Content-Type: image/png")
            body.append("\r\n\r\n")
            body.append($0.value as! Data)
            body.append("\r\n")
            body.append("--\(Self.boundary)--\r\n")
        }

        request.httpBody = body
    }
}
