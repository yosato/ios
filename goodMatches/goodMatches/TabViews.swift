//
//  TabViews.swift
//  goodMatches
//
//  Created by Yo Sato on 03/06/2024.
//

import SwiftUI

struct TabViews: View {
    var liveMode:Bool
    @Binding var registeredPlayers:[PlayerInClub]
    var debug:Bool
    @EnvironmentObject var matchResults:MatchSetHistory
//    @EnvironmentObject var matchResults:MatchResults
    var body: some View {
        TabView{ 
            MatchView(liveMode:liveMode,debug:debug).tabItem{
                Label("Matches", systemImage:"tennis.racket")
            }
            PlayerConfirmView(registeredPlayers:$registeredPlayers,debug:debug).tabItem{
            Label("Players", systemImage:"figure.tennis")
            }
            ResultHistoryView().tabItem{
            Label("Results", systemImage:"list.clipboard")
            }.environmentObject(matchResults)
        }

    }
}

//#Preview {
//    TabViews(liveMode:true,debug:false)
//}
