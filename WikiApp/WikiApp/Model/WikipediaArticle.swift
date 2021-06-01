//
//  WikipediaArticle.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation

struct WikipediaTOCItem {
    public let title: String
    public let anchor: String
    public let tocLevel: Int
    
    public init(title: String, anchor: String, tocLevel: Int) {
        self.title = title
        self.anchor = anchor
        self.tocLevel = tocLevel
    }
}

class WikipediaArticle {
    
   
    var title: String
    var displayTitle: String
    
    var rawText = ""
    lazy var displayText: String = {
        return Wikipedia.sharedFormattingDelegate?.format(context: .article, rawText: self.rawText, title: self.title, isHTML: true) ?? self.rawText
    }()
    
    var toc = [WikipediaTOCItem]()

    var coordinate: (latitude: Double, longitude: Double)?

    var imageURL: URL?
    var imageID: String?

    var wikidataID: String?

    var scrollToFragment: String?
    
    lazy var url: URL? = {
        let escapedTitle = self.title.wikipediaURLEncodedString()
        let urlString = "https://en.wikipedia.org/wiki/" + escapedTitle
        let url = URL(string: urlString)
        return url
    }()
    
    lazy var editURL: URL? = {
        let escapedTitle = self.title.wikipediaURLEncodedString()
        let editURLString = "https://en.m.wikipedia.org/w/index.php?action=edit&title=" + escapedTitle
        let editURL = URL(string: editURLString)
        return editURL
    }()
    
    init(title: String, displayTitle: String) {
        self.title = title.replacingOccurrences(of: "_", with: " ")
        
        
        var formattedTitle = displayTitle.replacingOccurrences(of: "_", with: " ")
        formattedTitle = (Wikipedia.sharedFormattingDelegate?.format(context: .articleTitle,
                                                                   rawText: formattedTitle,
                                                                   title: title,
                                                                   isHTML: true)) ?? formattedTitle
        self.displayTitle = formattedTitle
    }
    
    var areOtherLanguagesAvailable = false
    var languageCount = 0
   
}


extension WikipediaArticle {
    convenience init?(jsonDictionary dict: JSONDictionary, title: String, fragment: String? = nil, imageWidth: Int = 320) {
        
        guard let lead = dict["lead"] as? JSONDictionary,
              let leadSections = lead["sections"] as? [JSONDictionary],
              let leadFirstSection = leadSections.first,
              let leadText = leadFirstSection["text"] as? String
        else {
                return nil
        }

        var text = ""
        
        if let hatnotes = lead["hatnotes"] as? String {
            text += #"<div class="wikipediakit-hatnotes">"#
            text += hatnotes
            text += "</div>"
        }

        text += leadText

        var toc = [WikipediaTOCItem]()

        if let remaining = dict["remaining"] as? JSONDictionary,
           let remainingSections = remaining["sections"] as? [JSONDictionary] {

            for section in remainingSections {
                if let sectionText = section["text"] as? String {
                    // The first section (intro) does not have an anchor
                    if let sectionAnchor = section["anchor"] as? String {
                        var sectionTitle = (section["line"] as? String ?? "")
                        sectionTitle = (Wikipedia.sharedFormattingDelegate?.format(context: .tableOfContentsItem,
                                                                                   rawText: sectionTitle,
                                                                                   title: title,
                                                                                   isHTML: true)) ?? sectionTitle
                        let sectionTocLevel = section["toclevel"] as? Int ?? 1
                        toc.append(WikipediaTOCItem(title: sectionTitle, anchor: sectionAnchor, tocLevel: sectionTocLevel))

                        text += "<h\(sectionTocLevel) id=\"\(sectionAnchor)\">\(sectionTitle)</h\(sectionTocLevel)>"
                    }
                    text += sectionText
                }
            }
        }
        
        let title = lead["normalizedtitle"] as? String ?? title

        let rawDisplayTitle = (lead["displaytitle"] as? String) ?? title
        
        self.init(title: title, displayTitle: rawDisplayTitle)

        self.scrollToFragment = fragment
        self.rawText = text
        self.toc = toc

        if let imageProperties = lead["image"] as? JSONDictionary,
            let imageID = imageProperties["file"] as? String,
            let thumbs = imageProperties["urls"] as? JSONDictionary {

            self.imageID = imageID

            let availableWidths: [Int] = Array(thumbs.keys).compactMap { return Int($0) }.sorted()

            var bestSize = availableWidths.first ?? imageWidth
            for width in availableWidths {
                bestSize = width
                if width >= imageWidth {
                    continue
                }
            }

            if let imageURLString = thumbs["\(bestSize)"] as? String,
                let imageURL = URL(string: imageURLString) {
                self.imageURL = imageURL
            }
        }

        if let languageCount = lead["languagecount"] as? Int {
            self.languageCount = languageCount
        }
        self.areOtherLanguagesAvailable = languageCount > 0

        if let wikibaseItem = lead["wikibase_item"] as? String {
            self.wikidataID = wikibaseItem
        }

        if let geo = lead["geo"] as? JSONDictionary,
           let latitude = geo["latitude"] as? Double,
           let longitude = geo["longitude"] as? Double {
            self.coordinate = (latitude, longitude)
        }
    }
}
