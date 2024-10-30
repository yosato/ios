//
//  ShowClubRegisterView.swift
//  goodMatches
//
//  Created by Yo Sato on 25/10/2024.
//

import SwiftUI

struct ClubRegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService:AuthService
//    @EnvironmentObject var playerDataHandler:PlayerDataHandler
    @EnvironmentObject var playerViewModel:PlayerViewModel
    @State private var clubName=""
    @State private var country:String = ""
    @State private var region:String = ""
    @State private var alias:String = ""
    @State private var alertFailure=false

    var body: some View {
        VStack{
            HStack{Button("Cancel"){dismiss()};Spacer()}
            Form{
            TextField("Club name",text:$clubName)
            TextField("Country (optional)",text:$country)
            TextField("Region (optional)",text:$region)
            TextField("Alias (optional)",text:$alias)
        }
            
            Button("Create"){
                var myNewClub=create_club(clubName:clubName, creatorUID:authService.currentUser!.uid, country:(country.isEmpty ? nil : country), region:(region.isEmpty ? nil : region), alias:(alias.isEmpty ? nil : alias))
                let clubUID=register_club(myNewClub)
                if(clubUID != nil){
                    myNewClub.uid=clubUID
                }else{
                    alertFailure=true
                }
                
            }.alert(isPresented:$alertFailure){
                Alert(title: Text("Club registration failed"), message: Text("Check the internet connection and try again"))
            }
        }
    }
    
    func create_club(clubName:String, creatorUID:String, country:String?, region:String?, alias:String?)->Club{
        return Club(name: clubName, organiserUIDs: [authService.currentUser!.uid], players:[playerViewModel.youAsPlayer!], country:country, region:region, alias:alias)
    }
    func register_club(_ club:Club)->String?{
        Task{let clubDocID=try await playerViewModel.playerDataHandler.register_club(club)
        return clubDocID
        }
        return nil
    }
}

#Preview {
    ClubRegisterView()
}
