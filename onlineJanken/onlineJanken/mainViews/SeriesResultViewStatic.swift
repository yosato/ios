//
//  SeriesResultView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels


struct SeriesResultViewStatic: View {
    @EnvironmentObject var series:JankenSeriesInGroup
    var sortedRounds:[JankenRound] {Array(series.seriesTree.rounds).sorted{($0.parentAddress.count,$0.parentAddress)<($1.parentAddress.count,$1.parentAddress)}}
    
    
    var body: some View {
        
    ScrollView{
            VStack{
                
                ForEach(sortedRounds){round in
                    address2properText(address:round.parentAddress).padding(30)
                    
                    HStack{
                        ForEach(Array(round.participants.sorted{$0.displayName<$1.displayName})){participant in
                            Text(participant.displayName).padding(6)}
                    }

                    
                    ForEach(round.bouts){bout in
                        JankenBoutView(session:bout)
                    }
                    get_rank_text(round).padding()
                    Divider()

                }
            }
        }
    }
}

#Preview {
    
    SeriesResultViewStatic().environmentObject(
        JankenSeriesInGroup(seriesTree:JankenTree(branches:
                           Set([
                            
                               JankenRound(finalBout:JankenBout(
                                   [Participant(displayName:"John",email:"john@email.com"): JankenHand.scissors
                                ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.scissors
                                ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
                                ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
                               ]),
                                       drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),
                                                                                       Participant(displayName:"Tim", email:"tim@email.com")
                                                                                       ,Participant(displayName: "Dan", email:"dan@email.com")
                                                                                ,Participant(displayName:"Yo", email:"yo@email.com")
                                                                                ,Participant(displayName:"Zak", email:"zak@email.com")
                                                                                      ]),
                                                             bouts:[
                                                                JankenBout(
                                                                                       [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                                                        ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                                                                        ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
                                                                                        ,Participant(displayName:"Yo", email:"yo@email.com"): JankenHand.paper
                                                                                        ,Participant(displayName:"Zak", email:"zak@email.com"): JankenHand.paper
                                                               ])
                                                             ]),
                                       parentAddress:"",parentRange:1...5
                                      )
                                       
                                       ,
                                       JankenRound(finalBout:JankenBout(
                               [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper
                               ]),
                                       drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),Participant(displayName:"Tim", email:"tim@email.com"),Participant(displayName: "Dan", email:"dan@email.com")]),
                                           bouts:[
                                               JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                           ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
                                                           ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
                                               , JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                             ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                                             ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock])
                                           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.scissors
                                                        ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors
                                                        ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.scissors])
                                           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                        ,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper
                                                        ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
                                           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.paper,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
                                       ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.rock,
                                                    Participant(displayName:"Tim", email:"tim@email.com"): JankenHand.scissors,
                                                    Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])

                                       ]),
                                       parentAddress:"0",parentRange:1...3
                                      )
                                       
                                       ,
                                       JankenRound(finalBout:JankenBout(
                                                               [Participant(displayName:"John",email:"john@email.com"): JankenHand.paper
                                                                ,Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock
                                                               ]),
                                                                       drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"John",email:"john@email.com"),Participant(displayName: "Dan", email:"dan@email.com")]),bouts:[
                                                                        JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.rock, Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.rock])
//                                                                           ,JankenBout([Participant(displayName:"John",email:"john@email.com"): JankenHand.paper,
//                                                                                       Participant(displayName: "Dan", email:"dan@email.com"): JankenHand.paper])
//
                                                                       ]
                                                                       ),
                                                                       parentAddress:"01",parentRange:2...3
                                                                      )
                                       ,
                                       
                                       JankenRound(finalBout:JankenBout(
                                                               [Participant(displayName:"Yo",email:"yo@email.com"): JankenHand.paper
                                                                ,Participant(displayName: "Zak", email:"zak@email.com"): JankenHand.rock
                               ]),
                                       drawnBouts:DrawnBouts(participants:Set( [Participant(displayName:"Yo",email:"yo@email.com"),Participant(displayName: "Zak", email:"zak@email.com")]),bouts:[
                                            JankenBout([Participant(displayName:"Yo",email:"yo@email.com"): JankenHand.rock, Participant(displayName: "Zak", email:"zak@email.com"): JankenHand.rock])
//
                                       
                                       ]
                                       ),
                                       parentAddress:"1",parentRange:4...5
                                      )
                                       

                               
    
])
                                                  
                                                  
)))
}
