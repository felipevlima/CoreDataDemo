//
//  ContentView.swift
//  Demo
//
//  Created by Felipe Vieira Lima on 28/02/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var dbContext
    @FetchRequest(sortDescriptors: [], predicate: nil, animation: .default)
    private var listOfBooks: FetchedResults<Books>
    
    @SectionedFetchRequest(sectionIdentifier: \Books.firstLetter, sortDescriptors: [SortDescriptor(\Books.title, order: .forward)], predicate: nil) private var sectionBooks: SectionedFetchResults<String?, Books>
    
    
    @State private var search: String = ""
    @State private var totalBooks: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Total Books")
                    Spacer()
                    Text("\(totalBooks)")
                        .bold()
                }.foregroundColor(.green)
                
                ForEach(sectionBooks) { section in
                    Section(header: Text(section.id ?? "Undefined")) {
                        ForEach(section) { book in
                            NavigationLink(destination: ModifyBookView(book: book), label: {
                                RowBook(book: book)
                                    .id(UUID())
                            })
                        }
                        .onDelete(perform: { indexes in
                            Task(priority: .high) {
                                await deleteBook(indexes: indexes)
                            }
                        })
                    }
                }
                
            }
            .navigationBarTitle("Books")
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Menu("Sort") {
//                        Button("Sort by Title", action: {
//                            let sort = SortDescriptor(\Books.title, order: .forward)
//                            listOfBooks.sortDescriptors = [sort]
//                        })
//                        Button("Sort by Author", action: {
//                            let sort = SortDescriptor(\Books.author?.name, order: .forward)
//                            listOfBooks.sortDescriptors = [sort]
//                        })
//                        Button("Sort by Year", action: {
//                            let sort = SortDescriptor(\Books.year, order: .reverse)
//                            listOfBooks.sortDescriptors = [sort]
//                        })
//                    }
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: InsertBookView(), label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .searchable(text: $search, prompt: Text("Insert Title"))
            .onChange(of: search) { value in
                if !value.isEmpty {
                    listOfBooks.nsPredicate = NSPredicate(format: "title CONTAINS[dc] %@", value)
                } else {
                    listOfBooks.nsPredicate = nil
                }
            }
            .onAppear {
                countBook()
            }
//            .onChange(of: search) { value in
//                if value.count == 4 {k
//                    if let year = Int32(value) {
//                        listOfBooks.nsPredicate = NSPredicate(format: "year = %@", NSNumber(value: year))
//                    }
//                } else {
//                    listOfBooks.nsPredicate = nil
//                }
//            }
        }
    }
    func countBook() {
        let request: NSFetchRequest<Books> = Books.fetchRequest()
        if let count = try? self.dbContext.count(for: request) {
            totalBooks = count
        }
    }
    
    func deleteBook(indexes: IndexSet) async {
        await dbContext.perform {
            for index in indexes {
                dbContext.delete(listOfBooks[index])
                countBook()
            }
            
            do {
                try dbContext.save()
            } catch {
                print("Error to delete book")
            }
        }
    }
}

struct RowBook: View {
    let book: Books
    
    var body: some View {
        HStack (alignment: .top) {
            Image(uiImage: book.showCover)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
            VStack (alignment: .leading, spacing: 2) {
                Text(book.showTitle)
                    .bold()
                Text(book.showAuthor)
                    .foregroundColor(book.author != nil ? .black : .gray)
                Text(String(book.showYear))
                    .font(.caption)
                Spacer()
            }
            .padding(.top, 5)
            Spacer()
        }
        .padding(.top, 5)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, ApplicationData.preview.container.viewContext)
    }
}
