//
//  PlayerConfirmView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerConfirmView: View {
    @Binding var registeredPlayers:[PlayerInClub]
    @EnvironmentObject var playerViewModel:PlayerViewModel
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatchSets: GoodMatchSetsOnCourt
    
   // @Binding var registeredPlayers:[Player]
    @State var courtCount:Int=2
    var maxCourtCount=10
//    var defaultCourtCount:Int {}
    @State private var inputInvalid=false
    @State private var calculationDone=false
    @State private var calculating=false
    @State private var liveMode=true
    @State private var singlesOnly=false
    //var courtCount:Int {goodMatchSets.courtCount}
    @State var debug:Bool
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                VStack{
                    HStack{Spacer();Text("Players to be matched").font(.headline);Spacer();Spacer();Spacer()}
                    HStack{Spacer();NavigationLink(destination:PlayerView(club:playerViewModel.currentClub!, debug:$debug)){
                        Text("Change players")
                    }}
                }
                List(myPlayers.players,id:\.self){
                    Text($0.name+(!debug ? "" : " "+String($0.score)))
                }
                Text("\(myPlayers.players.count) players selected")
                Spacer()
                HStack{
                    Stepper("How many courts?\t\t\t \(courtCount)", value:$courtCount, in:1...maxCourtCount)
                }.padding()
                

                Toggle("Singles only",isOn:$singlesOnly)
                
                VStack{              Toggle("Live update",isOn:$liveMode)


//                VStack{
                    Button(action:{calculating=true
                        if(Double(myPlayers.players.count)/Double(2)<Double(courtCount)){inputInvalid=true}else{
                                                        calculating=true
                            //DispatchQueue.global(qos: .background).async {
                            goodMatchSets.get_best_new_matchset(myPlayers,courtCount,singlesOnly:singlesOnly);calculating=false;calculationDone=true
                            //}
                        }
                    },label:{Text("Get good matches")}).padding().alert("Too many courts for the player",isPresented: $inputInvalid){
                                Button("OK",role:.cancel){}
                                }.disabled(calculating)
                    if(calculating){HStack{Text("Calculating...");ProgressView()}}

                    //NavigationLink(destination:TabViews(liveMode:liveMode)){if(calculationDone){Text("Show")}}
                 
                }.navigationDestination(isPresented:$calculationDone){
                    TabViews(liveMode:liveMode,registeredPlayers:$registeredPlayers,debug:debug).navigationBarBackButtonHidden()
                }
                

//                Spacer()
            }
        }
    }
}

//#Preview {
//    PlayerConfirmView(registeredPlayers:Binding<U:Player>([U]),layers,courtCount:2,debug:false).environmentObject(PlayersOnCourt())
//}
