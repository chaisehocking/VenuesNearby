//
//  Location+Formatted.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 27/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * This extension is responsible for giving display logic to the Location Model.
 */
extension Location {
    
    /**
     * Formats the Address into lines separated by new line characters.
     * @return String, The formatted address string, or an empty string when formattedAddress is nil
     */
    func disaplyFormattedAddress() -> String {
        guard let safeFormattedAddress = self.formattedAddress else {
            return ""
        }
        return safeFormattedAddress.joined(separator: "\n")
    }
}
