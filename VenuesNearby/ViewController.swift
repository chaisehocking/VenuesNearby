//
//  ViewController.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import UIKit
import AFNetworking

struct VenuesNearbyColours {
    static let green = UIColor(red: 68.0/255.0, green: 169.0/255.0, blue: 60.0/255.0, alpha: 1)
    static let red = UIColor(red: 223.0/255.0, green: 44.0/255.0, blue: 71.0/255.0, alpha: 1)
}

/**
 * ViewController is responsible for controling the single view of the Let's Go Exploing App.
 * It controls a table and responds to callbacks via a delegate of the SearchController.
 * It also has creates a LocationController and responds to user current location updates for venue searches for current location.
 */
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchControllerDelegate, LocationControllerDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var findNearMeButton: UIButton!
    
    //searchController is used to manage how the app searches
    let searchController = SearchController.init(withFourSquareService: FourSquareService())
    
    //The Controller that tracks the user's location
    private let locationController = LocationController()
    
    //This flag is used so we don't keep on attempting to search at the bottom of scrolling
    private var reachedEndOfResults = false
    
    //items is the data that we are representing in the tablView.
    var items: [Item]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.searchController.delegate = self
        self.locationController.delegate = self
    }
    
    override func viewDidLoad() {
        self.searchBar.delegate = self.searchController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    //MARK: Actions
    @IBAction func findNearMeButtonPressed(sender:UIButton) {
        self.searchBar.resignFirstResponder()
        self.searchController.performNewCurrentLocationSearch(self.locationController.location)
    }
    
    @IBAction func gestureRecogniserDidTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.searchBar.resignFirstResponder()
        }
    }
    
    // MARK: UITableViewDataSource methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let safeVenues = self.items else {
            return 0
        }
        
        return safeVenues.count
    }
    
    /**
     * Simply dequeues a VeneuCell from the tableview, and populates it with data from self.items.
     * If data is empty for cell, this method doesn't clear the data in the dequeued cell,
     * as this is handled in the prepareForReuse() and awakeFromNib() methods of the VenueCell
     * @param see UITableViewDataSource
     * @return VenueCell, the venueCell populated with data to be display at the given indexPath
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath) as! VenueCell
        let item = self.items![indexPath.row]
        
        if let safeVenue = item.venue {
            var likes = ""
            var tip: Tip?
            
            if let safeTips = item.tips {
                if safeTips.count > 0 {
                    tip = safeTips[0]
                    if let safeLikes = tip?.likes, let safeCount = safeLikes.count {
                        likes = "  👍 \(safeCount)"
                    }
                }
            }
            
            if let safeName = safeVenue.name {
                let label = "\(safeName) \(likes)"
                let attributedString = NSMutableAttributedString(string: label)
                let likesLength = NSString.init(string: likes).length
                attributedString.addAttributes([NSForegroundColorAttributeName : UIColor.black,
                                                NSFontAttributeName: UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightThin)],
                                               range: NSMakeRange(attributedString.length - likesLength, likesLength))
                cell.name.attributedText = attributedString
            }
            
            if let safeLocation = safeVenue.location {
                cell.address.text = safeLocation.disaplyFormattedAddress()
            }
            
            if let safeHours = safeVenue.hours {
                if let safeStatus = safeHours.status, let safeIsOpen = safeHours.isOpen {
                    cell.hours.text = safeStatus
                    if safeIsOpen == true {
                        cell.hours.textColor = VenuesNearbyColours.green
                    } else {
                        cell.hours.textColor = VenuesNearbyColours.red
                    }
                }
            }
            
            if let safePhoto = safeVenue.photos?.firstVenuePhoto(), safePhoto.isPublic() == true, let safePhotoURL = safePhoto.thumbnailURL() {
                cell.photoView.setImageWith(safePhotoURL)
            }
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate methods
    /**
     * When the user taps a cell with a Venue a check is performed to see if the Venue has a URL.
     * If so, they are shown an alert and taken to Safari to view the url if they accepted to leave the app.
     * @param see UITableViewDelegate
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ManualShowVenue" {
            if let venue = sender as? Venue {
                let venueViewController = segue.destination as! VenueViewController
                venueViewController.venue = venue
            }
        }
        
        if segue.identifier == "TableCellShowVenue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            
            if let row = indexPath?.row, let venue = self.items?[row].venue {
                let venueViewController = segue.destination as! VenueViewController
                venueViewController.venue = venue
            }
        }
        
    }
    /**
     * This method is used to track when the user hits the bottom of the screen.
     * When this happens we fire off a new page request to the searchController
     * @param see UIScrollViewDelegate
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.reachedEndOfResults == true {
            return
        }
        
        if self.searchController.searching {
            return
        }
        
        guard let safeItems = self.items else {
            return
        }
        
        let lastIndexPath = IndexPath(row: safeItems.count - 1, section: 0)
        let indexPaths = self.tableView.indexPathsForVisibleRows
        
        if indexPaths?.last?.compare(lastIndexPath) == .orderedSame {
            self.searchController.pageForwardCurrentSearch(searchBar, currentItems: safeItems)
        }
    }
    
    // MARK: LocationControllerDelegate methods
    /**
     * Informs the deleagte that find near me should now be available
     */
    func locationControllerUpdatedLocation() {
        self.findNearMeButton.alpha = 1.0
        self.findNearMeButton.isUserInteractionEnabled = true
    }
    
    // MARK: SearchControllerDelegate methods
    func searchControllerDidGetVenue(venue: Venue){
        self.performSegue(withIdentifier: "ManualShowVenue", sender: venue)
    }
    
    /**
     * This delegate callback method is used to hide the tableView as it now has no results
     */
    func searchControllerStartingNewTextSearch() {
        self.items = nil
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0.0
        }
        self.tableView.reloadData()
    }
    
    /**
     * This delegate callback method is used to hide the tableView as it now has no results
     */
    func searchControllerDidClearSearch() {
        self.items = nil
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0.0
        }
        self.tableView.reloadData()
    }
    
    /**
     * This delegate callback method is used to reveal the tableView as it now has results
     * @param see SearchControllerDelegate
     */
    func searchControllerDidYieldResults(_ items: [Item]) {
        self.reachedEndOfResults = false
        self.items = items
        UIView.animate(withDuration: 0.2) { 
            self.tableView.alpha = 1.0
        }
        self.tableView.reloadData()
    }
    
    /**
     * This delegate callback method is used to set the reachedEndOfResults to true,
     * to prevent further attempts at searches that are known to return no results
     * @param see SearchControllerDelegate
     */
    func searchControllerReachResultsLimit() {
        self.reachedEndOfResults = true
    }
    
    func searchControllerReturnedNoResults() {
        self.displayErrorAlert()
    }
    
    func searchControllerErrorOccurred() {
        self.displayErrorAlert()
    }
    
    // MARK: Private Methods
    /**
     * This method is used to display a generic error alert to the user
     */
    func displayErrorAlert() {
        let alertViewController = UIAlertController.init(title: "No Results Found", message: nil, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    /**
     * Given a name and a url,
     * This method displays an alert asking the user if they are ok to leave the app to visit the website of the Venue with the name that has been passed in.
     * Upon hitting 'Leave' the user will be launched out into Safari to the url that was passed.
     * @param name, the Venue's name to display on the alert
     * @param url, the url of the Venue to launch to if the user hit 'Leave'
     */
    func displayLeaveAppAlert(possesiveName: String, url: URL) {
        let alertViewController = UIAlertController.init(title: "Leave App?", message: "Are your sure your want to leave to visit \(possesiveName) website.", preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Leave", style: .default, handler: { (action) in
            UIApplication.shared.openURL(url)
        })
        
        alertViewController.addAction(leaveAction)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func displayVenue(withId venueId: String) {
        self.searchController.fetchVenueById(venueId)
    }
    
    func searchForVenues(withSearchTerm term: String) {
        self.searchBar.text = term
        self.searchBar.delegate?.searchBarSearchButtonClicked?(self.searchBar)
    }
}

