//
//  PlayerRegisterView.swift
//  goodMatches
//
//  Created by Yo Sato on 15/03/2024.
//

import SwiftUI

struct PlayerRegisterView: View {
    @Environment(\.dismiss) var dismiss

    var playerDataHandler:PlayerDataHandler
 //   @EnvironmentObject var myPlayers:PlayersOnCourt
    @State var newPlayerName:String=""
    var initLevels=["Beginner","Improver","Intermediate","Upper intermediate","Advanced"]
    var genders=[Gender.male,Gender.female]
    @State var initLevel="Intermediate"
    @State var gender=Gender.female
    @Binding var currentClub:String
    @Binding var clubs:[String]
    @State var playerAlreadyExists=false
    @State private var backToPlayerView = false
    //init(currentClub:String){
    //    self.currentClub=currentClub
    //}

    var body: some View {
        NavigationStack{
            
            Form{
                TextField("Name",text:$newPlayerName)
                Picker("Proposed initial level",selection:$initLevel){
                    ForEach(initLevels,id:\.self){level in Text(level)}
                }
                Picker("Gender",selection:$gender){
                    Text(Gender.male.rawValue)
                    Text(Gender.female.rawValue)
                }
                Picker("Club",selection:$currentClub){
                    ForEach(clubs,id:\.self){club in Text(club)}
                }
            }.frame(maxWidth:.infinity,maxHeight:300).toolbar{Button("Register"){
                if(playerDataHandler.players.map{player in player.id}.contains( nameClub2id(name:newPlayerName,club:currentClub))){playerAlreadyExists=true}else{
                    Task{await register_player()}}
                dismiss()
            }.disabled(newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
            }
        }.alert("Name already taken, use a different one", isPresented: $playerAlreadyExists){Button("OK"){}}

    }
    func nameClub2id(name:String, club:String)-> String{
        var nameLen:Int {name.split(separator:" ").count}
        var nameAbbr:String {name.split(separator:" ")[0].lowercased()+(nameLen>1 ? name.split(separator:" ")[1] : "")}
        var clubAbbr:String {club.split(separator: " ").map{word in word.prefix(1)}.joined(separator:"")}
        return nameAbbr+"_"+clubAbbr

    }
    func loadData(){
        if(verifyUrl(urlString: "http://127.0.0.1/players")){
            Task{await playerDataHandler.loadData_remote()}
        }else{
            playerDataHandler.loadData_local()
        }
    }

    
    func register_player() async {
        let score:Double
        switch initLevel{
        case "Advanced": score=70.0
        case "Upper intermediate": score=60.0
        case "Intermediate": score=50.0
        case "Improver": score=40.0
        case "Beginner": score=30.0
        default: score=45.0
        }
        let player=Player(name:newPlayerName, score:score, gender:gender.rawValue, club:currentClub)
        await playerDataHandler.add_player_remote(player)
        playerDataHandler.add_player(player)
    }
}
//#Preview {
//    PlayerRegisterView(currentClub:"").environmentObject(ReadData())
//}