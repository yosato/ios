//
//  PlayerConfirmView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerConfirmView: View {
    @Binding var registeredPlayers:[Player]
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets: GoodMatchSetsOnCourt
    
   // @Binding var registeredPlayers:[Player]
    @State var courtCount:Int=2
    @State private var inputInvalid=false
    @State private var calculationDone=false
    @State private var calculating=false
    @State private var liveMode=true
    @State var debug:Bool
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                VStack{
                    HStack{Spacer();Text("Players to be matched").font(.headline);Spacer();Spacer();Spacer()}
                    HStack{Spacer();NavigationLink(destination:PlayerView(registeredPlayers:registeredPlayers,debug:$debug)){
                        Text("Change players")
                    }}
                }
                List(myPlayers.players,id:\.self){
                    Text($0.name+(!debug ? "" : " "+String($0.score)))
                }
                Text("\(myPlayers.players.count) players selected")
                Spacer()
                HStack{
                    Stepper("How many courts?\t\t\t \(courtCount)", value:$courtCount, in:1...10)
                }.padding()
                
                VStack{              Toggle("Live update",isOn:$liveMode).padding()


//                VStack{
                    Button(action:{
                        if(Double(myPlayers.players.count)/Double(2)<Double(courtCount)){inputInvalid=true}else{
                            calculating=true
                            goodMatchSets.get_best_matchsets(myPlayers,courtCount);calculating=false;calculationDone=true}},label:{Text("Get good matches")}).padding().alert("Too many courts for the player",isPresented: $inputInvalid){
                                Button("OK",role:.cancel){}
                            }
                    //NavigationLink(destination:TabViews(liveMode:liveMode)){if(calculationDone){Text("Show")}}
                    if(calculating){Text("aaaa");ProgressView()}

                }.navigationDestination(isPresented:$calculationDone){
                    TabViews(liveMode:liveMode,registeredPlayers:$registeredPlayers,debug:debug).navigationBarBackButtonHidden()
                }
//                Spacer()
            }
        }
    }
}

//#Preview {
//    PlayerConfirmView(courtCount:2,debug:false).environmentObject(PlayersOnCourt())
//}
