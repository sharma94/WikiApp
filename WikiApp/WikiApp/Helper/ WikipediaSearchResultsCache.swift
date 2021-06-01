//
//   WikipediaSearchResultsCache.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation

class WikipediaSearchResultsCache {
    
    let cache = NSCache<AnyObject,WikipediaSearchResults>()
    
    func add(_ searchResults: WikipediaSearchResults) {
        let cacheKey = self.cacheKey(method: searchResults.searchMethod, term: searchResults.term)
        self.cache.setObject(searchResults, forKey: cacheKey as AnyObject)
    }
    
    func get(method: WikipediaSearchMethod, term: String) -> WikipediaSearchResults? {
        let cacheKey = self.cacheKey(method: method, term: term)
        let cachedSearchResult = self.cache.object(forKey: cacheKey as AnyObject)
        return cachedSearchResult
    }
    
    func cacheKey(method: WikipediaSearchMethod, term: String) -> String {
        let cacheKey = "\(method.rawValue)/en/\(term)"
        return cacheKey
    }
    
}
