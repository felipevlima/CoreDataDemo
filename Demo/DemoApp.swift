//
//  DemoApp.swift
//  Demo
//
//  Created by Felipe Vieira Lima on 28/02/23.
//

import SwiftUI

@main
struct DemoApp: App {
    @StateObject var appData = ApplicationData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environment(\.managedObjectContext, appData.container.viewContext)
        }
    }
}
