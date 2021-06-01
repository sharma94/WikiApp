//
//  WikiHelper.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import Foundation

 enum WikipediaTextFormattingDelegateContext {
    case article
    case articleTitle
    case articleDescription
    case articlePreview
    case tableOfContentsItem
}

 enum WikipediaNamespace: Int {
    case media = -2
    case special = -1
    case main = 0
    case talk = 1
    case user = 2
    case userTalk = 3
    case project = 4
    case projectTalk = 5
    case file = 6
    case fileTalk = 7
    case mediaWiki = 8
    case mediaWikiTalk  = 9
    case template = 10
    case templateTalk = 11
    case help = 12
    case helpTalk = 13
    case category = 14
    case categoryTalk = 15
}

 enum WikipediaError: Error, Hashable, Equatable {
    case apiError(String)
    case cancelled
    case notFound
    case noInternetConnection
    case notEnoughResults
    case noResults
    case decodingError
    case badResponse
    case other(String?)
}

 enum WikipediaSearchMethod: String {
    case fullText = "fullText"
    case prefix = "prefix"
}

protocol WikipediaTextFormattingDelegate: AnyObject {
    
    // The article title and language are passed to make more informed decisions
    // on the formatting of rawText
    func format(context: WikipediaTextFormattingDelegateContext, rawText: String, title: String?, isHTML: Bool) -> String
}

protocol WikipediaNetworkingActivityDelegate: AnyObject {
    func start()
    func stop()
}
