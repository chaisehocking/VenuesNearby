//
//  PhotoCollection+Phtoto.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 14/9/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation
extension PhotoCollection {
    
    
    func firstVenuePhoto() -> Photo? {
        guard let venuePhotos = venuePhotos() else {
            return nil
        }
        
        if(venuePhotos.count == 0) {
            return nil
        }

    
        return venuePhotos[0];
    }
    
    func venuePhotos() -> [Photo]? {
        guard let groups = self.groups else {
            return nil
        }
        
        if groups.count == 0 {
            return nil
        }
    
        
        let venueGroups = groups.filter { (group) -> Bool in
            return group.name?.lowercased() == "venue photos"
        }
        
        if venueGroups.count == 0 {
            return nil
        }
        
        return venueGroups[0].items;
    }
}
