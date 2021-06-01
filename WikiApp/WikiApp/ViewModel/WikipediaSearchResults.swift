//
//  WikipediaSearchResults.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation

class WikipediaSearchResults: ObservableObject {
    
     var searchMethod = WikipediaSearchMethod.prefix
    
    @Published var term: String = "" {
        didSet {
            self.getSearchResults(for: term)
        }
    }

     var offset = 0
     var canLoadMore = true
    
     var suggestions = [String]()

    @Published var items = [WikipediaArticlePreview]()
    
     var hasResults: Bool {
        get {
            return self.items.count > 0 ? true : false
        }
    }
    
    func getSearchResults(for searchText: String) {
        let _ = Wikipedia.shared.requestOptimizedSearchResults(term: searchText) { (searchResults, error) in
            
            guard error == nil else { return }
            guard let searchResults = searchResults else { return }
            self.items = searchResults.items
        }
    }
}
