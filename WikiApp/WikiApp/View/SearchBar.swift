//
//  SearchBar.swift
//  WikiApp
//
//  Created by R M Sharma on 02/06/21.
//

import SwiftUI

struct SearchBar: View {
    @ObservedObject var listVM: WikipediaSearchResults
    
    @State private var isEditing = false
    
    var body: some View {
        
        HStack {
            TextField("Search ...", text: $listVM.term)
            .padding(10)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .onTapGesture {
                self.isEditing = true
            }
            
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)

                    if isEditing {
                        Button(action: {
                            resetSearchBar()
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                            }
                        }
                    }
                )

            if isEditing {
                
                Button(action: {
                    self.isEditing = false
                    resetSearchBar()
                // Dismiss the keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                    .padding(.trailing, 10)
                    .animation(.default)
            }
        }
    }
    
    func resetSearchBar() {
        self.listVM.term = ""
        self.listVM.items = []
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(listVM: WikipediaSearchResults())
    }
}
