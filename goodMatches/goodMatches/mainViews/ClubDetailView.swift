//
//  ClubDetailView.swift
//  goodMatches
//
//  Created by Yo Sato on 27/10/2024.
//

import SwiftUI

struct ClubDetailView: View {
    @EnvironmentObject var playerViewModel:PlayerViewModel
    let club:Club
//    let member:Member
    @State private var sendRequestDoneAlert=false
    
    var body: some View {
        NavigationStack{
            VStack{
                Text(club.name).font(.title2).padding()
                HStack{if(club.region != nil){
                    Text(club.region!)}
                    if(club.country != nil){
                        Text(club.country!)
                    }
                }
                Button("Send join request"){
                    playerViewModel.playerDataHandler.request_join(member:playerViewModel.youAsPlayer!.asMember, club:club)
                    sendRequestDoneAlert=true
                }.padding()
            }.alert(isPresented:$sendRequestDoneAlert){
                Alert(title:Text("Join request sent"),message:Text("You will be notified by email when it's approved"))
            }
        }
    }
}

//#Preview {
//    ClubDetailView(club:Club(name: "MY Wimbledon London", organiserUIDs: ["aaa"], players: [PlayerInClub()], country:"UK", region:"London"))
//}
