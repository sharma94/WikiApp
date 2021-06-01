//
//  WikipediaArticlePreview.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation
import UIKit

class WikipediaArticlePreview: Hashable, Equatable {
    static func == (lhs: WikipediaArticlePreview, rhs: WikipediaArticlePreview) -> Bool {
        return lhs.title == rhs.title
    }
    
    
    public var title: String
    public lazy var displayTitle: String = {
        // TODO: Find out if we can get the display title from the Search API
        //       (it’s possible with the Article API)
        let t = (Wikipedia.sharedFormattingDelegate?.format(context: .articleTitle,
                                                                       rawText: self.title,
                                                                       title: self.title,
                                                                       isHTML: true)) ?? self.title
        return t
    }()
    
    // The article excerpt
    public var rawText: String
    public var displayText: String
    
    // A short meta description provided by the API
     var description = ""
    
     var imageURL: URL?
     var imageDimensions: CGSize?
    
     lazy var url: URL? = {
        let escapedTitle = self.title.wikipediaURLEncodedString()
        let urlString = "https://en.wikipedia.org/wiki/" + escapedTitle
        let url = URL(string: urlString)
        return url
    }()
    
    // This index is used for sorting search results
    // The API delivers the results in a random order, but with indices
    var index = 0
    
    var coordinate: (latitude: Double, longitude: Double)?
    
    // Distance in meters from search coordinate in NearbySearch results
    var initialDistance: Double?
    
 //   static let disambiguationLocalizations = [
//        // TODO: Add more translations for “disambiguation”
//        // Must be lowercase
//        "de" : "begriffsklärung",
//        "en" : "disambiguation",
//        "es" : "desambiguación",
//        "fr" : "homonymie",
//        "it" : "disambigua",
//        "nl" : "doorverwijspagina",
//        "pl" : "ujednoznacznienie",
//        "sv" : "olika betydelser",
//    ]
    
//    lazy var isDisambiguation: Bool = {
//        // This is the most reliable way to find out whether we’re dealing with a disambiguation page
//        if let localizedDisambiguation = WikipediaArticlePreview.disambiguationLocalizations[self.language.code],
//            self.description.lowercased().range(of: localizedDisambiguation) != nil {
//            return true
//        }
//        return false
//    }()
    
    init(title: String, text: String) {
        self.title = title
        self.rawText = text

        self.displayText = Wikipedia.sharedFormattingDelegate?.format(context: .articlePreview, rawText: text, title: title, isHTML: true) ?? text
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title.hashValue)
    }
    
}

extension WikipediaArticlePreview {
    
    convenience init?(jsonDictionary dict: JSONDictionary) {

        var title = ""

        if let titlesDict = dict["titles"] as? JSONDictionary,
            let normalized = titlesDict["normalized"] as? String {
            title = normalized
        } else if let t = dict["title"] as? String {
            title = t
        }

        if title.isEmpty {
            return nil
        }

        let text = dict["extract"] as? String ?? ""
        
        self.init(title: title, text: text)


        var description = ""

        if let d = dict["description"] as? String,
              !d.isEmpty {
            description = d
        } else if let terms = dict["terms"] as? JSONDictionary,
           let descriptions = terms["description"] as? [String] {
            description = descriptions.first ?? ""
        }

        if !description.isEmpty {
            self.description = (Wikipedia.sharedFormattingDelegate?.format(context: .articleDescription,
                                                                           rawText: description,
                                                                           title: title,
                                                                           isHTML: true)) ?? description
        }

        if let thumbnail = dict["thumbnail"] as? JSONDictionary,
           let source = thumbnail["source"] as? String {
           
            self.imageURL = URL(string: source)
            
            if let width = thumbnail["width"] as? Int,
               let height = thumbnail["height"] as? Int {
                self.imageDimensions = CGSize(width: CGFloat(width), height: CGFloat(height))
            }
        }
        
        if let coordinatesWrapper = dict["coordinates"] as? [JSONDictionary],
           let coordinates = coordinatesWrapper.first,
           let latitude = coordinates["lat"] as? Double,
           let longitude = coordinates["lon"] as? Double,
           let initialDistance = coordinates["dist"] as? Double {
           
            self.coordinate = (latitude: latitude, longitude: longitude)
            self.initialDistance = initialDistance
        }
        
        if let index = dict["index"] as? Int {
            self.index = index
        }
    }
}
