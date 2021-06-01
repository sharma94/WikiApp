//
//  WikiListViewModel.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import Foundation

class WikiListViewModel: ObservableObject {
    
    @Published var wikiSearchList = [WikipediaArticlePreview]()
    
    @Published var searchText = "" {
        didSet {
            getSearchResults(for: searchText)
        }
    }
    
    func getSearchResults(for searchText: String) {
        let _ = Wikipedia.shared.requestOptimizedSearchResults(term: searchText) { (searchResults, error) in
            
            guard error == nil else { return }
            guard let searchResults = searchResults else { return }
            self.wikiSearchList = searchResults.items
        }
    }
}
