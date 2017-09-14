//
//  FourSquareService.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 25/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import Foundation
import AFNetworking
import CoreLocation

struct FourSquareAPIContstanst {
    static let fourSquareClientID = "QC4BPZAVQDAO1IFP1VWLPNEIQOHWFYL4C2ZELGCYGL55DTWF"
    static let fourSquareClientSecret = "VFRVIU03QYPNYG3AGXQEVJQFZZBBMIXFR0ZIFZJIQLC4D0QH"
    static let fourSquareAPIVersion = "20170701"
    static let fourSquareURLScheme = "https"
    static let fourSquareURLHost = "api.foursquare.com"
    static let fourSquareExploreURLPath = "/v2/venues/explore"
    static let fourSquareVenueURLPath = "/v2/venues"
    static let fourSquareVenuePageSize = 30
}

/**
 * FourSquareService is responsible for makking the http request operation to the foursquare api.
 * Taking the response, and transforming it into Model objects understandable by the app.
 * It then returns these objects in callbacks.
 */
class FourSquareService: NSObject {
    
    /**
     * Search for venues in the foursqaure api using a location name search term.
     * @param searchTerm, the location name to search for
     * @param offset, how many results into the search to offset the results by
     * @param success, the callback to call upon a successful search
     * @param failure, the callback to call upon failed search
     */
    func searchForVenues(searchTerm: String, offset: Int, success: @escaping ([Group]?) -> Void, failure: @escaping () -> Void) {
        let nearQuery = URLQueryItem(name: "near", value: searchTerm)
        self.performVenueSearch(additionalQueryParameters: [nearQuery], offset: offset, success: success, failure: failure)
    }
    
    /**
     * Search for venues in the foursqaure api using a location.
     * @param location, latitude and longitude of the search
     * @param offset, how many results into the search to offset the results by
     * @param success, the callback to call upon a successful search
     * @param failure, the callback to call upon failed search
     */
    func searchForVenues(location:CLLocationCoordinate2D, offset: Int, success: @escaping ([Group]?) -> Void, failure: @escaping () -> Void) {
        let locationQuery = URLQueryItem(name: "ll", value: "\(location.latitude),\(location.longitude)")
        self.performVenueSearch(additionalQueryParameters: [locationQuery], offset: offset, success: success, failure: failure)
    }
    
    
    func fetchVenue(withId venueId:String, success: @escaping (Venue) -> Void, failure: @escaping () -> Void) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        let venueURL = self.fourSquareApiURL(withPath: FourSquareAPIContstanst.fourSquareVenueURLPath,
                                               otherQueryParamters: nil)?.appendingPathComponent(venueId)
        
        if let urlString = venueURL?.absoluteString {
            manager.get(urlString,
                        parameters: nil,
                        progress: nil,
                        success: { (task: URLSessionDataTask?, response: Any?) in
                            let httpResponse = HTTPResponse.init(withJsonDictionary: response as? [String : Any])
                            if let venue = httpResponse.response?.venue {
                                success(venue)
                            } else {
                                failure()
                            }
                            
            },
                        failure: { (task: URLSessionDataTask?, error: Error) in
                            failure()
            })
        }
        else {
            failure()
        }
    }
    
    /**
     * This method generates the FourSqaure api url based on the FourSquareAPIContstanst.
     * It then appends query parameters passed in, and alson add offset and limit parameters.
     * Using AFNetworking it generates a get request and uses the success and failure blocks.
     * In here it creates the HTTPResponse object, and by passing it the response JSON the whole Model object heirarchy inside the JSON is created.
     * As the caller of this method is not interested in the response object, just the Groups array is returned in the callbeack.
     * @param location, latitude and longitude of the search
     * @param additionalQueryParameters, query paramertes like 'near' and 'll'
     * @param offset, how many results into the search to offset the results by
     * @param success, the callback to call upon a successful search
     * @param failure, the callback to call upon failed search
     */
    private func performVenueSearch(additionalQueryParameters:[URLQueryItem]?, offset: Int, success: @escaping ([Group]?) -> Void, failure: @escaping () -> Void) {
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        
        let offsetQuery = URLQueryItem(name: "offset", value: "\(offset)")
        let limitQuery = URLQueryItem(name: "limit", value: "\(FourSquareAPIContstanst.fourSquareVenuePageSize)")
        let photosQuery = URLQueryItem(name: "venuePhotos", value: "1")
        var parameters = [offsetQuery, limitQuery, photosQuery]
        if let safeAdditionalQueryParameters = additionalQueryParameters {
            parameters.append(contentsOf: safeAdditionalQueryParameters)
        }
        
        let exploreURL = self.fourSquareApiURL(withPath: FourSquareAPIContstanst.fourSquareExploreURLPath,
                                               otherQueryParamters: parameters)
        if let urlString = exploreURL?.absoluteString {
            manager.get(urlString,
                        parameters: nil,
                        progress: nil,
                        success: { (task: URLSessionDataTask?, response: Any?) in
                            let httpResponse = HTTPResponse.init(withJsonDictionary: response as? [String : Any])
                            success(httpResponse.response?.groups)
            },
                        failure: { (task: URLSessionDataTask?, error: Error) in
                            failure()
            })
        }
        else {
            failure()
        }
    }
    
    /**
     * Creates a URL using NSURLComponents with a given path for the FourSquare api based on the FourSquareAPIContstanst
     * Extra query parameters can be passed into this method and they will be added to the url.
     * @param withPath, the path in the api to create the url for
     * @param otherQueryParamters, query parameters to add to the end of the url
     */
    private func fourSquareApiURL(withPath path: String, otherQueryParamters:[URLQueryItem]?) -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = FourSquareAPIContstanst.fourSquareURLScheme;
        urlComponents.host = FourSquareAPIContstanst.fourSquareURLHost;
        urlComponents.path = path;
        
        let clientIDQuery = URLQueryItem(name: "client_id", value: FourSquareAPIContstanst.fourSquareClientID)
        let clientSecretQuery = URLQueryItem(name: "client_secret", value: FourSquareAPIContstanst.fourSquareClientSecret)
        let apiVersionQuery = URLQueryItem(name: "v", value: FourSquareAPIContstanst.fourSquareAPIVersion)
        urlComponents.queryItems = [clientIDQuery, clientSecretQuery, apiVersionQuery]
        if let safeOtherQueryParamters = otherQueryParamters {
            urlComponents.queryItems?.append(contentsOf: safeOtherQueryParamters)
        }
        
        return urlComponents.url
    }
}
