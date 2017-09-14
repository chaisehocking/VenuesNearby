//
//  Item.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 26/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Item is an Object in the FourSquare API that holds a venue and information about a venue.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Item: Model {
    var tips: [Tip]?
    var venue: Venue?
    
    /**
     * Provides the correct class for the array key tips.
     * @param see superclass
     */
    override func typeForArrayKey(_ key: String) -> Model.Type? {
        if key == "tips" {
            return Tip.self
        }
        
        return super.typeForArrayKey(key)
    }
}
