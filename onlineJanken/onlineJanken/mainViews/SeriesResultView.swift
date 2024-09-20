//
//  SeriesResultView.swift
//  onlineJanken
//
//  Created by Yo Sato on 23/08/2024.
//

import SwiftUI
import jankenModels

enum ViewState{
    case NotStarted, InProgress, Finished
}

struct SeriesResultView: View {
    @EnvironmentObject var series:JankenSeriesInGroup
    var memberCount:Int {series.groupMembers.count}
    var sortedRounds:[JankenRound] {Array(series.seriesTree.rounds).sorted{($0.parentAddress.count,$0.parentAddress)<($1.parentAddress.count,$1.parentAddress)}}
    //  let timer = Timer.publish (every: 2, on: .main, in: .common).autoconnect()
    @State private var currentNumberMain=0
    var lastNumber:Int {sortedRounds.count-1}
    var numbers:[Int] {Array(0...currentNumberMain) }
    
    //var lastNumberInner:Int {round.sessions.count-1}
    @State var currentNumberInner=0
    var numbersInner:[Int] {Array(0...currentNumberInner)}
    
    var previousSessionCount:Int=0
    var innerInterval=1
    var betweenInterval=2
    var showRankingDuration=2
    @State var showRank=false
    @State var showFinalResult=false
    
    
    var body: some View {
        VStack{
            let round=sortedRounds[currentNumberMain]
            let innerFinalInd=round.bouts.count-1
            //inner round view
            //            Text("\(sortedRounds.map{round in round.bouts.count})")
            address2properText(address:round.parentAddress).padding()
            HStack{
                ForEach(Array(round.participants.sorted{$0.displayName<$1.displayName})){participant in
                    Text(participant.displayName).padding(6)}
            }
            
            ScrollViewReader{scrollView in
                ScrollView{
                    
                    //inner loop for a round
                    VStack{
                        
                        ForEach(numbersInner,id:\.self){ numberInner in
                            //if(currentNumberInner != innerFinalInd){
                            //                            Text("\(currentNumberMain) \(lastNumber) \(currentNumberInner) \(innerFinalInd)")
                            JankenBoutView(session:round.bouts[numberInner]).padding(5)
                        }.transition(.opacity)
                            .onChange(of:currentNumberInner){
                                if(currentNumberInner != innerFinalInd){DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+DispatchTimeInterval.seconds(innerInterval)){currentNumberInner+=1}}else {showRank=true}
                                scrollView.scrollTo(currentNumberInner, anchor:.center)
                            }
                    }
                }.onAppear{ DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+DispatchTimeInterval.seconds(round.bouts.count*innerInterval+betweenInterval+showRankingDuration)){currentNumberInner=0;currentNumberMain+=1}
                }
                .onChange(of:currentNumberMain){
                    let delay=DispatchTimeInterval.seconds((round.bouts.count)*innerInterval+betweenInterval+showRankingDuration)
                    
                    if(currentNumberMain ==  lastNumber){ DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+delay){showFinalResult=true}
                    }else{DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+delay){currentNumberInner=0;currentNumberMain+=1}}
                }
                if(showRank){
                    get_rank_text(round).font(.headline).padding(50).onAppear{DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+DispatchTimeInterval.seconds(betweenInterval+showRankingDuration+1)){showRank=false}}
                }
            }
            
        }
        //get the whole thing going (after a second)
        .onAppear{DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+1){currentNumberInner+=1}}
        .sheet(isPresented:$showFinalResult){ResultSummaryView().environmentObject(series)}
    }
}

func get_rank_text(_ round:JankenRound)-> some View {
    var str2return=""
    if(round.hasAWinner||round.hasALoser){
        if(round.hasAWinner){
            let isFirst=(round.parentRange.first!==1)
            str2return+="\n順位決定 \(round.leftSet.first!.displayName) \(round.parentRange.first!)位"+(isFirst ? "!! おめでとう！" : "")
        }
        if(round.hasALoser){
            str2return+="\n順位決定 \(round.rightSet.first!.displayName) \(round.parentRange.last!)位"
        }
    }
    return Text(str2return)
}

struct address2properText:View{
    var address:String
    @ViewBuilder
    var body: some View{ 
        if(address==""){HStack{Text("初戦")}.font(.title)}
        else{
            let properText=String(address.count+1)+"回戦"
            let winsLosses=address.replacingOccurrences(of: "0", with: "○").replacingOccurrences(of: "1", with: "●")
            VStack(alignment:.leading){Text(winsLosses);Text(properText).font(.title)}
        }
    }
}


#Preview {
    
    SeriesResultView().environmentObject(
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
