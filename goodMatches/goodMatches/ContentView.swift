//
//  ContentView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI


struct ContentView: View {
    @StateObject var playerDataHandler=PlayerDataHandler()
    var body: some View {
        NavigationStack {
            Spacer()
            Spacer()
            Text("goodMatches").font(.largeTitle)
            Spacer()
            
//            MultiPicker(selection1:$selection1,selection2:$selection2,values1:values1,values2:values2)
            
            NavigationLink(destination:PlayerView(playerDataHandler:playerDataHandler)){
                Text("Pick players").font(.headline)}
            Spacer()
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    
}

#Preview {
    ContentView().environmentObject(PlayersOnCourt())
}
