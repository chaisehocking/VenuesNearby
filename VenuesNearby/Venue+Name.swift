//
//  Venue+Name.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 31/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * This extension is responsible for returning a possesive name from a Venue's name.
 */
extension Venue {
    
    /**
     * This method will add an apostrophe s to a name unles it already end in an s.
     * This follow the basic rules of English.
     * If the name ends in an s already, it just adds an apostrophe.
     * @return String, the possesive version of the Venue's name or nil if it didn't have a name
     */
    func possesiveName() -> String? {
        guard let safeName = self.name else {
            return nil
        }
        
        if safeName.lowercased().hasSuffix("s") {
            return "\(safeName)'"
        } else {
            return "\(safeName)'s"
        }
    }
}
