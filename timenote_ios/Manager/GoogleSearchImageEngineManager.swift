//
//  GoogleSearchImageEngineManager.swift
//  Timenote
//
//  Created by Aziz Essid on 8/16/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import os.log

/* Extension to add GoogleSearchImageEngineManager LOG console */

extension OSLog {
    // Unique cycle for this class
    static let GoogleSearchImageEngineManagerCycle = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "GoogleSearchImageEngineManager")
}

/* This struct define the Google API Search parameters in the request */

struct GoogleAPISearchParameter     : Codable {
    // Google API Search Engine Key
    var key         = GoogleSearchImageEngineManager.GoogleSearchAPIKEY
    // Google API Search Engine APP ID
    var cx          = GoogleSearchImageEngineManager.GoogleSearchAPID
    // Search Type
    var searchType  = GoogleSearchImageEngineManager.GoogleSearchType
    // ImageSize
    //let imgSize     = GoogleSearchImageEngineManager.GoogleSearchImageSize
    // Index of search paging
    let start       : Int
    // Text Searched by the API
    var q           : String
}

/* This struct is the response of the google search API */

// It is important to note that not all variables of the API response has been define
// Only those who could be usable to Dayzee has been written

struct GoogleAPISearchResponse      : Codable {
    let kind                : String
    let queries             : GoogleAPISearchQueries
    let context             : GoogleAPISearchContext
    let searchInformation   : GoogleAPISearchInformation
    let items               : [GoogleAPISearchItem]
}

struct GoogleAPISearchQueries       : Codable {
    let request             : [GoogleAPISearchRequest]
    let nextPage            : [GoogleAPISearchRequest]
}

struct GoogleAPISearchRequest       : Codable {
    let title               : String
    let searchTerms         : String
    let count               : Int
    let startIndex          : Int
}

struct GoogleAPISearchContext       : Codable {
    let title               : String
}

struct GoogleAPISearchInformation   : Codable {
    let searchTime          : Double
    let totalResults        : String
}

struct GoogleAPISearchItem          : Codable, Hashable {
    let title               : String
    var link                : String
    let mime                : String?
    let fileFormat          : String?
    var image               : GoogleAPISearchItemImageDetail
}

struct GoogleAPISearchItemImageDetail     : Codable, Hashable {
    let thumbnailHeight     : Int?
    let thumbnailWidth      : Int?
    let thumbnailLink       : String?
    var thumbnailImage      : Data?
}

struct GoogleAPISearchItemsResult   {
    let items               : [GoogleAPISearchItem]
    let nextPage            : GoogleAPISearchRequest?
}

/* This class has beeen designed to make google search images */

class GoogleSearchImageEngineManager {
    
    // Singleton to globalise class scope
    static let shared   : GoogleSearchImageEngineManager    = GoogleSearchImageEngineManager()
    
    // All google api config
    static let GoogleSearchAPIKEY                       = "AIzaSyBhM9HQo1fzDlwkIVqobfmrRmEMCWTU1CA"
    static let GoogleSearchAPID                         = "018194552039993531144:aj_el4m5plw"
    static let GoogleSearchType                         = "image"
    
    // This func call the WebService class to make a request to the Google Search Engine API retriving the images resulting of the text given as parameter
    func searchImageWithText(text: String?, paginationIndex: Int, completion: @escaping(Result<GoogleAPISearchItemsResult, WebServiceError>) -> Void) {
        guard let text = text else { return }
        WebService.shared.getGoogleImages(by: text, paginationIndex: paginationIndex) { googleResponse in
            switch googleResponse {
            case .failure(let errorMessage):
                os_log("Error while retriving google images for searched text : %{PRIVATE}@", log : OSLog.GoogleSearchImageEngineManagerCycle, type : .error, errorMessage.rawValue)
                return completion(.failure(errorMessage))
            case .success(let googleResults):
                os_log("Successfully searched text in %{PRIVATE}@ sec", log : OSLog.GoogleSearchImageEngineManagerCycle, type: .debug, "\(googleResults.searchInformation.searchTime)")
                return completion(.success(GoogleAPISearchItemsResult(items: googleResults.items.filter({URL(string: $0.image.thumbnailLink!) != nil}), nextPage: googleResults.queries.nextPage.first)))
            }
        }
    }
    
}
