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
    
    @State var membersFetchedP=false
    @State private var sessionFetchedP=false
    @State var currentMember:Member?=nil
    @State var organiserYourself:Bool?=nil
    
//    @State private var isInvited=true

    var body: some View {
        NavigationStack{
            VStack{
                LogoView().frame(maxHeight:60)
                if(sessionFetchedP){
                    if(organiserYourself!){LiveSessionView(session:dataService.ourGroupSession!)}else{
                    if let yourGrSession=dataService.ourGroupSession{
                        if let organiser=dataService.uid2member(yourGrSession.organiserUID){
                            Text("\(organiser.displayName)(\(organiser.email))から招待を受けています")
                            Text("参加しますか");NavigationLink("参加") {
                                LiveSessionView(session:yourGrSession)
                            }
                        }}}}
                if (currentMember != nil){
                    Text("友達とのじゃんけんを開催");NavigationLink("主催"){
                        OrganizeView(organiser:currentMember!)
                    }
                }
            }.toolbar{HStack{Text(currentMember != nil ? currentMember!.displayName : "");Text(authService.currentUser!.email!);Spacer();Button("ログアウト"){Task{try? await authService.regularSignOut()}}}}
        }.task{
            /*
             two tasks really, fetching all the members (maybe there's a better way) and fetching the session that includes you
            */
            //1st task
            try? await dataService.fetchMembersFromFB()
            if let currentUser=authService.currentUser{if let email=currentUser.email{
                if let aMember=dataService.get_currentMember_withEmail(email){
                    currentMember=aMember
                    membersFetchedP=true
                }
            }
            }
        //2nd
        if let currentUser=authService.currentUser{
            let uid=currentUser.uid
            let yourGrSessions=try? await dataService.fetchYourGroupSessionsFromFS(uid)
            
            if(!yourGrSessions!.isEmpty){
                await MainActor.run{dataService.ourGroupSession=yourGrSessions![0]}
                sessionFetchedP=true
                organiserYourself = dataService.ourGroupSession!.organiserUID==currentMember!.uid

            }
        }
        }

    }
}

//#Preview {
//    AfterLogInView(currentUser:).environmentObject(AuthService()).environmentObject(DataService())
//}
