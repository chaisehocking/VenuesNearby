//
//  LocationTests.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble
@testable import VenuesNearby

class LocationTests: QuickSpec {
    override func spec() {
        
        describe("The display formatted address logic of the location extension") {
            var location: Location!
            
            beforeEach {
                location = Location()
            }
            
            it("Should return an empty string if the formattedAddress property is nil") {
                location.formattedAddress = nil
                expect(location.disaplyFormattedAddress()).to(equal(""))
            }
            
            it("Should return a single string with line breaks between each of the individual strings in the array of the formatted address property") {
                location.formattedAddress = ["1", "2"]
                expect(location.disaplyFormattedAddress()).to(equal("1\n2"))
            }
        }
    }
}
