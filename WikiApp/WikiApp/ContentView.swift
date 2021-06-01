//
//  ContentView.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    
        
    
    var body: some View {
        
        ZStack {
                    
            VStack {
                        
                HStack {
                            Text("Saved Item List")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                
                            Spacer()
                            
                            Button(action: {
                                
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding()
                        WikiSearchView()
                            .padding(.top, -20)
                        
//                        List(todoItems.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { item in
//                            Text(item.name)
                        }
                        
                        
                    }
        
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
