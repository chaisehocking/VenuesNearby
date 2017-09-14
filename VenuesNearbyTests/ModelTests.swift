//
//  ModelTests.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble
@testable import VenuesNearby

class ModelTests: QuickSpec {
    override func spec() {
        
        describe("Testing Initialisers") {
            context("New Designated initialiser") {
                it("should not call setValuesForKeys() when nil is provided") {
                    let model = MockModel.init(withJsonDictionary: nil)
                    expect(model.setValuesForKeysCalled).to(beFalse())
                }
                
                it("should call setValuesForKeys() when an object of type Dictionary is provided") {
                    let model = MockModel.init(withJsonDictionary: [String : Any]())
                    expect(model.setValuesForKeysCalled).to(beTrue())
                }
            }
            
            context("NSObject designated initialiser") {
                it("should not call setValuesForKeys() when calling the overriden initialiser") {
                    let model = MockModel()
                    expect(model.setValuesForKeysCalled).to(beFalse())
                }
            }
        }
        
        describe("Test setValueForKey()") {
            var model: MockObjectPropertyModel!
            var jsonObject: [String : Any]!
            beforeEach {
                model = MockObjectPropertyModel()
                jsonObject = [String : Any]()
            }
            
            it("Should not modify model, nor throw exception, if unknown key") {
                model.setValue(jsonObject, forKey: "unknown")
                expect(model.property).to(beNil())
            }
            
            context("Array keys") {
                it("Should not automatically create Model object, nor thrown exception if key unknown") {
                    model.setValue(jsonObject, forKey: "unknonwn")
                    expect(model.arrayProperty).to(beNil())
                    expect(model.arrayProperty2).to(beNil())
                }
                
                it("Should not create Model objects for array key when class is not returned by subclass for key") {
                    let array = [jsonObject]
                    model.setValue(array, forKey: "arrayProperty2")
                    expect(model.arrayProperty2 != nil).to(beTrue())
                    expect(type(of: model.arrayProperty2!) == Model.self).to(beFalse())
                }
            
                it("Should create Model objects for array key when class is returned by subclass for key") {
                    let array = [jsonObject]
                    model.setValue(array, forKey: "arrayProperty")
                    expect(model.arrayProperty).toNot(beNil())
                    expect(type(of: model.arrayProperty!) == [Model].self).to(beTrue())
                }
            }
            
            context("Dictionary keys") {
                it("Should not automatically create a Model object, nor thrown exception if key is unknonw") {
                    model.setValue(jsonObject, forKey: "unknown")
                    expect(model.property).to(beNil())
                    expect(model.property2).to(beNil())
                }
                
                it("Should not automatically create a Model object from the json dictionary if key is not for a Model Class") {
                    model.setValue(jsonObject, forKey: "property2")
                    expect(model.property2).toNot(beNil())
                    expect(model.property2).to(equal(jsonObject as NSObject))
                }
                
                it("Should automatically create a Model object from the json dictionary if property is a known Model") {
                    model.setValue(jsonObject, forKey: "property")
                    expect(model.property).toNot(beNil())
                    expect(type(of: model.property!) == Model.self).to(beTrue())
                }
            }
        }
    }
}

class ResponseTests: QuickSpec {
    override func spec() {
        
        describe("Testing the implementation of array classes for json parsing") {
            it("Should return a Group type for the groups array") {
                let response = Response()
                expect(response.typeForArrayKey("groups") == Group.self).to(beTrue())
            }
        }
    }
}

class GroupTests: QuickSpec {
    override func spec() {
        
        describe("Testing the implementation of array classes for json parsing") {
            it("Should return a Item type for the items array") {
                let response = Group()
                expect(response.typeForArrayKey("items") == Item.self).to(beTrue())
            }
        }
    }
}

class MockModel: Model {
    var setValuesForKeysCalled = false
    override func setValuesForKeys(_ keyedValues: [String : Any]) {
        self.setValuesForKeysCalled = true
        super.setValuesForKeys(keyedValues)
    }
}

class MockObjectPropertyModel: Model {
    var property: Model?
    var property2: NSObject?
    
    var arrayProperty: [Model]?
    var arrayProperty2: [NSObject]?
    
    override func typeForArrayKey(_ key:String) -> Model.Type? {
        if key == "arrayProperty" {
            return Model.self
        }
        
        return super.typeForArrayKey(key)
    }
}
