//
//  PlayerView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerView: View {
    //    @Environment(\.editMode) var editMode
    @State var club:Club
//    @State var registeredPlayers:[PlayerInClub]
    @EnvironmentObject var playerDataHandler:PlayerDataHandler
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatches:GoodMatchSetsOnCourt
    @EnvironmentObject var matchResults:MatchSetHistory
    @State private var playersConfirmedP=false
    @State private var inputInvalid=false
    @State private var selectedPlayers=Set<PlayerInClub>()
    @State var currentClub="MY Wimbledon London"
    @State var clubs=["MY Wimbledon London","MY Wimbledon Tokyo","Funabashi Tennis Freaks"]
    @State var registerSheet=false
    @Binding var debug:Bool
    
    
    var likelyCourtCount:Int { selectedPlayers.count/3 }
    var maxCourtCount:Int {selectedPlayers.count/2}

    //    private var isEditing: Bool {
    //      if editMode?.wrappedValue.isEditing == true {
    //       return true
    //   }
    // return false
    //}
    var body: some View {
        NavigationStack{
//            Picker("Club",selection:$currentClub){
//                ForEach(clubs,id:\.self){
//                    Text($0)
//                }
//            }
            Text("Pick players and confirm").padding(0.2)
            Button("Register a new player"){registerSheet=true}
            List{
                ForEach(club.players){player in
                    MultipleSelection(name:player.name, club:$currentClub, clubs:$clubs, isSelected:self.selectedPlayers.contains(player)){
                        if self.selectedPlayers.contains(player){
                            self.selectedPlayers.remove(player)
                        }else{
                            self.selectedPlayers.insert(player)}
                    }.environmentObject(playerDataHandler)
                }.onDelete(perform:delete)                //                Text("\($0.name)"
                
                
                //                )
            }.sheet(isPresented:$registerSheet){
                PlayerRegisterView(registeredPlayersForClub:$club.players, currentClub:$currentClub, clubs: $clubs)
            }
                //.navigationTitle("Registered players")
                .navigationBarTitleDisplayMode(.inline)
            Text("\(selectedPlayers.count) players selected")
            
            NavigationLink(destination:PlayerConfirmView(registeredPlayers:$club.players, courtCount:likelyCourtCount,maxCourtCount:maxCourtCount,debug:debug).environmentObject(myPlayers).onAppear{
                myPlayers.delete_all_players()
                myPlayers.add_players(Array(selectedPlayers))
            }){
                Text("Confirm")}.disabled(selectedPlayers.count<4)
            
            
        }.onAppear{matchResults.results=[]}
        
    }
    
    func delete(at offsets: IndexSet) {
        var players2remove:[PlayerInClub]=[]
        for offset in offsets{
            players2remove.append(club.players[offset])
        }
        Task{
            await playerDataHandler.delete_players_remote(players2remove)
        }
        club.players.remove(atOffsets: offsets)
    }
    

}

struct MultipleSelection: View {
        var name: String
    @Binding var club:String
    @Binding var clubs:[String]
        var isSelected: Bool
        var action: () -> Void
    @State var showSheet=false
    @EnvironmentObject var playerDataHandler:PlayerDataHandler


        var body: some View {
            Button(action: self.action) {
                HStack {
                    Button{showSheet=true}label:{Image(systemName:"square.and.pencil")}.imageScale(.small).foregroundColor(.gray)
                    Text(self.name)
                    if self.isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }.sheet(isPresented:$showSheet){
                //PlayerRegisterView(registeredPlayersForClub:registeredPlayers,playerDataHandler:playerDataHandler,playerName:name,currentClub:$club,clubs:$clubs)
            }
        }
}
    




//#Preview {
//    PlayerView(club:Club(), debug: .constant(false)).environmentObject(PlayerDataHandler()).environmentObject(PlayersOnCourt())
//}
