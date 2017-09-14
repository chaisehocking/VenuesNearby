//
//  Photo.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 30/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Photo is an Object in the FourSquare API that represents information about photos and a photo url.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Photo: Model {
    var prefix: String?
    var suffix: String?
    var visibility: String?
}
