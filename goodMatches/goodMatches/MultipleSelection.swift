//
//  MultipleSelection.swift
//  goodMatches
//
//  Created by Yo Sato on 02/03/2024.
//

import SwiftUI

struct MultipleSelection: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void

        var body: some View {
            Button(action: self.action) {
                HStack {
                    Text(self.title)
                    if self.isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
}
    


