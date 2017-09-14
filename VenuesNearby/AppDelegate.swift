//
//  AppDelegate.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Prevents the status bar hiding when rotating to landscape
        application.setStatusBarHidden(true, with: .none)
        application.setStatusBarHidden(false, with: .none)
        
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL else {
                return false
        }
        
        if url.pathComponents.count == 2 {
            return self.handleSearchURLActivity(url: url)
        }
        
        if url.pathComponents.count == 3 {
            return self.handleVenuesURLActivity(url: url)
        }
        
        return false
    }
    
    func handleSearchURLActivity(url: URL) -> Bool {
        if url.pathComponents[1].lowercased() != "search" {
            return false
        }
        
        if let nav = self.window?.rootViewController as? UINavigationController {
            if nav.topViewController is VenueViewController {
                nav.popViewController(animated: false)
            }
            
            if let viewController = nav.topViewController as? ViewController {
                
                let components = NSURLComponents.init(url: url, resolvingAgainstBaseURL: true)
                if let queryItems = components?.queryItems {
                    let terms = queryItems.filter({ (item) -> Bool in
                        return item.name == "term"
                    })
                    
                    if terms.count > 0, let searchTerm = terms[0].value {
                        viewController.searchForVenues(withSearchTerm: searchTerm)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func handleVenuesURLActivity(url: URL) -> Bool {
        if url.pathComponents[1].lowercased() != "venue" {
            return false
        }
        
        if let nav = self.window?.rootViewController as? UINavigationController {
            if nav.topViewController is VenueViewController {
                nav.popViewController(animated: false)
            }
            
            if let viewController = nav.topViewController as? ViewController {
                
                viewController.displayVenue(withId: url.lastPathComponent)
                return true
            }
        }
        
        return false
    }
}

