//
//  WikiSearchView.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import SwiftUI

struct WikiSearchView: View {
    @ObservedObject var listVM = WikipediaSearchResults()
    
    var body: some View {
    
        VStack{
            SearchBar(listVM: self.listVM)
            Spacer()
            List {
                
               ForEach(listVM.items, id: \.self) { item in
                    WikiSearchCellView(wikiItem: item)
                }
            }
        }
    }
}

struct WikiSearchView_Previews: PreviewProvider {
    static var previews: some View {
        WikiSearchView()
    }
}

struct WikiSearchCellView: View {
    var wikiItem: WikipediaArticlePreview
    
    var body: some View {
        HStack (alignment: .center)  {
            VStack(alignment: .leading, spacing: 7) {
                Text(wikiItem.displayTitle)
                    .fontWeight(.bold)
                    //.font(.headline)
                Text(wikiItem.description)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "person")
        }
    }
}
