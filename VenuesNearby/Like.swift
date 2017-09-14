//
//  Like.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Like is an Object in the FourSquare API that represents information about how many user have like a Venue.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Like: Model {
    var count: NSNumber?
}
