//
//  FirstLogInView.swift
//  onlineJanken
//
//  Created by Yo Sato on 05/09/2024.
//

import SwiftUI
import FirebaseAuth

struct AfterLogInView: View {
    let yourCredential:User
    @EnvironmentObject var authService:AuthService
    @EnvironmentObject var dataService:DataService
    
    @State var yourGrSession:GroupSession? = nil
    @State var membersFetchedP=false
    @State private var sessionFetchedP=false
    @State var currentMember:Member?=nil
    
//    @State private var isInvited=true

    var body: some View {
        NavigationStack{
            LogoView().padding()
            
            VStack{
                if(sessionFetchedP){
                    Text("\(yourGrSession!.organiser.id)から招待を受けています")
                    Text("参加しますか");NavigationLink("参加") {
                        ParticipateView(groupSession:yourGrSession!)
                    }.padding()
                }
                if (currentMember != nil){
                    Text("友達とのじゃんけんを開催");NavigationLink("主催"){
                        OrganizeView(organiser:currentMember!)
                    }
                }
            }.toolbar{HStack{Text(currentMember != nil ? currentMember!.displayName : "");Text(authService.currentUser!.email!);Spacer();Button("ログアウト"){authService.regularSignOut{_ in}}}}
        }.task{try? await dataService.fetchMembersFromFB()
            if let currentUser=authService.currentUser{if let email=currentUser.email{
                if let aMember=dataService.get_currentMember_withEmail(email){
                    currentMember=aMember
                    membersFetchedP=true}}
            }
        }
        .task{if let currentUser=authService.currentUser{if let email=currentUser.email{yourGrSession=try? await dataService.fetchYourGroupSessionFromFS(email)}}
                if(yourGrSession != nil){sessionFetchedP=true}}

    }
}

//#Preview {
//    AfterLogInView(currentUser:).environmentObject(AuthService()).environmentObject(DataService())
//}
