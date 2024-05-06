//
//  GoogleLocationManager.swift
//  Timenote
//
//  Created by Aziz Essid on 8/3/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps
import os.log

// BEFORE USING CLASS
//   pod 'GoogleMaps'
//   pod 'GooglePlaces'
// HELP : https://developers.google.com/places/ios-sdk/start
// To use the Google Location Manager class you must add theses keys to your info.plist
// The values of each key is a description of your needs of use as string.
// Open the info.plist as source code and add the code below
/*
<key>NSLocationWhenInUseUsageDescription</key>
<string>Show your location on the map</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Nous utilisons votre localisation pour vous faciliter la navigation. </string>
 */

// Add to the app Delegate did finish lunching with option
/*

 GMSPlacesClient.provideAPIKey("API_KEY")
 GMSServices.provideAPIKey("API_KEY")
 */

// FAST EXEMPLE OF USE
/*
 GoogleLocationManager.shared.getLocationWithUpdate { (place, error) in
    self.userLocalisation = place
    self.locationTextField.text = place?.formattedAddress ?? ""
 }
 
 GoogleLocationManager.shared.presentGoogleAutoComplete(self)
 */

// The enum class below is defined to get all the different values of the GMSPlace addressComponents

enum GoogleAdresseComponent {
    case street_number;
    case route;
    case neighborhood;
    case locality;
    case country;
    case postal_code;
    case administrative_area;
    
    func toString() -> String {
        switch self {
        case GoogleAdresseComponent.street_number:
            return "street_number"
        case GoogleAdresseComponent.route:
            return "route"
        case GoogleAdresseComponent.neighborhood:
            return "neighborhood"
        case GoogleAdresseComponent.locality:
            return "locality"
        case GoogleAdresseComponent.country:
            return "country"
        case GoogleAdresseComponent.postal_code:
            return "postal_code"
        case GoogleAdresseComponent.administrative_area:
            return "administrative_area"
        }
    }
}

// Alias type to enhance code comprehension
typealias GoogleLocationManagerResult = ((_ userLocation : GMSPlace?, _ adresse : GMSAddress? , _ error : Error?) -> Void)

// Google Location Manager class definition
class GoogleLocationManager : NSObject {
    
    // Shared
    static let shared = GoogleLocationManager()
    
    // User DefaultKey to get the last user location
    private var lastUserLocationPlace       : GMSPlace?     = nil
    private let lastUserLocationKey         : String        = ConfigUtil.lastUserLocationKey
    private var lastUserLocationAddress     : GMSAddress?   = nil
    
    // User defaultKey to get the last save place
    private var savedUserLocationPlace      : GMSPlace?     = nil
    private let savedUserLocationKey        : String        = ConfigUtil.savedUserLocationKey
    private var savedUserLocationAdresse    : GMSAddress?   = nil

    // iOS location to request location authorizations
    private let locationManager     : CLLocationManager = CLLocationManager()
    private var isCheckingLocation  : Bool              = false
    
    // Google variables for auto-complete view controller
    private let autoCompleteController  : GMSAutocompleteViewController             = GMSAutocompleteViewController()
    private var autoCompletePlace       : GMSPlace?                                 = nil
    private var autoCompleteDelegate    : GMSAutocompleteViewControllerDelegate?    = nil
    private var autoCompleteFilter      : GMSAutocompleteFilter                     = GMSAutocompleteFilter()
    
    // Google autocomplete easy filter setter
    var autoCompleteOnlyStreets : Bool = false {
        didSet(newValue) {
            self.autoCompleteFilter.type = self.autoCompleteOnlyStreets ? .address : .noFilter
        }
    }
    
    // Google autocomplete easy filter setter
    var autoCompleteOnlyRegion : Bool = false {
        didSet(newValue) {
            self.autoCompleteFilter.type = self.autoCompleteOnlyRegion ? .region : .noFilter
        }
    }
    
    // Google autocomplete easy filter setter
    var autoCompletionOnlyFrance : Bool = false {
        didSet(newValue) {
            self.autoCompleteFilter.country = self.autoCompletionOnlyFrance ? "FR" : nil
        }
    }
    
    // Google variables to get the user location
    private var likelyPlaces            : [GMSPlace]       = []
    private var placesClient            : GMSPlacesClient! = GMSPlacesClient.shared()
    private var currentPlace            : GMSPlace?        = nil
    private var currentPlaceAddress     : GMSAddress?      = nil
    private var geocoder                : GMSGeocoder      = GMSGeocoder()

    
    // Completion handler variables
    private var completion : GoogleLocationManagerResult?
    //typealias ((_ userLocation : GMSPlace?, _ adresse : GMSAddress? , _ error : Error?) -> Void) = GoogleLocationManagerResult

    // Error
    private var error : Error?

    override init() {
        super.init()
        // Add delegate to get update of status authorisation
        self.locationManager.delegate = self
        // Retrive last selected place
        self.getLastSelectedPlace(nil)
        // Set the delegate of the Google autoComplete to this class
        self.autoCompleteController.delegate = self
        self.autoCompleteController.modalPresentationStyle = .overCurrentContext
        self.autoCompleteController.autocompleteFilter = self.autoCompleteFilter
    }
    
    // Main function to get the user current location it is called all along the class
    private func getUserLocation() {
        
        // Request authorisation from user to get his location
        self.locationManager.requestWhenInUseAuthorization()
        
        guard isLocationAllowed() else { return }
        
        self.likelyPlaces.removeAll()
        
        // Call to google places to get a list of places that can be user locations
        self.placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            
            // Handle the error.
            if let error = error {
                self.callCompletion(nil, nil, error)
                os_log("Current Place error: %{PUBLIC}@", log: OSLog.googleLocationManagerCycle ,type: .error, error.localizedDescription)
                return
            }
            
            // Save the mostLikelyUserPlace in the class
            guard let mostLikelyUserPlace = placeLikelihoods?.likelihoods.first?.place else {
                os_log("Cannot find the user location", log: OSLog.googleLocationManagerCycle ,type: .error)
                self.callCompletion(nil, nil, nil)
                return
            }
            
            self.currentPlace = mostLikelyUserPlace
            self.saveNewSelectedPlace(mostLikelyUserPlace)
            os_log("Saved new selected place %{PRIVATE}@", log : OSLog.googleLocationManagerCycle, type : .debug, mostLikelyUserPlace.name ?? "No name")
            
            // Call private function to handle completion
            self.geocoder.reverseGeocodeCoordinate(mostLikelyUserPlace.coordinate) { (response, error) in
                self.currentPlaceAddress = self.lastUserLocationAddress
                self.callCompletion(mostLikelyUserPlace, self.lastUserLocationAddress, nil)
            }
            
            
            // Get likely places and add to the list.
            // TODO
            // Not always needed you can remove that if you don't use it on your project
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        })
    }
    
    // Save the new selected place
    private func saveNewSelectedPlace(_ userLocation : GMSPlace?) {
        guard let userLocation = userLocation else { return }
        self.lastUserLocationPlace = userLocation
        self.geocoder.reverseGeocodeCoordinate(userLocation.coordinate) { (response, error) in
            self.lastUserLocationAddress = response?.results()?.first
            self.currentPlaceAddress = self.lastUserLocationAddress
        }
        UserDefaults.standard.set(userLocation.placeID, forKey: self.lastUserLocationKey)
    }
    
    private func saveNewSelectedPlace(_ userLocation : GMSPlace?, _ userAdresse : GMSAddress?) {
        guard let userLocation = userLocation else { return }
        self.lastUserLocationPlace = userLocation
        self.lastUserLocationAddress = userAdresse
        UserDefaults.standard.set(userLocation.placeID, forKey: self.lastUserLocationKey)
    }
    
    // Save the new selected place
    func saveNewPlace(_ savedLocation : GMSPlace?) {
        guard let savedLocation = savedLocation else { return }
        self.savedUserLocationPlace = savedLocation
        self.geocoder.reverseGeocodeCoordinate(savedLocation.coordinate) { (response, error) in
            self.savedUserLocationAdresse = response?.results()?.first
        }
        UserDefaults.standard.set(savedLocation.placeID, forKey: self.savedUserLocationKey)
    }
    
    func saveNewPlace(_ savedLocation : GMSPlace?, _ savedAdresse : GMSAddress?) {
        guard let savedLocation = savedLocation else { return }
        self.savedUserLocationPlace = savedLocation
        self.savedUserLocationAdresse = savedAdresse
        UserDefaults.standard.set(savedLocation.placeID, forKey: self.savedUserLocationKey)
    }
    
    // Call the completion if it's needed
    private func callCompletion(_ userLocation : GMSPlace?, _ userAdresse : GMSAddress?, _ error : Error?) {
        self.error = error
        guard let completion = self.completion else { return }
        completion(userLocation, userAdresse, error)
        self.completion = nil
    }
    
    // Return the error if need to be called after gettin a nil user location
    // Error is always printed
    func getError() -> Error? {
        return self.error
    }
    
    // Return the last selected place by the google location manager
    // It can either be the last user location or the last selected place by google autocomplete
    // It is saved in the UserDefault to retreive it on the app lunching for exemple
    func getLastSelectedPlace( _ completion : GoogleLocationManagerResult?) {
        guard self.lastUserLocationPlace == nil else {
            completion?(self.lastUserLocationPlace, self.lastUserLocationAddress, nil)
            return
        }
        guard let placeId = UserDefaults.standard.string(forKey: self.lastUserLocationKey) else {
            completion?(nil, nil, nil)
            return
        }
        self.getPlaceFromGoogleId(placeId) { (place, error) in
            self.lastUserLocationPlace = place
            guard let place = place else {
                completion?(nil, nil, error)
                return
            }
            self.geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
                self.lastUserLocationAddress = response?.results()?.first
                completion?(place, self.lastUserLocationAddress, error)
            }
        }
    }
    
    // Return the last saved place by the google location manager
    // It is saved in the UserDefault to retreive it on the app lunching for exemple
    func getLastSavedPlace( _ completion : GoogleLocationManagerResult?) {
        guard self.savedUserLocationPlace == nil else {
            completion?(self.savedUserLocationPlace, self.savedUserLocationAdresse, nil)
            return
        }
        guard let placeId = UserDefaults.standard.string(forKey: self.savedUserLocationKey) else {
            completion?(nil, nil, nil)
            return
        }
        self.getPlaceFromGoogleId(placeId) { (place, error) in
            self.savedUserLocationPlace = place
            guard let place = place else {
                completion?(nil, nil, error)
                return
            }
            self.geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
                self.savedUserLocationAdresse = response?.results()?.first
                completion?(place, self.savedUserLocationAdresse, error)
            }
        }
    }
    
    
    // Return the last updated location it is always instantiated
    // The only result it can be nil is that there was an error or the request of location had not the time to be completed
    func getLocation() -> GMSPlace? {
        if (self.error != nil) {
           return nil
        }
        return self.currentPlace
    }
    
    // TODO
    // If you dont need it in your project you can remove this function
    // Get the list of the likely user location place
    func getLikelyUserLocations() -> [GMSPlace]? {
        if (self.error != nil) {
            return nil
        }
        return self.likelyPlaces
    }

    // Function that call the completion with the current user location with a refresh
    func getLocationWithUpdate(_ completion : @escaping (_ userLocation : GMSPlace?, _ userAdresse : GMSAddress?, _ error : Error?) -> Void) {
        self.completion = completion
        self.getUserLocation()
    }
    
    private func configureAutoCompleteStyle() {
        if #available(iOS 13.0, *) {
            let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: isDarkMode ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
            UINavigationBar.appearance().tintColor = .systemGray3
            UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleColor(isDarkMode ? .lightGray : .blue, for: .normal)
            UISearchBar.appearance().tintColor = .systemGray5
            self.autoCompleteController.modalPresentationStyle = .overCurrentContext
            self.autoCompleteController.primaryTextHighlightColor = isDarkMode ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.autoCompleteController.primaryTextColor = .lightGray
            self.autoCompleteController.secondaryTextColor = .lightGray
            self.autoCompleteController.tableCellBackgroundColor = .systemGray6
        } else {
        }
    }
    
    // Function to present the auto complete google places view controller
    func presentGoogleAutoComplete(_ viewController : UIViewController) {
        guard let delegate = viewController as? GMSAutocompleteViewControllerDelegate else {
            os_log("Present of Google Auto Complete view controller did fail, you must add the exetension of GMSAutocompleteViewControllerDelegate in your class before presenting", log: OSLog.googleLocationManagerCycle, type: .error)
            return
        }
        self.autoCompleteDelegate = delegate
        self.configureAutoCompleteStyle()
        //if let viewControllerNavigationContoller = viewController.navigationController {
        //    viewControllerNavigationContoller.pushViewController(self.autoCompleteController, animated: true)
        //} else {
            viewController.present(self.autoCompleteController, animated: true, completion: nil)
        //}
    }
    
    func getUserTimenoteLocation(completion: @escaping(UserLocationDto?) -> Void){
        guard let currentPlace = self.currentPlace else { return completion(nil) }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(currentPlace.coordinate) { (response, error) in
            guard let response = response?.firstResult() else { return completion(nil) }
            completion(UserLocationDto(longitude: currentPlace.coordinate.longitude, latitude: currentPlace.coordinate.latitude, address: UserAddressDto(address: GoogleLocationManager.getFullAdresseOf(currentPlace) ?? "", zipCode: response.postalCode ?? "", city: response.locality ?? "", country: response.country ?? "")))
        }
    }
    
    func getTimenoteLocation(place: GMSPlace?, completion: @escaping(UserLocationDto?) -> Void){
        guard let currentPlace = place else { return completion(nil) }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(currentPlace.coordinate) { (response, error) in
            guard let response = response?.firstResult() else { return completion(nil) }
            completion(UserLocationDto(longitude: currentPlace.coordinate.longitude, latitude: currentPlace.coordinate.latitude, address: UserAddressDto(address: GoogleLocationManager.getFullAdresseOf(currentPlace) ?? "", zipCode: response.postalCode ?? "", city: response.locality ?? "", country: response.country ?? "")))
        }
    }
    
    func resetAutoCompleteFilter() {
        self.autoCompleteController.autocompleteFilter = nil
    }
    
    // Function to allow Google auto complete filter
    // It must be called before presenting the auto complete view controller
    func setAutoCompleteFilters(_ filter : GMSAutocompleteFilter) {
        self.autoCompleteController.autocompleteFilter = filter
    }
    
    // This function allow you get a place from its ID
    func getPlaceFromGoogleId(_ placeId : String, _ completion : @escaping GMSPlaceResultCallback) {
        self.placesClient.lookUpPlaceID(placeId, callback: completion)
    }
    
    // The function bellow are single line function they are here mostly to remember easely how to get information from GMSPlace
    
    static func getFullAdresseOf(_ place : GMSPlace?) -> String? {
        return place?.formattedAddress
    }
    
    static func getNameOf(_ place : GMSPlace?) -> String? {
        return place?.name
    }
    
    static func getCoordinateOf(_ place : GMSPlace?) -> CLLocationCoordinate2D? {
        return place?.coordinate
    }
    
    static func getPhoneNumberOf(_ place : GMSPlace?) -> String? {
        return place?.phoneNumber
    }
    
    static func getIdOf(_ place : GMSPlace?) -> String? {
        return place?.placeID
    }
    
    static func getWebSiteOf(_ place : GMSPlace?) -> URL? {
        return place?.website
    }
    
    static func getRatingOf(_ place : GMSPlace?) -> Float? {
        return place?.rating
    }
    
    static func getPriceLevelOf(_ place : GMSPlace?) -> GMSPlacesPriceLevel? {
        return place?.priceLevel
    }
    
    static func getCityOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.locality.toString()) != nil })?.name
    }
    
    static func getStreetNumberOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.street_number.toString()) != nil })?.name
    }
    
    static func getRouteOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.route.toString()) != nil })?.name
    }
    
    static func getNeighborhoodOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.neighborhood.toString()) != nil })?.name
    }
    
    static func getCountryOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.country.toString()) != nil })?.name
    }
    
    static func getPostalCodeOf(_ place : GMSPlace?) -> String? {
        return place?.addressComponents?.first(where: { $0.types.firstIndex(of: GoogleAdresseComponent.postal_code.toString()) != nil })?.name
    }
    
    // Deprecated use getAdresseOf instead
    static func getPostalCodeOf(_ place : GMSPlace?, completion : @escaping (_ codePostale : String?) -> ()) {
        guard let place = place else { return completion(nil) }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            completion(response?.results()?.first?.postalCode)
        }
    }
    
    static func getAdresseOf(_ place : GMSPlace?, completion : @escaping (_ placeAdresse : GMSAddress?) -> ()) {
        guard let place = place else { return }
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(place.coordinate) { (response, error) in
            completion(response?.results()?.first)
        }
    }
    
    static func getAdministrativeAreoOf(_ place : GMSPlace?) -> [String]? {
        var administrative_area_level : [String] = []
        
        guard let adressComponents = place?.addressComponents else { return nil }
        for adress in adressComponents {
            if (adress.types.contains(where: { $0.contains((GoogleAdresseComponent.administrative_area.toString())) })) {
                administrative_area_level.append(adress.name)
            }
        }
        return administrative_area_level
    }
    
    static func reverseGeocodeLocation(location: CLLocationCoordinate2D, completion : @escaping (_ placeAdresse : GMSAddress?) -> ()) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { (response, error) in
            completion(response?.results()?.first)
        }
    }
}

extension GoogleLocationManager : GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        os_log("New selected place %{PRIVATE}@", log : OSLog.googleLocationManagerCycle, type : .debug, place.name ?? "No name")
        //self.saveNewSelectedPlace(place)
        self.autoCompleteDelegate?.viewController(viewController, didAutocompleteWith: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.autoCompleteDelegate?.viewController(viewController, didFailAutocompleteWithError: error)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.autoCompleteDelegate?.wasCancelled(viewController)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        self.autoCompleteDelegate?.didRequestAutocompletePredictions?(viewController)
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        self.autoCompleteDelegate?.didUpdateAutocompletePredictions?(viewController)
    }
}

extension GoogleLocationManager : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .notDetermined) {
            self.isCheckingLocation = true
            return
        }
        guard self.isCheckingLocation else { return }
        self.isCheckingLocation = false
        if isLocationAllowed() {
            self.getUserLocation()
        } else {
            self.callCompletion(nil, nil, nil)
        }
    }
}

// Function returning if the location service are allowed
fileprivate func isLocationAllowed() -> Bool {
    let currentStatus = CLLocationManager.authorizationStatus()
    return currentStatus != .denied && currentStatus != .notDetermined && currentStatus != .restricted
}

