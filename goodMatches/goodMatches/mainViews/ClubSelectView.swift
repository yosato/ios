//
//  SelectClubView.swift
//  goodMatches
//
//  Created by Yo Sato on 27/10/2024.
//

import SwiftUI

struct ClubSelectView: View {
    let clubs=["club A","club B","Club C","Club D"]
    var body: some View {
        NavigationStack{
            ForEach(clubs,id:\.self){club in
                Text("\(club)")}
        }.navigationTitle("Choose the club to join")
    }
}

#Preview {
    ClubSelectView()
}
