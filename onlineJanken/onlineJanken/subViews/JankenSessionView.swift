//
//  JankenSessionView.swift
//  onlineJanken
//
//  Created by Yo Sato on 15/08/2024.
//

import SwiftUI
import jankenModels

struct JankenSessionView: View {
    var session:JankenSession
    let fakeSessions=[
        JankenSession([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.paper,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock])
    ]

    var body: some View {
            VStack{
                    HStack{
                        ForEach(Array(session.participantHandPairs.keys).sorted{$0.displayName<$1.displayName}){participant in
                            if(session.winners.isEmpty){
                                VStack{
                                    Image(session.participantHandPairs[participant]!.rawValue).resizable().frame(width:40,height:40)
                                    Text(participant.displayName)
                                }
                            }else{
                                VStack{
                                    Image(session.participantHandPairs[participant]!.rawValue).resizable().frame(width:40,height:37)
                                    Text(participant.displayName)
                                }//.frame(maxWidth:50,maxHeight:70).background((session.winners.contains(participant) ? .green : .red)).opacity((session.winners.contains(participant) ? 1.0 : 0.4))

                            }
                            
                        }
                    }
                Text(session.winners.isEmpty ? "あいこ" : "\(session.winners.map{winner in winner.displayName}.sorted{$0<$1}.joined(separator:"と"))が勝ちました！")
                
        }//.onAppear{jankenSessions.add_sessions(fakeSessions)}
    }
}

#Preview {
    JankenSessionView( session:       JankenSession([
        Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
        Participant(displayName: "D", email: "eee@fff.com"): JankenHand.scissors,
        Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
        Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock]))
//.environmentObject(JankenSessions())
}
