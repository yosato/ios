//
//  goodMatchesApp.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI
import FirebaseCore

@main
struct goodMatchesApp: App {
    @StateObject var myPlayers=PlayersOnCourt()
    @StateObject var goodMatchSets=GoodMatchSetsOnCourt()
    @StateObject var matchResults=MatchSetHistory()
    @StateObject var authService=AuthService()
    @StateObject var playerDataHandler=PlayerDataHandler()
    @StateObject var playerViewModel=PlayerViewModel()
    
    init(){
        FirebaseApp.configure()
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(playerDataHandler).environmentObject(playerViewModel).environmentObject(myPlayers).environmentObject(goodMatchSets).environmentObject(matchResults).environmentObject(authService)
        }
    }
}
