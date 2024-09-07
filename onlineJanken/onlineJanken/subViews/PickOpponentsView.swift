//
//  PickOpponentsView.swift
//  onlineJanken
//
//  Created by Yo Sato on 07/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct PickOpponentsView: View {
    let organiser:Member
    @EnvironmentObject var dataService:DataService
    //@State var opponents:[Member]=[]
    @State private var goBackToOrganizeView=false
    //@State var session:Session
    @Binding var selectedOpponents:Set<Member>

    var body: some View {
        NavigationStack{
            List{
                ForEach(dataService.registeredMembers.filter{member in member != organiser}){member in
                    MultipleSelection(name: member.displayName, isSelected:selectedOpponents.contains(member)){
                        if(selectedOpponents.contains(member)){
                            selectedOpponents.remove(member)
                        }else{
                            selectedOpponents.insert(member)
                        }
                    }
                }
            }
        }
    }
}

struct MultipleSelection: View {
        var name: String
//    @Binding var club:String
//    @Binding var clubs:[String]
        var isSelected: Bool
        var action: () -> Void
//    @EnvironmentObject var dataService:DataService


        var body: some View {
            Button(action: self.action) {
                HStack {
                    //Button{showSheet=true}label:{Image(systemName:"square.and.pencil")}.imageScale(.small).foregroundColor(.gray)
                    Text(self.name)
                    if self.isSelected {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }//.sheet(isPresented:$showSheet){
                //PlayerRegisterView(registeredPlayersForClub:registeredPlayers,playerDataHandler:playerDataHandler,playerName:name,currentClub:$club,clubs:$clubs)}
        }
}
    


//#Preview {
//    PickOpponentsView().environmentObject(DataService())}
