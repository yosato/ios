//
//  JankenSessionView.swift
//  onlineJanken
//
//  Created by Yo Sato on 15/08/2024.
//

import SwiftUI
import jankenModels

struct JankenBoutView: View {
    var session:JankenBout
    let scaleOffset=0.16
    let fakeSessions=[
        JankenBout([
            Participant(displayName: "C", email: "bbb@ccc.co.uk"): JankenHand.rock,
            Participant(displayName: "D", email: "eee@fff.com"): JankenHand.paper,
            Participant(displayName: "F", email: "eef@fff.com"): JankenHand.scissors,
            Participant(displayName: "E", email: "bbb@ccc.co.uk"): JankenHand.rock])
    ]

    var body: some View {
            VStack{
                HStack(alignment:.top){
                        ForEach(Array(session.participantHandPairs.keys).sorted{$0.displayName<$1.displayName}){participant in
                            if(session.winners.isEmpty){
                                VStack{
                                    Image(session.participantHandPairs[participant]!.rawValue).resizable().frame(width:40,height:40)
                                    Text(participant.displayName)
                                }.scaleEffect(1-scaleOffset)
                            }else{
                                VStack{
                                    Image(session.participantHandPairs[participant]!.rawValue).resizable().frame(width:40,height:40)
                                    Text(participant.displayName).padding(3).frame(width:.infinity,height:.infinity).background((session.winners.contains(participant) ? .green : .white)).clipShape(RoundedRectangle(cornerRadius:8))
                                }.opacity((session.winners.contains(participant) ? 1.0 : 0.4)).scaleEffect(1+scaleOffset)

                            }
                            
                        }
                    }
                Text(session.winners.isEmpty ? "あいこ" : "\(session.winners.map{winner in winner.displayName+"さん"}.sorted{$0<$1}.joined(separator:"と"))が勝ちました！").font(session.winners.isEmpty ? .body : .headline).padding((session.winners.isEmpty ? 0 : 10))
                
        }//.onAppear{jankenSessions.add_sessions(fakeSessions)}
    }
}

#Preview {
    JankenBoutView( session:       JankenBout([
 
        Participant(displayName: "Tim Henmann"): JankenHand.rock,
        Participant(displayName: "Tam"): JankenHand.scissors,
        Participant(displayName: "Simon"): JankenHand.rock,
        Participant(displayName: "Timothy"): JankenHand.scissors,
        Participant(displayName: "Dan", email: "eee@fff.com"): JankenHand.scissors,
        Participant(displayName: "Flooooorence", email: "eef@fff.com"): JankenHand.rock,
        Participant(displayName: "Eric", email: "bbb@ccc.co.uk"): JankenHand.rock

//        Participant(displayName: "Tim Henmann"): JankenHand.rock,
//        Participant(displayName: "Tam"): JankenHand.scissors,
//        Participant(displayName: "Simon"): JankenHand.paper,
//        Participant(displayName: "Timothy"): JankenHand.scissors,
//        Participant(displayName: "Dan", email: "eee@fff.com"): JankenHand.scissors,
//        Participant(displayName: "Flooooorence", email: "eef@fff.com"): JankenHand.rock,
//        Participant(displayName: "Eric", email: "bbb@ccc.co.uk"): JankenHand.rock

    ]))
}
