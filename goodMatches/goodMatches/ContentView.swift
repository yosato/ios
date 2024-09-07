//
//  ContentView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI


struct ContentView: View {
    @State var debug=false
  
//    @StateObject var playerDataHandler=PlayerDataHandler(urlString_remote:"http://127.0.0.1:5000/players")
    @EnvironmentObject var playerDataHandler:PlayerDataHandler
    @StateObject var networkMonitor=NetworkMonitor()
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @State var reachable:Bool=true
    @State var dataLoaded:Bool=false
    @State var showInternetAlert:Bool=false
    @State var showReachabilityAlert:Bool=false
    @State var registeredPlayers:[Player]=[]
    @State var currentClub="MY Wimbledon London"
    @State var clubs=["MY Wimbledon London","MY Wimbledon Tokyo","Funabashi Tennis Freaks"]
    // @State var goToPlayers:Bool=false
    
    var body: some View {
        NavigationStack {
            Spacer()
            Spacer()
            Text("goodMatches").font(.largeTitle)
            Spacer()
            
//            MultiPicker(selection1:$selection1,selection2:$selection2,values1:values1,values2:values2)

            Picker("Club",selection:$currentClub){
                ForEach(clubs,id:\.self){
                    Text($0)
                }
            }
            
            Button{
                if(!networkMonitor.isConnected){
                    showInternetAlert.toggle()
                }else{
                    //networkMonitor.checkConnection(urlString:"http://127.0.0.1:5000/players")
                    
                    if(false){showReachabilityAlert.toggle()}else{
                        //dataLoading=true
                        //Task{registeredPlayers=try! await playerDataHandler.loadData_remote(); dataLoaded=true}
                        registeredPlayers=playerDataHandler.loadData_local();
                            dataLoaded=true

                        //dataLoading=false
                                         }
                  //  goToPlayers=true
                }
            } label: {Text("Pick players").font(.headline)}
                .navigationDestination(isPresented: $dataLoaded){PlayerView(registeredPlayers:registeredPlayers.filter{player in player.club==currentClub}.sorted{$0.name<$1.name},debug:$debug)}

//            NavigationLink(destination:PlayerView(playerDataHandler:playerDataHandler)){
  //              Text("Pick players").font(.headline)}
            
            Spacer()
            Spacer()
            Spacer()
        }.alert("Internet connection required for loading data",isPresented: $showInternetAlert){Button("OK",role:.cancel){}}
            .alert("Data source cannot be reached",isPresented: $showReachabilityAlert){Button("OK",role:.cancel){}}
            .padding()
    }
    
    
}

//#Preview {
//    ContentView().environmentObject(PlayersOnCourt())
//}
