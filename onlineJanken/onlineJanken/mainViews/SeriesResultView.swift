//
//  SeriesResultView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels

struct SeriesResultView: View {
    @EnvironmentObject var series:JankenSeriesInGroup
    var IDsSessions:[String:JankenSession] {series.seriesTree.IDsSessions}
    
    var body: some View {
        ScrollView{
            VStack{
                Text(series.seriesTree.sortedLeaves.map{part in part.displayName}.joined(separator:"--"))
                ForEach(Array(series.seriesTree.rounds).sorted{$0.parentAddress<$1.parentAddress},id:\.self){round in
                    
                    Text(round.parentAddress.replacingOccurrences(of: "0", with:    "W").replacingOccurrences(of: "1", with: "L")).padding()
                    
                    let finalSession=IDsSessions[round.finalSessionID]!
                    let drawnSessions=IDsSessions.filter{(id,session) in round.drawSessionIDs.contains(id)}.map{(_id,session) in session}
                    let sessions=drawnSessions+[finalSession]
                                        
//                    RoundResultView(session:sessions)
                    
                    ForEach(sessions,id:\.self){session in
                        let strings=session.participantHandPairs.map{(part,hand) in part.displayName+": "+hand.rawValue}.sorted{$0<$1}
                        Text(strings.joined(separator:" ")).padding(2)
                        
                    }
                    
                }
            }
        }
    }
}

#Preview { 
    SeriesResultView().environmentObject(JankenSeriesInGroup(groupMembers:Set([
        Participant(displayName: "John", email: "hahaha@mail.com")
        ,Participant(displayName: "Mary", email: "hihihi@mail.com")
        ,Participant(displayName: "Dan", email: "huhuhu@mail.com")        ,Participant(displayName: "Tim", email: "hehehe@mail.com")
        ,Participant(displayName: "Darlene", email: "hehehe@mail.com")
        ,Participant(displayName: "Zak", email: "hahaha@mail.com")
        ,Participant(displayName: "Yo", email: "hihihi@mail.com") 
//        ,Participant(displayName: "Motoko", email: "huhuhu@mail.com")
//        ,Participant(displayName: "Brian", email: "hehehe@mail.com")
//        ,Participant(displayName: "Simon", email: "hehehe@mail.com")
//        Participant(displayName: "K", email: "hehehe@mail.com"),
//        Participant(displayName: "L", email: "hohoho@mail.com"),
//        Participant(displayName: "M", email: "hohoho@mail.com"),
//        Participant(displayName: "L", email: "hohoho@mail.com"),
//        Participant(displayName: "M", email: "hohoho@mail.com"),
//        Participant(displayName: "N", email: "hehehe@mail.com"),
//        Participant(displayName: "O", email: "hehehe@mail.com"),
//        Participant(displayName: "P", email: "hohoho@mail.com"),
//        Participant(displayName: "Q", email: "hohoho@mail.com"),
//        Participant(displayName: "R", email: "hehehe@mail.com"),
//        Participant(displayName: "S", email: "hohoho@mail.com"),
//        Participant(displayName: "T", email: "hohoho@mail.com"),
//        Participant(displayName: "U", email: "hehehe@mail.com"),
//        Participant(displayName: "V", email: "hohoho@mail.com"),
//        Participant(displayName: "W", email: "hohoho@mail.com"),
//        Participant(displayName: "X", email: "hehehe@mail.com"),
//        Participant(displayName: "Y", email: "hehehe@mail.com"),
//        Participant(displayName: "Z", email: "hohoho@mail.com")

    ])))
}
