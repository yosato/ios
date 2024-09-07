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
    var memberCount:Int {series.groupMembers.count}
    var sortedRounds:[JankenRound] {Array(series.seriesTree.rounds).sorted{$0.parentAddress<$1.parentAddress}}
    let timer = Timer.publish (every: 2, on: .main, in: .common).autoconnect()
    @State private var currentNumber=0
    var lastNumber:Int {sortedRounds.count-1}
    var numbers:[Int] {Array(0..<currentNumber+1) }
    @State private var index:Int=0

    var body: some View {
        ScrollViewReader{scrollView in
            ScrollView{
                LazyVStack{
                    
                    ForEach(sortedRounds,id:\.self){round in
                        
                        //                            let round=sortedRounds[number]
                        RoundResultViewStatic(round:round).id(round)
                        
                        
                        //Text("hahahaha").padding(100)
                        
                        if(round.hasAWinner||round.hasALoser){
                            if(round.hasAWinner){
                                Text("順位決定 \(round.leftSet.first!.displayName) \(round.parentRange.first!)位")
                            }
                            if(round.hasALoser){
                                Text("順位決定 \(round.rightSet.first!.displayName) \(round.parentRange.last!)位")
                            }
                        }
                    }
                    Text("最終順位 \(series.seriesTree.sortedLeaves.map{part in part.displayName}.joined(separator: "-"))").padding()
                    
                }   .onChange(of:sortedRounds){
                    scrollView.scrollTo(sortedRounds[sortedRounds.endIndex-1],anchor:.center)}

            }
            .onAppear{series.do_jankenSeries_in_group()}
            .onReceive(timer) { _ in
             currentNumber += 1
             if currentNumber == lastNumber-1 {
                 timer.upstream.connect().cancel()
             }
            }
        }
    }
    }


#Preview {
    SeriesResultView().environmentObject(
        JankenSeriesInGroup(groupMembers:Set([
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

        ]))
    )
}
