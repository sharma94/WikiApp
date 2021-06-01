//
//  Wiki.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import Foundation

struct WikiStruct: Codable {

    var query: QueryStruct?
    var warnings: Warnings?
    var batchcomplete: Bool? = true
    var continueObj: ContinueStruct?
    
    enum CodingKeys: String, CodingKey {
        case query, warnings, batchcomplete
        case continueObj = "continue"
    }
}

struct Warnings: Codable {
    var main: Main?
}

struct Main: Codable {
    var warnings: String?
}

struct ContinueStruct : Codable {
    var gpsoffset: Int?
    var continueObj: String?
    
    enum CodingKeys: String, CodingKey {
        case gpsoffset
        case continueObj = "continue"
    }
}

struct QueryStruct: Codable {

    var redirects: [NormalizedStruct]?
   // var pages: [String:PageStruct]?
    var pages: [PageStruct]?
}

struct NormalizedStruct: Codable {
    var index: Int?
    var from: String?
    var to: String?
}

struct PageStruct: Codable {

    var pageid: Int?
    var ns: Int?
    var title: String?
    var index: Int?
    var contentmodel: String?
    var pagelanguage: String?
    var pagelanguagehtmlcode: String?
    var pagelanguagedir: String?
    var touched: Date?
    var lastrevid: Int?
    var length: Int?
    var fullurl: String?
    var editurl: String?
    var canonicalurl: String?
    
//    var thumbnail: ThumbStruct?
//    var pageimage: String?

}

struct ThumbStruct: Codable {

    var source: String?//this is what I want
    var width: Int?
    var height: Int?

}
