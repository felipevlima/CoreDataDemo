//
//  InsertAuthorView.swift
//  Demo
//
//  Created by Felipe Vieira Lima on 01/03/23.
//

import SwiftUI
import CoreData

struct InsertAuthorView: View {
    @Environment(\.managedObjectContext) var dbContext
    @Environment(\.dismiss) var dismiss
    @State private var inputName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Name:")
                TextField("Insert Name", text: $inputName).textFieldStyle(.roundedBorder)
            }
            HStack {
                Spacer()
                Button("Save") {
                    let newName = inputName.trimmingCharacters(in: .whitespaces)
                    if !newName.isEmpty {
                        Task(priority: .high) {
                            await storeAuthor(name: newName)
                        }
                    }
                }
            }
            Spacer()
        }.padding()
            .navigationBarTitle("Add Author")
    }
    
    func storeAuthor(name: String) async {
        await dbContext.perform {
            let request: NSFetchRequest<Authors> = Authors.fetchRequest()
            request.predicate = NSPredicate(format: "name = %@", name)
            if let total = try? self.dbContext.count(for: request), total == 0 {
                let newAuthor = Authors(context: dbContext)
                newAuthor.name = name
                do {
                    try dbContext.save()
                } catch {
                    print("Error saving record")
                }
            }
        }
    }
}

struct InsertAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        InsertAuthorView()
    }
}
