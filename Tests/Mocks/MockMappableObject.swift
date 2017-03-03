//
//  MockMappableObject.swift
//  APIClient
//
//  Created by Mark Daigneault on 3/6/17.
//  Copyright © 2017 Mark Daigneault. All rights reserved.
//

import Foundation
import Genome

final class MockMappableObject: BasicMappable {
    var identifier: String = ""
    var name: String = ""

    func sequence(_ map: Map) throws {
        try identifier <~ map["identifier"]
        try name <~ map["name"]
    }
}
