//
//  PhotoTests.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 30/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble
@testable import VenuesNearby

class PhotoTests: QuickSpec {
    override func spec() {
        describe("The public logic of the photo extension") {
            var photo: Photo!
            beforeEach {
                photo = Photo()
            }
            
            it("Should consider a photo not public if it has nil visibility") {
                photo.visibility = nil
                expect(photo.isPublic()).to(beFalse())
            }
            
            it("Should consider a photo not public if it has a visibility that's not the exact string 'public'") {
                photo.visibility = "publics"
                expect(photo.isPublic()).to(beFalse())
            }
            
            it("Should consider a photo public if visibility of string 'public' ignoring case") {
                photo.visibility = "public"
                expect(photo.isPublic()).to(beTrue())
                
                photo.visibility = "pUbLiC"
                expect(photo.isPublic()).to(beTrue())
            }
        }
        
        describe("The thumbnail url creation") {
            var photo: Photo!
            beforeEach {
                photo = Photo()
            }
            
            it("Should not return a url if the prefix property is nil") {
                photo.prefix = nil
                photo.suffix = "/123.jpg"
                
                expect(photo.thumbnailURL()).to(beNil())
            }
            
            it("Should not return a url if the suffix property is nil") {
                photo.prefix = "https://domain.com/"
                photo.suffix = nil
                
                expect(photo.thumbnailURL()).to(beNil())
            }
            
            it("Should not return a url if prefix or suffix do not create a valid url") {
                photo.prefix = "bl^ah"
                photo.suffix = "/123.jpg"
                
                expect(photo.thumbnailURL()).to(beNil())
                
                photo.prefix = "https://domain.com/"
                photo.suffix = "/12^3.jpg"
                
                expect(photo.thumbnailURL()).to(beNil())
            }
            
            it("Should return a thumbnail url when prefix and suffix are valid url components to create a url") {
                photo.prefix = "https://domain.com/"
                photo.suffix = "/123.jpg"
                
                let url = photo.thumbnailURL()
                expect(url).toNot(beNil())
                expect(url?.absoluteString).to(equal("https://domain.com/cap100/123.jpg"))
            }
        }
    }
}
