//
//  SearchController.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * This Protocol is used to provide updates to a delegate about events occuring in the SearchController.
 * Namely evenst regaring to starting a search and it's results.
 */
protocol SearchControllerDelegate {
    /**
     * This methods is called on the delegate every time a new text search or location search is about to be fired.
     * It is not called for new page searches
     */
    func searchControllerStartingNewTextSearch()
    
    /**
     * This methods is called on the delegate whenever the user hits the clear button in the search bar,
     * or when the user back spaces to no characters in the search bar
     */
    func searchControllerDidClearSearch()
    
    /**
     * This methods is called on the delegate a search on the API find results containing Items.
     * If not Items are found in the results or, the search errors, this method will not be called.
     * @param items, the Items found by the search
     */
    func searchControllerDidYieldResults(_ items: [Item])
    
    /**
     * This methods is called on the delegate when a new page search is fired, but no Items are founds in the response.
     * It is used to indicate to the delegate the end of results for that search has been reached.
     */
    func searchControllerReachResultsLimit()
    
    /**
     * This methods is called on the delegate when a new search returns successfully but no items are found in th results.
     * It is not called if the same happens on next page searches (see searchControllerReachResultsLimit())
     */
    func searchControllerReturnedNoResults()
    
    /**
     * This methods is called on the delegate when a new search or next page search fail for any reason.
     */
    func searchControllerErrorOccurred()
    
    func searchControllerDidGetVenue(venue: Venue);
}

/**
 * SearchController is responsible for bridging the FourSquarApi and what is needed for the UI of the app.
 * It takes a FourSquareService via dependecy injection, or if using the convenience initialiser init(), one will be create automatically.
 * To use the SearchController their is a delegate property that the controller reports back its events through.
 * It adopts the UISearchBarDelegate can be wired up directly to a search bar so searches can be triggered directly from that.
 */
class SearchController: NSObject, UISearchBarDelegate {
    //A deleagte where all the events of the controller are reported through
    var delegate: SearchControllerDelegate?
    
    //Used to stop search being rapid fired to the FourSquareService
    var searching = false
    
    //The Api providing the results
    private var fourSquareService: FourSquareService!
    
    //Used so when a next page search is triggered, the next page is for the same locaction
    private var currentSearchingLocation: CLLocationCoordinate2D?
    
    /**
     * The required initialiser for this controller.
     * Takes the FourSquareService via dependecy injection.
     * Sets the delegate of the locationControler to self.
     * @param withFourSquareService, The API service that will provide the search results
     */
    required init(withFourSquareService fourSquareService:FourSquareService) {
        super.init()
        self.fourSquareService = fourSquareService
    }
    
    /**
     * Convenience initialiser, overriding the designated initialiser of the superclass.
     * Creates a FourSquareService.
     */
    override convenience init() {
        self.init(withFourSquareService: FourSquareService())
    }
    
    // Mark UISearchBarDelegate
    /**
     * If the search bar has text will fire a new page search to the FourSquareService.
     * Informs the delegate of the new search, and of the result.
     * @param see UISearchBarDelegate
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.characters.count == 0 {
            return
        }
        searchBar.resignFirstResponder()
        
        self.currentSearchingLocation = nil
        self.delegate?.searchControllerStartingNewTextSearch()
        self.searching = true
        self.fourSquareService.searchForVenues(searchTerm: searchBar.text!,
                                               offset: 0,
                                               success: self.successBlockForVenuesAPISearch(),
                                               failure: self.failureBlockForVenuesAPISearch())
    }
    
    /**
     * If the change is to no text,
     * informs the deleagte that the searchbar has been cleared so it can update the UI if required
     * @param see UISearchBarDelegate
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.delegate?.searchControllerDidClearSearch()
        }
    }
    
    /**
     * When the user is searching current location and enters the text bar
     * This method informs the delegate that the search has been cleared so it can update the UI.
     * This is so the current location results are not in the way of a new search.
     * @param see UISearchBarDelegate
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if self.currentSearchingLocation != nil && searchBar.text == "" {
            self.delegate?.searchControllerDidClearSearch()
        }
    }
    
    // MARK: Public Methods
    /**
     * Save the searched location from location parameter for use in next page searches.
     * Then fires off a new venues search to the FourSquareService.
     * @param location the current location to search for venues in
     */
    public func performNewCurrentLocationSearch(_ location: CLLocationCoordinate2D) {
        if self.searching {
            return
        }
        
        self.searching = true
        self.currentSearchingLocation = location
        self.fourSquareService.searchForVenues(location: location,
                                               offset: 0,
                                               success: self.successBlockForVenuesAPISearch(),
                                               failure: self.failureBlockForVenuesAPISearch())
    }
    
    /**
     * If the current location is saved then the next page will use the user's location, as that is the current search.
     * Otherwise it will fire of a next page search using the searchBar text.
     * Upon completion, the new items will be found in the Groups and appended to the current itmes before being returned as the results in the deleagte method searchControllerDidYield().
     * @param searchBar, the searchBar that contains the user's search text
     * @param currentItems, the current displayed items
     */
    public func pageForwardCurrentSearch(_ searchBar: UISearchBar, currentItems: [Item]) {
        if self.searching {
            return
        }
        
        let completion = { (groups: [Group]?) in
            if let newItems = self.allItems(fromGroups: groups) {
                
                self.searching = false
                if newItems.count == 0 {
                    self.delegate?.searchControllerReachResultsLimit()
                } else {
                    var combinedItems = currentItems as [Item]
                    combinedItems.append(contentsOf: newItems)
                    self.delegate?.searchControllerDidYieldResults(combinedItems)
                }
            }
        }
        
        let failure = { () in
            self.searching = false
            self.delegate?.searchControllerErrorOccurred()
        }
        
        self.searching = true
        //If we are currently searching the users location, continue doing that
        if let safeCurrentSearchingLocation = currentSearchingLocation {
            self.fourSquareService.searchForVenues(location: safeCurrentSearchingLocation,
                                                   offset: currentItems.count,
                                                   success: completion,
                                                   failure: failure)
        
        }
        //If the user is currently searching text, continue doing that
        else if let safeText = searchBar.text, safeText.characters.count > 0 {
            self.fourSquareService.searchForVenues(searchTerm: searchBar.text!,
                                                   offset: currentItems.count,
                                                   success: completion,
                                                   failure: failure)
        }
    }
    
    public func fetchVenueById(_ id: String) {
        self.fourSquareService.fetchVenue(withId: id,
                                          success: { (venue) in
                                            self.delegate?.searchControllerDidGetVenue(venue: venue)
        },
                                          failure: {
            
        })
    }
    
    // MARK: Private Methods
    /**
     * The common succes completion block for the two FourSquare API searches: new searchTerm and new location.
     * Upon succes all items will be found in the returned Groups, and returned in the deleagte method searchControllerDidYield().
     * If no Items are found the delegate method searchControllerReturnedNoResults() will be called.
     * @return ([Group]?) -> Void, the success completion block
     */
    private func successBlockForVenuesAPISearch() -> ([Group]?) -> Void {
        return { (groups: [Group]?) in
            self.searching = false
            if let newVenues = self.allItems(fromGroups: groups), newVenues.count > 0 {
                self.delegate?.searchControllerDidYieldResults(newVenues)
            } else {
                self.delegate?.searchControllerReturnedNoResults()
            }
        }
    }
    
    /**
     * The common failure completion block for the two FourSquare API searches: new searchTerm and new location.
     * Upon failure all the deleagte method searchControllerErrorOccurred().
     * @return () -> Void, the failure completion block
     */
    private func failureBlockForVenuesAPISearch() -> () -> Void {
        return {
            self.searching = false
            self.delegate?.searchControllerErrorOccurred()
        }
    }
    
    /**
     * This method finds all items within an array of given groups and returns them in a single array.
     * If the groups given are nil, then nil will be returned
     * @param groups, the groups to find the items in
     * @return [Item]?, the array of items, or nil
     */
    private func allItems(fromGroups groups:[Group]?) -> [Item]? {
        guard let safeGroups = groups else {
            return nil
        }
        
        var items = [Item]()
        for group in safeGroups {
            guard let safeItems = group.items else {
                continue
            }
            
            for item in safeItems {
                items.append(item)
            }
        }
        
        return items
    }
}
