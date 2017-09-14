//
//  VenueTests.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 31/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble
@testable import VenuesNearby

class VenueTests: QuickSpec {
    override func spec() {
        
        describe("The possesive name logic of the Venue extension") {
            var venue: Venue!
            
            beforeEach {
                venue = Venue()
            }
            
            it("Should return nil if the name property is nil") {
                venue.name = nil
                expect(venue.possesiveName()).to(beNil())
            }
            
            it("Should end in an apostrophe if the name already ends in an 's'") {
                venue.name = "Gardens"
                expect(venue.possesiveName()).to(equal("Gardens'"))
            }
            
            it("Should add an apostrophe then an 's' if the name doesn't already end in an 's'") {
                venue.name = "JB Hi Fi"
                expect(venue.possesiveName()).to(equal("JB Hi Fi's"))
            }
        }
    }
}
