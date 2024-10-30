//
//  ContentView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/10/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerDataHandler:PlayerDataHandler
    @StateObject var networkMonitor=NetworkMonitor()
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets:GoodMatchSetsOnCourt
    @EnvironmentObject var authService:AuthService
  
    var body: some View{
        if(authService.signedIn){
            AfterLoginView().environmentObject(myPlayers).environmentObject(goodMatchSets).environmentObject(playerDataHandler)}else{
                    WelcomeView().environmentObject(authService)
                
            }
        
    }
}

#Preview {
    ContentView()
}
