//
//  ContentView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI


struct ContentView: View {
    @State var debug=true
  
//    @StateObject var playerDataHandler=PlayerDataHandler(urlString_remote:"http://127.0.0.1:5000/players")
    @StateObject var playerDataHandler=PlayerDataHandler(urlString_remote:"https://ancient-gorge-03670-d9436f85c740.herokuapp.com/players")
    @StateObject var networkMonitor=NetworkMonitor()
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @State var reachable:Bool=true
    @State var dataLoaded:Bool=false
    @State var showInternetAlert:Bool=false
    @State var showReachabilityAlert:Bool=false
    @State var registeredPlayers:[Player]=[]

    // @State var goToPlayers:Bool=false
    
    var body: some View {
        NavigationStack {
            Spacer()
            Spacer()
            Text("goodMatches").font(.largeTitle)
            Spacer()
            
//            MultiPicker(selection1:$selection1,selection2:$selection2,values1:values1,values2:values2)

            Button{
                if(!networkMonitor.isConnected){
                    showInternetAlert.toggle()
                }else{
                    //networkMonitor.checkConnection(urlString:"http://127.0.0.1:5000/players")
                    
                    if(false){showReachabilityAlert.toggle()}else{
                        //dataLoading=true
                        Task{registeredPlayers=try! await playerDataHandler.loadData_remote();
                            dataLoaded=true
                        }

                        //dataLoading=false
                                         }
                  //  goToPlayers=true
                }
            } label: {Text("Pick players").font(.headline)}
            .navigationDestination(isPresented: $dataLoaded){PlayerView(registeredPlayers:registeredPlayers,debug:$debug)}

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
