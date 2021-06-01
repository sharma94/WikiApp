//
//  WikipediaImage.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation

class WikipediaImage {
   
    let id: String
    let url: URL
    let originalURL: URL
    let descriptionURL: URL
    let description: String
    let license: String
    
    static let allowedImageMimeTypes = [
        "image/jpeg",
        "image/png",
        "image/gif"
    ]
    
    init(id: String, url: URL, originalURL: URL, descriptionURL: URL, description: String, license: String) {
        self.id = id
        self.url = url
        self.originalURL = originalURL
        self.descriptionURL = descriptionURL
        self.description = description
        self.license = license
    }
}

extension WikipediaImage {
    
    convenience init?(jsonDictionary dict: JSONDictionary) {
        guard let imageInfoWrapper = dict["imageinfo"] as? [JSONDictionary]
            else { return nil }

        guard let imageInfo = imageInfoWrapper.first else {
                return nil
        }

        let url: URL

        guard let originalURLString = imageInfo["url"] as? String,
              let originalURL = URL(string: originalURLString) else {
                return nil
        }

        let mime: String?
        if let thumbURLString = imageInfo["thumburl"] as? String,
           let thumbURL = URL(string: thumbURLString) {
            url = thumbURL
            mime = imageInfo["thumbmime"] as? String
        } else {
            url = originalURL
            mime = imageInfo["mime"] as? String
        }

        guard let thumbMime = mime, WikipediaImage.allowedImageMimeTypes.contains(thumbMime) else {
            return nil
        }

        guard let descriptionURLString = imageInfo["descriptionurl"] as? String,
            let descriptionURL = URL(string: descriptionURLString) else {
                return nil
        }


        let id = dict["title"] as? String ?? ""
        
        var description = ""
        var license = ""

        if let meta = imageInfo["extmetadata"] as? JSONDictionary {
            
            if let descriptionWrapper = meta["ImageDescription"] as? JSONDictionary,
                let descriptionValue = descriptionWrapper["value"] as? String {
                description = descriptionValue
            }
            
            if let licenseWrapper = meta["LicenseShortName"] as? JSONDictionary,
                let licenseValue = licenseWrapper["value"] as? String {
                license = licenseValue
            }
        }
        
        self.init(id: id, url: url, originalURL: originalURL, descriptionURL: descriptionURL, description: description, license: license)
    }
}

