//
//  test.swift
//  goodMatches
//
//  Created by Yo Sato on 02/03/2024.
//

import SwiftUI
struct MultipleSelectionList: View {
    @State var items: [String] = ["Apples", "Oranges", "Bananas", "Pears", "Mangos", "Grapefruit"]
    @State var selections: [String] = []

    var body: some View {
        List(self.items, id: \.self)
     { item in
                MultipleSelection(title: item, isSelected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            
        }
    }
}

#Preview {
    MultipleSelectionList()
}
