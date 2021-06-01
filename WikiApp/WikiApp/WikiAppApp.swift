//
//  WikiAppApp.swift
//  WikiApp
//
//  Created by R M Sharma on 31/05/21.
//

import SwiftUI

@main
struct WikiAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
