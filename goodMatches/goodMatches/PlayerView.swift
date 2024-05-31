//
//  PlayerView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerView: View {
    //    @Environment(\.editMode) var editMode
    @StateObject var playerDataHandler=PlayerDataHandler()
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatches:GoodMatchSetsOnCourt
    @State private var playersConfirmedP=false
    @State private var inputInvalid=false
    @State private var selectedPlayers=Set<Player>()
    @State var currentClub="MY Wimbledon London"
    @State var clubs=["MY Wimbledon London","MY Wimbledon Tokyo","Funabashi Tennis Freaks"]
    @State var registerSheet=false
    
    var registeredPlayers:[Player] { playerDataHandler.players.filter{player in player.club==currentClub}.sorted(by:{$0.name < $1.name})
    }
    
    var likelyCourtCount:Int { myPlayers.players.count/3 }

    //    private var isEditing: Bool {
    //      if editMode?.wrappedValue.isEditing == true {
    //       return true
    //   }
    // return false
    //}
    var body: some View {
        NavigationStack{
            Picker("Club",selection:$currentClub){
                ForEach(clubs,id:\.self){
                    Text($0)
                }
            }
            Text("Pick players and confirm").padding(0.2)
                Button("Register a new player"){registerSheet=true}
            List{
                ForEach(registeredPlayers){player in
                    MultipleSelection(title:player.name, isSelected:self.selectedPlayers.contains(player)){
                        if self.selectedPlayers.contains(player){
                            self.selectedPlayers.remove(player)
                        }else{
                            self.selectedPlayers.insert(player)}
                    }
                }.onDelete(perform:delete)                //                Text("\($0.name)"
                
                
                //                )
            }.sheet(isPresented:$registerSheet){            PlayerRegisterView(playerDataHandler:playerDataHandler, currentClub:$currentClub, clubs: $clubs)}
            .navigationTitle("Registered players")
            .navigationBarTitleDisplayMode(.inline)
            Text("\(selectedPlayers.count) players selected")
            
            NavigationLink(destination:PlayerConfirmView().environmentObject(myPlayers).onAppear{
                myPlayers.delete_all_players()
                myPlayers.add_players(Array(selectedPlayers))
            }){
                Text("Confirm")}.disabled(selectedPlayers.count<4)
            
            
        }.onAppear{loadData()}
    }
    
    func delete(at offsets: IndexSet) {
        let players2remove:[Player]=registeredPlayers.enumerated().filter{(ind,_) in offsets.contains(ind)}.map{(_,player) in player }
        Task{await playerDataHandler.delete_players_remote(players2remove)}
    }
    
    func loadData(){
        if(verifyUrl(urlString: "http://127.0.0.1:5000/players")){
            Task{await playerDataHandler.loadData_remote()}
        }else{
            playerDataHandler.loadData_local()
        }
    }

}






//#Preview {
//    PlayerView().environmentObject(PlayersOnCourt())
//}
