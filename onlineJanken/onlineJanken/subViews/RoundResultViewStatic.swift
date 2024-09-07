//
//  RoundResultViewStatic.swift
//  onlineJanken
//
//  Created by Yo Sato on 02/09/2024.
//


import SwiftUI
import jankenModels

struct RoundResultViewStatic: View {
    let round:JankenRound

    var body: some View {
        ScrollViewReader{scrollView in
            //GeometryReader{geo in
            ScrollView{
                if(round.parentAddress==""){Text("初戦")}else{Text(round.parentAddress)}
                LazyVStack{
                    ForEach(round.sessions,id:\.self){ session in
                        //         VStack{Text("aaa");Text("iii");Text("\(number)")}.padding(10)
                        
                            JankenSessionView(session:session)
                        
                    }.transition(.opacity)

                }.padding()
                }
            }
    }
}
#Preview {
    RoundResultViewStatic(round:
                        JankenRound(
                            finalSession: JankenSession([
                                Participant(displayName: "A", email: "aaa@ccc.co.uk"): JankenHand.rock
                                , Participant(displayName: "B", email: "bbb@ccc.co.uk"): JankenHand.rock
                                , Participant(displayName: "C", email: "ccc@ccc.co.uk"): JankenHand.rock
                                ,   Participant(displayName: "D", email: "ddd@ccc.co.uk"): JankenHand.scissors
                                ,   Participant(displayName: "F", email: "fff@ccc.co.uk"): JankenHand.scissors
                                ,  Participant(displayName: "E", email: "eee@ccc.co.uk"): JankenHand.rock
                                ,  Participant(displayName: "G", email: "ggg@ccc.co.uk"): JankenHand.rock
                                ,  Participant(displayName: "HHHHHHHHH", email: "hhh@ccc.co.uk"): JankenHand.rock
                                ,  Participant(displayName: "I", email: "iii@ccc.co.uk"): JankenHand.rock
                            ]),
                            drawnSessions: DrawnSessions(participants:
                                        Set([
                                            Participant(displayName: "A", email: "aaa@ccc.co.uk"),
                                            Participant(displayName: "B", email: "bbb@ccc.co.uk"),
                                                Participant(displayName: "C", email: "ccc@ccc.co.uk"),
                                            Participant(displayName: "D", email: "ddd@ccc.co.uk"),
                                            Participant(displayName: "F", email: "fff@ccc.co.uk"),
                                            Participant(displayName: "E", email: "eee@ccc.co.uk")
                                            ,  Participant(displayName: "G", email: "ggg@ccc.co.uk")
                                            ,  Participant(displayName: "HHHHHHHHH", email: "hhh@ccc.co.uk")
                                            ,  Participant(displayName: "I", email: "iii@ccc.co.uk")
                                            
                                            
                                        ])),
                            parentAddress: "",
                            parentRange: (1...9)
                                )
        )
}


