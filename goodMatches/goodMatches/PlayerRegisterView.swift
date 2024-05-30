//
//  PlayerRegisterView.swift
//  goodMatches
//
//  Created by Yo Sato on 15/03/2024.
//

import SwiftUI


struct PlayerRegisterView: View {
    @EnvironmentObject var playerData:ReadData
 //   @EnvironmentObject var myPlayers:PlayersOnCourt
    @State var newPlayerName:String=""
    var initLevels=["Beginner","Improver","Intermediate","Upper intermediate","Advanced"]
    var genders=[Gender.male,Gender.female]
    @State var initLevel="Intermediate"
    @State var gender=Gender.female
    @Binding var currentClub:String
    @Binding var clubs:[String]
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
                }.frame(maxWidth:.infinity,maxHeight:300)
            ZStack{
                Button("Register"){register_player(); backToPlayerView=true}
//                NavigationLink(destination:PlayerView(currentClub:currentClub).environmentObject(playerData),isActive:$backToPlayerView){Text("aaa")}
                
            }
        }       
    }
    func register_player(){
        let score:Int
        switch initLevel{
        case "Advanced": score=70
        case "Upper intermediate": score=60
        case "Intermediate": score=50
        case "Improver": score=40
        case "Beginner": score=30
        default: score=45
        }
        let player=Player(name:newPlayerName, score:score, gender:gender.rawValue, club:currentClub)
        playerData.add_player(player)
    }
}
//#Preview {
//    PlayerRegisterView(currentClub:"").environmentObject(ReadData())
//}
