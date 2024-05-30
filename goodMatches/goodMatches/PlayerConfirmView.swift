//
//  PlayerConfirmView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerConfirmView: View {
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets: GoodMatchSetsOnCourt
    var likelyCourtCount:Int { myPlayers.players.count.quotientAndRemainder(dividingBy: 4).quotient }
    @State private var courtCount:Int=2
    @State private var inputInvalid=false
    @State private var calculationDone=false
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                Text("Players to be matched").font(.headline).padding()
                List(myPlayers.players,id:\.self){Text($0.name)}
                Text("\(myPlayers.players.count) players selected")
                Spacer()
                HStack{
                    Stepper("How many courts?\t\t\t \(courtCount)", value:$courtCount, in:1...10)
                }.padding()
                
                VStack{
                    Button(action:{
                        if(Double(myPlayers.players.count)/Double(2)<Double(courtCount)){inputInvalid=true}else{
                            goodMatchSets.get_best_matchsets(myPlayers,courtCount);calculationDone=true}},label:{Text("Get good matches")}).alert("Too many courts for the player",isPresented: $inputInvalid){
                                Button("OK",role:.cancel){}
                            }
                    if(calculationDone){Text("... done")}
                    NavigationLink(destination:MatchView()){if(calculationDone){Text("Show")}}
            }
                Spacer()
            }
        }
    }
}

#Preview {
    PlayerConfirmView().environmentObject(PlayersOnCourt())
}
