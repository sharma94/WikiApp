//
//  WikipediaArticleCache.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation


class WikipediaArticleCache {
    
    let cache = NSCache<AnyObject,WikipediaArticle>()
    
    func add(_ article: WikipediaArticle) {
        let cacheKey = self.cacheKey(title: article.title)
        self.cache.setObject(article, forKey: cacheKey)
    }
    
    func get(title: String) -> WikipediaArticle? {
        let cacheKey = self.cacheKey(title: title)
        let cachedSearchResult = self.cache.object(forKey: cacheKey)
        return cachedSearchResult
    }
    
    func cacheKey(title: String) -> AnyObject {
        let cacheKey = "en/\(title)"
        return cacheKey as AnyObject
    }
}
