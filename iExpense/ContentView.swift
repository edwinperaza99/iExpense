//
//  ContentView.swift
//  iExpense
//
//  Created by csuftitan on 3/21/24.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()

    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            List {
                Section("Business"){
                    ForEach(expenses.items.filter {$0.type == "Business"}) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(determineFont(amount: item.amount))
                        }
                    }
                    .onDelete { offsets in
                            removeItems(at: offsets, from: "Business")
                        }
                }
                Section("Personal") {
                    ForEach(expenses.items.filter {$0.type == "Personal"}) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(determineFont(amount: item.amount))
                        }
                    }
                    .onDelete { offsets in
                           removeItems(at: offsets, from: "Personal")
                       }
                }
               
                
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }

    func removeItems(at offsets: IndexSet, from section: String) {
        let filteredItems = expenses.items.filter { $0.type == section }
        let idsToRemove = Set(offsets.map { filteredItems[$0].id })
        expenses.items.removeAll { idsToRemove.contains($0.id) }
    }
    func determineFont(amount: Double) -> Font {
        if amount > 100 {
            return .title
        } else if amount < 10 {
            return .subheadline
        } else {
            return .body
        }
    }

}

#Preview {
    ContentView()
}
