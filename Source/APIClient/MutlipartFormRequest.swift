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
    var formDataParameters: [String: FormParameter]? { get }

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

        formDataParameters?.forEach {
            body.append("--\(Self.boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\($0.key)\"")
            body.append("; filename=\"\($0.value.filename)\"")
            body.append("\r\n")
            body.append("Content-Type: \($0.value.mediaType)")
            body.append("\r\n\r\n")
            body.append($0.value.data as! Data)
            body.append("\r\n")
            body.append("--\(Self.boundary)--\r\n")
        }

        request.httpBody = body
    }
}

public struct FormParameter {
    public let filename: String
    public let mediaType: String
    public let data: Data

    public init(filename: String, mediaType: String, data: Data) {
        self.filename = filename
        self.mediaType = mediaType
        self.data = data
    }
}
