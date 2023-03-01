//
//  ApplicationData.swift
//  Demo
//
//  Created by Felipe Vieira Lima on 28/02/23.
//

import SwiftUI
import CoreData

class ApplicationData: ObservableObject {
    let container: NSPersistentContainer
    
    static var preview: ApplicationData = {
        let model = ApplicationData(preview: true)
        return model
    }()
    
    init(preview: Bool = false) {
        container = NSPersistentContainer(name: "Demo")
        if preview {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

