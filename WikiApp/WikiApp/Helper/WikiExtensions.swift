//
//  WikiExtensions.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import Foundation

extension String {
    
    public func wikipediaURLEncodedString(replaceSpacesWithUnderscores: Bool = true, encodeSlashes: Bool = false) -> String {
        var string = self
        
        if replaceSpacesWithUnderscores {
            string = string.replacingOccurrences(of: " ", with: "_")
        }
        
        var characterSet = NSMutableCharacterSet.urlQueryAllowed
        
        var delimitersToEncode = "#[]@!$?&'()*+="

        if encodeSlashes {
            delimitersToEncode.append("/")
        }

        characterSet.remove(charactersIn: delimitersToEncode)
        
        return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet) ?? string
    }

}

extension URL {
    
    public func extractWikipediaArticleParameters() -> (title: String, languageCode: String?, fragment: String) {
        var articleTitle = self.path.replacingOccurrences(of: "/wiki/", with: "").replacingOccurrences(of: "_", with: " ")
        let articleLanguage = self.host?.components(separatedBy: ".").first
        let fragment = self.fragment ?? ""
        // Remove hash from title:
        if !fragment.isEmpty {
            articleTitle = articleTitle.replacingOccurrences(of: "#\(fragment)", with: "")
        }
        return (articleTitle, articleLanguage, fragment)
    }
    
    public func isWikipediaArticleURL() -> Bool {
        let pattern = "^(https?://)?(www\\.)?([^.].*\\.wikipedia.org)?/wiki/.+$"
        
        let absoluteURLString = self.absoluteString
        if let _ = absoluteURLString.range(of: pattern, options: .regularExpression) {
            return true
        }
        return false
    }
        
    public func isWikipediaImageURL() -> Bool {
        // This list includes SVG and PDF because currently the Wikipedia API
        // will always return a flattened bitmap (PNG or JPG)
        // when requesting these types.
        let supportedImageFileExtensions = ["tiff", "tif", "jpg", "jpeg", "gif", "bmp", "bmpf", "ico", "cur", "xbm", "png", "svg", "pdf"]
        var imageExtension = self.pathExtension
        if imageExtension.isEmpty {
            // For the rare case where the path extension is not recognized by Foundation, like this one:
            // https://en.wikipedia.org/wiki/Megalodon#/media/File:Giant_white_shark_coprolite_(Miocene;_coastal_waters_of_South_Carolina,_USA).jpg
            // TODO: Use a regex to clean this up and to allow a 3 or 4 character suffix.
            let suffix = String(self.absoluteString.suffix(4))
            if suffix.prefix(1) == "." {
                imageExtension = String(suffix.suffix(3))
            }
        }
        return supportedImageFileExtensions.contains(imageExtension.lowercased())
    }
    
    public func isWikipediaMediaURL() -> Bool {
        let supportedMediaFileExtensions = ["ogg", "ogv", "oga", "flac", "webm"]
        let imageExtension = self.pathExtension
        return supportedMediaFileExtensions.contains(imageExtension.lowercased())
    }
    
    public func isWikipediaScrollURL() -> Bool {
        let isHostWikipedia = self.host != nil ? self.host!.range(of: ".wikipedia.org") != nil : false
        let pathPointsToSiteRoot = self.path != "" ? self.path == "/" : false
        let hasFragment = self.fragment != nil ? (self.fragment!).count > 0 : false
        return isHostWikipedia && pathPointsToSiteRoot && hasFragment
    }
    
}
