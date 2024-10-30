//
//  ContentView.swift
//  goodMatches
//
//  Created by Yo Sato on 24/02/2024.
//

import SwiftUI
import FirebaseAuth
//import FirebaseFirestore

struct AfterLoginView: View {
    @State var debug=false
    
    //@EnvironmentObject var playerDataHandler:PlayerDataHandler
    @EnvironmentObject var playerViewModel:PlayerViewModel
    @StateObject var networkMonitor=NetworkMonitor()
    @EnvironmentObject var authService:AuthService
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @State var reachable:Bool=true
    @State var dataLoaded:Bool=false
    @State var showInternetAlert:Bool=false
    @State var showReachabilityAlert:Bool=false
//    @State var registeredPlayers:[PlayerInClub]=[]
//    @State var yourClubUIDsNames:[String:String]=[:]
    @State var yourClubNames:[String]=[]
    @State var currentClubName:String? = nil
    @State var currentClubUID:String?=nil
    // @State var goToPlayers:Bool=false
    @State var chosenClub:Club?=nil
    @State private var showClubRegisterView=false
    @State private var showClubSelectView=false
    @State private var showJoinApprovalView=false
    @State private var nameEmail:(String,String)? = nil
    @State private var haveJoinRequests=false
    //@State private var membership:Member?=nil
    
    
    var body: some View {
        NavigationStack {
            VStack{
            HStack{
                if(nameEmail != nil){
                    Spacer();Text(nameEmail!.0);Text("(\(nameEmail!.1))").font(.subheadline);Button("Log out"){Task{try? await authService.regularSignOut()}}}
            }

            Spacer()

            LogoView()
            
                HStack{
                    if(!yourClubNames.isEmpty){
                        VStack{
                            Text("Choose club")
                                Picker("Club",selection:$currentClubName){
                                    ForEach(yourClubNames,id:\.self){Text($0)}}
                            }
                        Button{
                            
                                    //dataLoading=true
                            Task{do{chosenClub=try await playerViewModel.playerDataHandler.loadClubData(clubUID:currentClubUID!); dataLoaded=true}catch{print("hahaha")}}
                                    //registeredPlayers=playerDataHandler.loadData_local()
                                    //dataLoaded=true
                                    
                                    //dataLoading=false
                                
                                //  goToPlayers=true
                            
                        } label: {Text("Start").font(.headline)}.buttonStyle(.borderedProminent).padding()
                    }
                }
                .navigationDestination(isPresented: $dataLoaded){PlayerView(club:chosenClub!, debug: .constant(false))}
                
                //            NavigationLink(destination:PlayerView(playerDataHandler:playerDataHandler)){
                //              Text("Pick players").font(.headline)}
                

                Spacer()

                NavigationLink("Join a"+(!yourClubNames.isEmpty ? "nother" : "")+" club"){                        ClubSelectView()
                    }.padding(5)
                Button("Create a new club"){showClubRegisterView=true}
                    .sheet(isPresented: $showClubRegisterView) {
                        ClubRegisterView()
                    }.padding(5)

            }
            
            Spacer()
        }.task{
            nameEmail=try? await playerViewModel.playerDataHandler.get_userNameEmailPair_fromAuthUserUID(authService.currentUser!.uid)
            if let yourClubUIDsNames=try? await playerViewModel.playerDataHandler.get_affiliatedClubDocIDsNames_fromAuthUserUID(authService.currentUser!.uid){
                if(!yourClubUIDsNames.isEmpty){
                    let yourClubUIDs=Array(yourClubUIDsNames.keys)
                    yourClubNames=Array(yourClubUIDsNames.values)
                    currentClubUID=yourClubUIDs[0]
                    currentClubName=yourClubUIDsNames[currentClubUID!]!
                    
                }
            }
            
            
        }
    }
}


#Preview {
    AfterLoginView().environmentObject(AuthService()).environmentObject(PlayerDataHandler()).environmentObject(PlayersOnCourt())
}
