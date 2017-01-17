//
//  ExampleAPIClient.swift
//
//  Created by Mark Daigneault on 5/4/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid
import Genome

class TestObject: MappableObject {

    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    public required init(map: Map) throws {
        self.identifier = try map.extract("identifier")
    }
}

typealias TestObjectResult = (Result<TestObject>) -> ()

class ExampleAPIClient: APIClient {
    
    let session = URLSession()
    internal var requestURLRetryCountMapping = [URL : Int]()
    
    // MARK: - Test API Call

    func getTestObject(testObject: TestObject, completion: TestObjectResult?) {
        let request = Request.getTestObject(testObject).URLRequest
        sendRequest(request as URLRequest, completion: completion)
    }
}
