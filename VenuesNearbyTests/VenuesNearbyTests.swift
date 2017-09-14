//
//  VenuesNearbyTests.swift
//  VenuesNearbyTests
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble

@testable import VenuesNearby

class VenuesNearbyTests: QuickSpec {
    override func spec() {
        
        describe("Prove the tests are working") {
            it("should have correct values in array") {
                let variable = [1, 2]
                expect(variable).to(haveCount(2))
                expect(variable[0]).to(equal(1))
                expect(variable[1]).to(equal(2))
            }
        }
    }
}
