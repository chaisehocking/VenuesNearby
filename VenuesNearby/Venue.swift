//
//  Venue.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Venue is an Object in the FourSquare API that represents detail about a place.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Venue: Model {
    var id: String?
    var name: String?
    var location: Location?
    var hours: Hours?
    var url: String?
    var photos: PhotoCollection?
    
}
