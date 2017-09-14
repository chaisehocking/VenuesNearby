//
//  Photo+Extension.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 30/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * This extension is responsible for giving thumbnail URLs to the Photo Model.
 */
extension Photo {
    
    /**
     * Determines whether the photo can be accessed by the public.
     * Uses the Model's visibility property, and check's whether it's set to 'public' ignoring case
     * @return Bool, whether the photo is public
     */
    func isPublic() -> Bool{
        guard let safeVisibility = self.visibility else {
            return false
        }
        return safeVisibility.lowercased() == "public"
    }
    
    /**
     * Creates a new thumbnail url for the photo.
     * The photo will capped at either 100px wide or 100px high, depending on which is bigger.
     * URL is composed from the Photo's prefix and suffix properties.
     * @return URL, The new thumbnail URL
     */
    func thumbnailURL() -> URL? {
        guard let safePrefix = self.prefix, let safeSuffix = self.suffix else {
            return nil
        }
        
        return URL.init(string: "\(safePrefix)cap100\(safeSuffix)")
    }
    
    func url() -> URL? {
        guard let safePrefix = self.prefix, let safeSuffix = self.suffix else {
            return nil
        }
        
        return URL.init(string: "\(safePrefix)300x300\(safeSuffix)")
    }
}
