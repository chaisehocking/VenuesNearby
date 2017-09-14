//
//  SearchControllerTests.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 29/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Quick
import Nimble
@testable import VenuesNearby

class SearchControllerTests: QuickSpec {
    override func spec() {
        
        describe("Search controller calling the four square service") {
            var fourSquareService: MockFourSquareService!
            var searchController: SearchController!
            var searchDelegate: MockSearchControllerDelegate!
            var searchBar: MockSearchBar!
            beforeEach {
                fourSquareService = MockFourSquareService()
                searchDelegate = MockSearchControllerDelegate()
                searchController = SearchController.init(withFourSquareService: fourSquareService)
                searchController.delegate = searchDelegate
                searchBar = MockSearchBar()
            }
            
            context("Hitting search button") {
                it("Should not call the service when the search button is clicked if there is no text in the search bar") {
                    searchBar.text = nil
                    searchController.searchBarSearchButtonClicked(searchBar)
                    expect(fourSquareService.venuesSearchCalled).to(beFalse())
                    expect(searchBar.resigned).to(beFalse())
                    expect(searchDelegate.startingSearch).to(beFalse())
                    expect(searchDelegate.searchResults).to(beNil())
                }
                
                it("Should call the service for a venues search when the search button is clicked on the keyboard") {
                    searchBar.text = "melbourne"
                    searchController.searchBarSearchButtonClicked(searchBar)
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchBar.resigned).to(beTrue())
                    expect(searchDelegate.startingSearch).to(beTrue())
                    expect(searchDelegate.searchResults).to(haveCount(2))
                }
            }
            
            context("Hitting clear button") {
                it("should alert the delegate that the text was cleared in the search bar so it can update the UI") {
                    searchBar.text = ""
                    searchController.searchBar(searchBar, textDidChange: "")
                    expect(searchDelegate.clearedSearch).to(beTrue())
                }
            }
            
            context("Page forward search") {
                it("Should not page forward if the text has been cleared in the search bar") {
                    searchBar.text = nil
                    searchController.pageForwardCurrentSearch(searchBar, currentItems: [Item()])
                    expect(fourSquareService.venuesSearchCalled).to(beFalse())
                    expect(searchBar.resigned).to(beFalse())
                    expect(searchDelegate.startingSearch).to(beFalse())
                    expect(searchDelegate.searchResults).to(beNil())
                }
                
                it("Should return a combined array to the delegate of the results from service, and initial venues") {
                    searchBar.text = "melbourne"
                    let item1 = Item()
                    let venue1 = Venue()
                    venue1.name = "venue 1"
                    item1.venue = venue1
                    
                    let item2 = Item()
                    let venue2 = Venue()
                    venue2.name = "venue 2"
                    item2.venue = venue2
                    
                    searchController.pageForwardCurrentSearch(searchBar, currentItems: [item1, item2])
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchDelegate.searchResults).to(haveCount(4))
                    expect(searchDelegate.searchResults![0].venue!.name).to(equal("venue 1"))
                    expect(searchDelegate.searchResults![1].venue!.name).to(equal("venue 2"))
                    expect(searchDelegate.searchResults![2].venue!.name).to(equal("venue 3"))
                    expect(searchDelegate.searchResults![3].venue!.name).to(equal("venue 4"))
                }
            }
            
            context("Callbacks on failures and no results") {
                it("Should call the delegate telling it that no results were returned") {
                    fourSquareService.forceNoResults = true
                    searchBar.text = "no results"
                    searchController.searchBarSearchButtonClicked(searchBar)
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchBar.resigned).to(beTrue())
                    expect(searchDelegate.startingSearch).to(beTrue())
                    expect(searchDelegate.returnedNoResults).to(beTrue())
                    expect(searchDelegate.searchResults).to(beNil())
                }
                
                it("Should not call the delegate telling it that no results were returned on next page searches, as these are invisible searches to the user") {
                    fourSquareService.forceNoResults = true
                    fourSquareService.forceFailure = true
                    searchBar.text = "melbourne"
                    searchController.pageForwardCurrentSearch(searchBar, currentItems: [])
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchDelegate.returnedNoResults).to(beFalse())
                    expect(searchDelegate.searchResults).to(beNil())
                }
                
                it("Should call the delegate telling it when a failure occurs on new searches") {
                    fourSquareService.forceFailure = true
                    searchBar.text = "melbourne"
                    searchController.searchBarSearchButtonClicked(searchBar)
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchBar.resigned).to(beTrue())
                    expect(searchDelegate.startingSearch).to(beTrue())
                    expect(searchDelegate.failureOccured).to(beTrue())
                    expect(searchDelegate.searchResults).to(beNil())
                }
                
                it("Should call the delegate telling it when a failure occurs on next page searches") {
                    fourSquareService.forceFailure = true
                    searchBar.text = "melbourne"
                    searchController.pageForwardCurrentSearch(searchBar, currentItems: [])
                    expect(fourSquareService.venuesSearchCalled).to(beTrue())
                    expect(searchDelegate.failureOccured).to(beTrue())
                }
            }
        }
    }
}



class MockFourSquareService: FourSquareService {
    var forceNoResults = false
    var forceFailure = false
    var venuesSearchCalled = false
    override func searchForVenues(searchTerm: String, offset: Int, success: @escaping ([Group]?) -> Void, failure: @escaping () -> Void) {
        self.venuesSearchCalled = true
        
        if self.forceFailure {
            failure()
            return
        }
        
        if forceNoResults == true {
            success([])
        } else {
            let group = self.venuesGroup(offset: offset)
            success([group])
        }
    }
    
    private func venuesGroup(offset: Int) -> Group {
        let group = Group()
        let item = Item()
        let item2 = Item()
        let venue = Venue()
        venue.name = "venue \(offset + 1)"
        let venue2 = Venue()
        venue2.name = "venue \(offset + 2)"
        item.venue = venue
        item2.venue = venue2
        group.items = [item, item2]
        
        return group
    }
}

class MockSearchBar: UISearchBar{
    var resigned = false
    override func resignFirstResponder() -> Bool {
        self.resigned = true
        return super.resignFirstResponder()
    }
}

class MockSearchControllerDelegate: SearchControllerDelegate {
    var startingSearch = false
    var clearedSearch = false
    var searchResults: [Item]?
    var returnedNoResults = false
    var failureOccured = false
    
    func searchControllerStartingNewTextSearch(){
        startingSearch = true
    }
    func searchControllerDidClearSearch(){
        clearedSearch = true
    }
    func searchControllerDidYieldResults(_ items: [Item]){
        searchResults = items
    }
    func searchControllerReachResultsLimit(){
        
    }
    func searchControllerReturnedNoResults(){
        self.returnedNoResults = true
    }
    func searchControllerErrorOccurred(){
        self.failureOccured = true
    }
    func searchControllerDidGetVenue(venue: Venue){
        
    }
}
