//
//  WikiAPIClient.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import Foundation

typealias JSONDictionary = [String:AnyObject]

//https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&prop=info&inprop=url&wbptterms=description&gpssearch=Sachin+T&gpslimit=10

//https://en.wikipedia.org/w/api.php?ggscoord=0.0%7C0.0&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json

//https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages&piprop=thumbnail&pithumbsize=100&pilimit=10&prop=info&inprop=url&wbptterms=description&gpssearch=Sachin+T&gpslimit=10&generator=prefixsearch&inprop=url
 class Wikipedia {
    // Public initializer is required if we don’t use the shared singleton
 // public init() {}

     static let shared: Wikipedia = {
        return Wikipedia()
    }()
    
    static weak var sharedFormattingDelegate: WikipediaTextFormattingDelegate?
    
    let articleCache: WikipediaArticleCache = {
       return WikipediaArticleCache()
    }()

    let searchResultsCache: WikipediaSearchResultsCache = {
        return WikipediaSearchResultsCache()
    }()
    
    // This cache setting will be mirrored in the headers returned by Wikipedia’s servers
    // and thus respected by NSURLSession’s NSURLCache
    public var maxAgeInSeconds = 60 * 60 * 2 // 2 hours by default
    
    
    static var baseURL = URL(string:"https://en.wikipedia.org/w/api.php")
    var secondSearchRequest: URLSessionDataTask?
    var mostReadArticleDetailsRequest: URLSessionDataTask?
    
    static func stringFromQueryParameters(_ queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        
        for (name, value) in queryParameters {
            let escapedName = name.wikipediaURLEncodedString(replaceSpacesWithUnderscores: false)
            let escapedValue = value.wikipediaURLEncodedString(replaceSpacesWithUnderscores: false)
            let part = "\(escapedName)=\(escapedValue)"
            
            parts.append(part as String)
        }
        
        return parts.joined(separator: "&")
    }
    
    static func buildURL(_ URL : URL, queryParameters : Dictionary<String, String>) -> URL? {
        let URLString = "\(URL.absoluteString)?\(self.stringFromQueryParameters(queryParameters))"
        return Foundation.URL(string: URLString)
    }
    
    static func buildURLRequest(parameters: [String:String]) -> URLRequest? {
        guard let baseUrl = self.baseURL else { return nil }
        
        guard let url = Wikipedia.buildURL(baseUrl, queryParameters: parameters) else { return nil }
        let request = URLRequest(url: url)
        
        return request
    }
    
}

//MARK:- API
extension Wikipedia {
    
    func requestOptimizedSearchResults(term: String,
                                              existingSearchResults: WikipediaSearchResults? = nil,
                                              imageWidth: Int = 200,
                                              minCount: Int = 10,
                                              maxCount: Int = 25,
                                              completion: @escaping (WikipediaSearchResults?, WikipediaError?) -> ())
        -> URLSessionDataTask? {
        
        let searchMethod = existingSearchResults?.searchMethod ?? .prefix
        let minCount: Int? = searchMethod == .prefix ? minCount : nil // ignore the minCount for fullText search
        
        self.secondSearchRequest?.cancel()
        
        return self.requestSearchResults(method: searchMethod, term: term, existingSearchResults: existingSearchResults, imageWidth: imageWidth, minCount: minCount, maxCount: maxCount) { searchResults, error in
            
            if searchMethod != .fullText,
                let error = error,
                error == WikipediaError.notEnoughResults || error == WikipediaError.notFound {
                
                var prefixSearchResults: WikipediaSearchResults?
                if error == .notEnoughResults {
                    prefixSearchResults = searchResults
                }
                
                self.secondSearchRequest = self.requestSearchResults(method: .fullText, term: term, existingSearchResults: nil, imageWidth: imageWidth, maxCount: maxCount) { fullTextSearchResults, error in
                    if (fullTextSearchResults?.items.count ?? 0) >= (prefixSearchResults?.items.count ?? 0) {
                        DispatchQueue.main.async {
                            completion(fullTextSearchResults, error)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(prefixSearchResults, nil)
                        }
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    completion(searchResults, error)
                }
            }
        }
    }
    
    func requestSearchResults(method: WikipediaSearchMethod,
                              term: String,
                              existingSearchResults: WikipediaSearchResults? = nil,
                              imageWidth: Int = 200,
                              minCount: Int? = nil,
                              maxCount: Int = 15,
                              completion: @escaping (WikipediaSearchResults?, WikipediaError?) -> ())
        -> URLSessionDataTask? {
        
        var searchResults: WikipediaSearchResults
        
        if let sr = existingSearchResults {
            
            guard sr.term == term else {
                    DispatchQueue.main.async {
                        completion(nil, .other(nil))
                    }
                    return nil
            }
            
            searchResults = sr
        } else {
           // searchResults = WikipediaSearchResults(term: term)
            searchResults = WikipediaSearchResults()
        }
        
        searchResults.searchMethod = method
        
        if let cachedSearchResults = self.searchResultsCache.get(method: method, term: term) {
            if cachedSearchResults.items.count > searchResults.items.count {
                DispatchQueue.main.async {
                    completion(cachedSearchResults, nil)
                }
                return nil
            } else {
                searchResults = cachedSearchResults
            }
        }
        
        searchResults.offset = searchResults.items.last?.index ?? 0
        
        if imageWidth == 0 {
            print("The response will have no thumbnails because the imageWidth you passed is 0")
        }

        let parameters: [String:String]
        
        switch method {
        case .prefix:
            parameters = [
                "action": "query",
                "format": "json",
                "generator": "prefixsearch",
                "gpssearch": term,
                "gpsnamespace": "\(WikipediaNamespace.main.rawValue)",
                "gpslimit": "\(maxCount)",
                "gpsoffset": "\(searchResults.offset)",
                "prop": "extracts|pageterms|pageimages",
                "piprop": "thumbnail",
                "pithumbsize": "\(imageWidth)",
                "pilimit": "\(maxCount)",
                "exlimit": "\(maxCount)",
                "explaintext": "1",
                "exintro": "1",
                "formatversion": "2",
                "continue": "",
                "redirects": "1",
                "converttitles": "1",
                // get search suggestions
                "srsearch": term,
                "srwhat": "text",
                "srlimit": "1",
                "srnamespace": "\(WikipediaNamespace.main.rawValue)",
                "list": "search",
                "srinfo": "suggestion",
                "maxage": "\(self.maxAgeInSeconds)",
                "smaxage": "\(self.maxAgeInSeconds)",
                "uselang": "en",
            ]
            
        case .fullText:
            parameters = [
                "action": "query",
                "format": "json",
                "generator": "search",
                "gsrsearch": term,
                "gsrnamespace": "\(WikipediaNamespace.main.rawValue)",
                "gsrlimit": "\(maxCount)",
                "gsroffset": "\(searchResults.offset)",
                "prop": "extracts|pageterms|pageimages",
                "piprop": "thumbnail",
                "pithumbsize": "50",
                //"pithumbsize": "\(imageWidth)",
                "pilimit": "\(maxCount)",
                "exlimit": "\(maxCount)",
                "explaintext": "1",
                "exintro": "1",
                "formatversion": "2",
                "continue": "",
                "redirects": "1",
                "converttitles": "1",
                // get search suggestions
                "list": "search",
                "srsearch": term,
                "srwhat": "text",
                "srlimit": "1",
                "sroffset": "\(searchResults.offset)",
                "srnamespace": "\(WikipediaNamespace.main.rawValue)",
                "srinfo": "suggestion",
                "maxage": "\(self.maxAgeInSeconds)",
                "smaxage": "\(self.maxAgeInSeconds)",
                "uselang": "en",
            ]
        }
        
        guard let request = Wikipedia.buildURLRequest(parameters: parameters)
            else {
                DispatchQueue.main.async {
                    completion(nil, .other(nil))
                }
                return nil
        }
        
        return WikipediaNetworking.shared.loadJSON(urlRequest: request) { jsonDictionary, error in
            
            guard error == nil else {
                // (also occurs when the request was cancelled programmatically)
                DispatchQueue.main.async {
                    completion (searchResults, error)
                }
                return
            }
            
            guard let jsonDictionary = jsonDictionary else {
                DispatchQueue.main.async {
                    completion (searchResults, .decodingError)
                }
                return
            }
            
            guard let query = jsonDictionary["query"] as? JSONDictionary else {
                DispatchQueue.main.async {
                    completion (searchResults, .notFound)
                }
                return
            }
            
            if let searchinfo = query["searchinfo"] as? JSONDictionary,
                let suggestion = searchinfo["suggestion"] as? String {
                searchResults.suggestions.removeAll()
                let capitalizedSuggestion = suggestion.capitalized(with: Locale(identifier:"en"))
                searchResults.suggestions.append(capitalizedSuggestion)
            }
            
            if let pages = query["pages"] as? [JSONDictionary] {
                
                var results = [WikipediaArticlePreview]()
                for page in pages {
                    if let result = WikipediaArticlePreview(jsonDictionary: page) {
                        if !searchResults.items.contains(result) {
                            results.append(result)
                        }
                    }
                }
                
                // The check for <= 1 fixes a Wikipedia API bug where it will indefinitely
                // load the same item over and over again
                if jsonDictionary["continue"] == nil || results.count <= 1 {
                    searchResults.canLoadMore = false
                }
                
                results.sort { $0.index < $1.index }
                searchResults.items.append(contentsOf: results)
                
                if searchResults.offset == 0,
                    let minCount = minCount,
                    pages.count < minCount {
                    
                    DispatchQueue.main.async {
                        completion (searchResults, .notEnoughResults)
                    }
                    return
                }
                
                self.searchResultsCache.add(searchResults)
                
                DispatchQueue.main.async {
                    completion(searchResults, error)
                }
                
            }  else {
                
                // No pages and offset of 0; this means that there are no results for this query.
                if searchResults.offset == 0 {
                    DispatchQueue.main.async {
                        completion (searchResults, .notFound)
                    }
                    return
                } else {
                    // No pages found but there are already search results; this means that there are no more results.
                    searchResults.canLoadMore = false
                    DispatchQueue.main.async {
                        completion (searchResults, error)
                    }
                    return
                }
                
            }
            
        }
        
    }
}
