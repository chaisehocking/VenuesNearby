//
//  Group.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 26/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Group is an Object in the FourSquare API that represents a groups of items from a Venue search.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Group: Model {
    var type: String?
    var items: [Item]?
    
    /**
     * Provides the correct class for the array key items.
     * @param see superclass
     */
    override func typeForArrayKey(_ key: String) -> Model.Type? {
        if key == "items" {
            return Item.self
        }
        
        return super.typeForArrayKey(key)
    }
}
