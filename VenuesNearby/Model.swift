//
//  Model.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 26/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation

/**
 * This Class is used for objects that are represented by JSON.
 * Subclasses that extend from this class need only to create properties with the same names as the json properties and the values will be mapped to them automatically.
 * If a property in your model is of another type that extends from Model, then the instance of the property will be cretead of the correct Type when the JSON is mapped.
 * This class rids you of the need to map all json values out of a dictionary to your properties.
 */
class Model: NSObject {
    
    /**
     * The designated initialiser.
     * @param dictionary, Provide the Model with the JSON dictionary to map the keys and values
     */
    required init(withJsonDictionary dictionary:[String : Any]?) {
        super.init()
        guard let dict = dictionary else {
            return
        }
        self.setValuesForKeys(dict)
    }
    
    override required convenience init() {
        self.init(withJsonDictionary: nil)
    }
    
    /**
     * This method is overridden and super is not called to avoid an exception when their are json keys that a Model doesn't care about
     * @param, see superclass
     */
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        //do nothing
    }
    
    /**
     * This method takes raw json and creates Model objects if a matching property for the key is in the Model.
     * The Model object is then passed on to super for the key instead.
     * If a matching key is not in the Model, or the key is not for an Object of Type Model, then the value is just passed on to super without modyfing the value in/out
     * @param, see superclass
     */
    override func setValue(_ value: Any?, forKey key: String) {
        if self.responds(to: Selector(key)) {
        
            let dictionary = value as? [String : Any]
            if let safeDictionary = dictionary {
                let theClass = self.getPropertyType(key)
                let object = self.objectOfType(theClass, fromDictionary: safeDictionary)
                if let safeObject = object {
                    super.setValue(safeObject, forKey: key)
                    return
                }
            }
            else {
                let array = value as? [[String : Any]]
                if let safeArray = array {
                    let theClass = self.typeForArrayKey(key)
                    let objects = self.arrayOfObjectOfType(theClass, fromArray: safeArray)
                    if let safeObjects = objects {
                        super.setValue(safeObjects, forKey: key)
                        return
                    }
                }
            }
        }
        
        super.setValue(value, forKey: key)
    }
    
    /**
     * This method is for describing what class an Array properties in a Model is.
     * This is purely for subclasses to override.
     * @param key, The key of the Array property to find the Class of
     * @return The type of Model that is in the Array. These can then be created from the json and put in the array
     */
    func typeForArrayKey(_ key:String) -> Model.Type? {
        return nil
    }
    
    /**
     * This method works out the Type of a Model's property.
     * It uses the runtime environment to get the description of a property, and examines that to find the class.
     * @param key, The key of the property to examine on the Model
     * @return the type of Model class (subclass) the property is
     */
    private func getPropertyType(_ key: String) -> Model.Type? {
        let propertyPtr = class_getProperty(type(of: self), UnsafePointer(key))
        let propertyAttributes = property_getAttributes(propertyPtr)
        guard let safePropertyAttributes = propertyAttributes else {
            return nil
        }
        
        let propertyString = String(utf8String: safePropertyAttributes)
        guard let safePropertyString = propertyString else {
            return nil
        }
        
        let classRange = safePropertyString.range(of: "T@\"")
        guard let safeClassRange = classRange else {
            return nil
        }
        
        let start = safePropertyString.index(safePropertyString.startIndex, offsetBy: 3)
        let end = safePropertyString.endIndex
        
        if safePropertyString.distance(from: safePropertyString.startIndex, to: safeClassRange.lowerBound) == 0 {
            let classEndRange = safePropertyString.range(of: "\"",
                                                         options: .literal,
                                                         range: start..<end,
                                                         locale: nil)
            
            if let safeClassEndRange = classEndRange {
                let classString = safePropertyString.substring(with: start..<safeClassEndRange.lowerBound)
                let theClassType = NSClassFromString(classString) as? Model.Type
                return theClassType
            }
        }
        
        return nil;
    }
    
    /**
     * This method creates a new Objects of the given Model (subclass) Type.
     * It populates the Model's keys/properties with the given JSON dictionary
     * @param type, The Model Type of Object to create
     * @param fromDictionary, The JSON dictionary to prouplate the Model object's properties with
     * @return the newly created and populated Model object
     */
    private func objectOfType(_ type:Model.Type?, fromDictionary dictionary:[String : Any]) -> Model? {
        let object = type?.init(withJsonDictionary: dictionary)
        return object
    }
    
    /**
     * This method creates a new Array of Objects of the given Model (subclass) Type.
     * It populates each Model's keys/properties with a dictionary from the given array of JSON dictionaries
     * @param type, The Model Type of Objects to create
     * @param fromArray, The JSON dictionary array to prouplate each Model object's properties with
     * @return the newly created array of populated Model objects
     */
    private func arrayOfObjectOfType(_ type:Model.Type?, fromArray array:[[String : Any]]) -> [Model]? {
        if type == nil {
            return nil
        }
        
        var arrayModels = [Model]()
        for arrayObject in array {
            let object = self.objectOfType(type, fromDictionary: arrayObject)
            if let safeObject = object {
                arrayModels.append(safeObject)
            }
        }
        
        return arrayModels
    }
}
