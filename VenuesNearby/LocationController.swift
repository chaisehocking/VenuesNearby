//
//  LocationController.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation
import CoreLocation

/**
 * This Protocol is used to inform it's delegate that a location has been found for the user.
 */
protocol LocationControllerDelegate {
    /**
     * Tells the delegate each time a new location is found.
     * The location is not passed back, as that can be accessed via the location property of the LocationController
     */
    func locationControllerUpdatedLocation()
}

/**
 * LocationController is responsible for communicating with CoreLocation, and reporting back to the app via it's delegate.
 * It starts the location update process and tracks the reported location updates in a public property.
 */
class LocationController: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var delegate: LocationControllerDelegate?
    var location: CLLocationCoordinate2D!
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    /**
     * This method is used to save the loaction users location from CoreLocation to the location property,
     * then inform the delegate that a location has been found.
     * @param see CLLocationManagerDelegate
     */
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let safeLocation = manager.location {
            self.location = safeLocation.coordinate
            self.delegate?.locationControllerUpdatedLocation()
        }
    }

}
