//
//  Tip.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * Tip is an Object in the FourSquare API that represents information uploaded by users.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class Tip: Model {
    var likes: Like?
    var photo: Photo?
}
