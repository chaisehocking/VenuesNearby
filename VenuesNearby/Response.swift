//
//  Response.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 26/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Response is an Object in the FourSquare API that represents the resonse in a Venue search.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Response: Model {
    var groups: [Group]?
    var venue: Venue?
    
    /**
     * Provides the correct class for the array key groups.
     * @param see superclass
     */
    override func typeForArrayKey(_ key: String) -> Model.Type? {
        if key == "groups" {
            return Group.self
        }
        
        return super.typeForArrayKey(key)
    }
}
