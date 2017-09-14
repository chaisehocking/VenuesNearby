//
//  HTTPResponse.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 26/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * HTTPResponse is an Object in the FourSquare API that represents the top level objects returned in a response.
 * It extends from Model so it can have json mapped into it and it's Model properties cretead automatically.
 */
class HTTPResponse: Model {
    var response:Response?
    
}
