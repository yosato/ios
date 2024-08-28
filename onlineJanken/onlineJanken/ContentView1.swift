//
//  ContentView1.swift
//  onlineJanken
//
//  Created by Yo Sato on 27/08/2024.
//

import SwiftUI
import jankenModels

struct ContentView1: View {
    
  //  @EnvironmentObject var authService:AuthService
  //  @EnvironmentObject var dataService:DataService
    @EnvironmentObject var jankenSeries:JankenSeriesInGroup
    var round:JankenRound=JankenRound(
        finalSession: JankenSession([
//                Participant(displayName: "B", email: "bbb@ccc.co.uk"): JankenHand.rock,
//            Participant(displayName: "C", email: "ccc@ccc.co.uk"): JankenHand.rock,
                Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
                Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
                Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]),
        drawnSessions: DrawnSessions(participants:
                    Set([ //  Participant(displayName: "B", email: "bbb@ccc.co.uk"),
  //                          Participant(displayName: "C", email: "ccc@ccc.co.uk"),
                        Participant(displayName: "D", email: "eee@fff.com"),
                        Participant(displayName: "F", email: "eef@fff.com"),
                        Participant(displayName: "E", email: "bbb@ccc.co.uk")])),
        parentAddress: "",
        parentRange: (1...4)
            )

    var body: some View {
        RoundResultView(round:round)
    }
}

#Preview {
    ContentView1().environmentObject(JankenSeriesInGroup())
}
