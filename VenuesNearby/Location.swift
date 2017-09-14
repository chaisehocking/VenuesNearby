//
//  Location.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 27/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Location is an Object in the FourSquare API that represents address information.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Location: Model {
    var formattedAddress: [String]?
}
