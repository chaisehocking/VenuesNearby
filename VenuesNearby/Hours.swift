//
//  Hours.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 30/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Hours is an Object in the FourSquare API that represents the current opening hours status of a venue.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Hours: Model {
    var status: String?
    var isOpen: NSNumber?
}
