//
//  ExampleAPIClient.swift
//
//  Created by Mark Daigneault on 5/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid
import Genome

final class TestObject: BasicMappable {

    var identifier: String = ""

    func sequence(_ map: Map) throws {
        try identifier <~ map["identifier"]
    }
}

typealias TestObjectResult = (Result<TestObject>) -> ()

class ExampleAPIClient: APIClient {

    // MARK: - Test API Call

    func getTestObject(testObject: TestObject, completion: TestObjectResult?) {
        let request = Request.getTestObject(testObject).URLRequest
        sendRequest(request, completion: completion)
    }
}
