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
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(myPlayers).environmentObject(goodMatchSets)
        }
    }
}
