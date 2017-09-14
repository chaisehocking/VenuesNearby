//
//  PhotoCollection.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 14/9/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation
class PhotoCollection: Model {
    var groups: [PhotoGroup]?
    
    override func typeForArrayKey(_ key: String) -> Model.Type? {
        if key == "groups" {
            return PhotoGroup.self
        }
        
        return super.typeForArrayKey(key)
    }
    
}
