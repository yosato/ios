//
//  PlayerView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/02/2024.
//

import SwiftUI

struct PlayerView: View {
    //    @Environment(\.editMode) var editMode
    @ObservedObject var playerData=ReadData()
    @EnvironmentObject var myPlayers:PlayersOnCourt
    @EnvironmentObject var goodMatches:GoodMatchSetsOnCourt
    @State private var playersConfirmedP=false
    @State private var inputInvalid=false
    @State private var selectedPlayers=Set<Player>()
    @State var currentClub="MY Wimbledon London"
    @State var clubs=["MY Wimbledon London","MY Wimbledon Tokyo","Funabashi Tennis Freaks"]
    var registeredPlayers:[Player] { playerData.players.filter{player in player.club==currentClub}.sorted(by:{$0.name < $1.name})
    }
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
            NavigationLink(destination:PlayerRegisterView(currentClub:$currentClub, clubs: $clubs).environmentObject(playerData)){
                Text("Register a new player")}
            List(registeredPlayers,id:\.self){
                item in
                MultipleSelection(title:item.name,isSelected:self.selectedPlayers.contains(item)){
                    if self.selectedPlayers.contains(item){
                        self.selectedPlayers.remove(item)
                    }else{
                        self.selectedPlayers.insert(item)}
                }
                
                //                Text("\($0.name)"
                
                
                //                )
            }
            .navigationTitle("Registered players")
            .navigationBarTitleDisplayMode(.inline)
            Text("\(selectedPlayers.count) players selected")
            
                NavigationLink(destination:PlayerConfirmView().environmentObject(myPlayers).onAppear{
                    myPlayers.delete_all_players()
                    myPlayers.add_players(Array(selectedPlayers))
                }){
                    Text("Confirm")}.disabled(selectedPlayers.count<4)
            

        }
    }
}





#Preview {
    PlayerView().environmentObject(PlayersOnCourt())
}
