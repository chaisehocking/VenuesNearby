//
//  VenueViewController.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 6/9/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import UIKit
import AFNetworking

class VenueViewController: UIViewController {
    
    @IBOutlet var venueTitle: UILabel!
    @IBOutlet var venueURL: UIButton!
    @IBOutlet var venueWebSite: UIWebView!
    
    var venue: Venue?
    
    override func viewDidLoad() {
        self.refreshView()
    }
    
    func refreshView(){
        guard let venue = self.venue else {
            return
        }
        self.venueTitle.text = venue.name
        self.venueURL.setTitle(venue.url, for: .normal)
        
        if let urlString = venue.url, let url = URL.init(string: urlString) {
            let request = URLRequest.init(url: url)
            self.venueWebSite.loadRequest(request)
        }
    }
}
