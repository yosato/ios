//
//  goodMatchesApp.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI

@main
struct goodMatchesApp: App {
    @StateObject var myPlayers=PlayersOnCourt()
    @StateObject var goodMatchSets=GoodMatchSetsOnCourt()
    @StateObject var matchResults=MatchResults()
    @StateObject var playerDataHandler=PlayerDataHandler(urlString_remote:"http://127.0.0.1:5000/players")
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(myPlayers).environmentObject(goodMatchSets).environmentObject(matchResults).environmentObject(playerDataHandler)
        }
    }
}
