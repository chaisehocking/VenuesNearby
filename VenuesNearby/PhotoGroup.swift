//
//  PhotoGroup.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 14/9/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

class PhotoGroup: Model {
    var name: String?
    var items: [Photo]?
    
    override func typeForArrayKey(_ key: String) -> Model.Type? {
        if key == "items" {
            return Photo.self
        }
        
        return super.typeForArrayKey(key)
    }
}
