//
//  ModifyBookView.swift
//  Demo
//
//  Created by Felipe Vieira Lima on 01/03/23.
//

import SwiftUI

struct ModifyBookView: View {
    @Environment(\.managedObjectContext) var dbContext
    @Environment(\.dismiss) var dismiss
    @State private var selectedAuthor: Authors? = nil
    @State private var inputTitle: String = ""
    @State private var inputYear: String = ""
    @State private var valuesLoaded: Bool = false
    
    let book: Books?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Title:")
                TextField("Insert Title", text: $inputTitle)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("Year:")
                TextField("Inser Year", text: $inputYear)
                    .textFieldStyle(.roundedBorder)
            }
            HStack (alignment: .top) {
                Text("Author:")
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedAuthor?.name ?? "Undefined")
                        .foregroundColor(selectedAuthor != nil ? Color.black : Color.gray)
                    NavigationLink(destination: AuthorsView(selected: $selectedAuthor), label: {
                        Text("Selected Author")
                    })
                }
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding()
            .navigationBarTitle("Modify Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTitle = inputTitle.trimmingCharacters(in: .whitespaces)
                        let newYear = Int32(inputYear)
                        if !newTitle.isEmpty && newYear != nil {
                            Task(priority: .high) {
                                await saveBook(title: newTitle, year: newYear!)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if !valuesLoaded{
                    selectedAuthor = book?.author
                    inputTitle = book?.title ?? ""
                    inputYear = book?.showYear ?? ""
                    valuesLoaded = true
                }
            }
    }
    
    func saveBook(title: String, year: Int32) async {
        await dbContext.perform {
            book?.title = title
            book?.year = year
            book?.author = selectedAuthor
            
            var letter = String(title.first!).uppercased()
            if Int(letter) != nil {
                letter = "#"
            }
            book?.firstLetter = letter
            
            
            do {
                try dbContext.save()
                dismiss()
            } catch {
                print("Error to saving record")
            }
        }
    }
}

struct ModifyBookView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyBookView(book: nil)
            .environment(\.managedObjectContext, ApplicationData.preview.container.viewContext)
        
    }
}
